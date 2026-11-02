#!/usr/bin/env python3
"""Read-only Google Search Console index watcher with GitHub Issue deduplication.

The Google calls only read URL Inspection and Sitemap status. GitHub Issues
are used exclusively to notify when a NEW technical page is confirmed indexed.
Never store Google credentials in the repository or in the output report.
"""
from __future__ import annotations

import json
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen

SITE_URL = "https://mohammadhpp.github.io/Datalogger-RevA/"
REPOSITORY = "mohammadhpp/Datalogger-RevA"
SITEMAP_URL = SITE_URL + "sitemap.xml"
SCOPE = "https://www.googleapis.com/auth/webmasters.readonly"
PAGES = (
    ("home", SITE_URL, False),
    ("hardware", SITE_URL + "hardware.html", True),
    ("validation", SITE_URL + "validation.html", True),
    ("documentation", SITE_URL + "documentation.html", True),
)
REPORT_PATH = Path("gsc-index-report.json")


def gsc_indexed(index: dict, expected_url: str) -> bool:
    """Conservatively detect Google's confirmed, own-canonical indexed state."""
    if index.get("verdict") != "PASS":
        return False
    coverage = str(index.get("coverageState") or "").strip().casefold()
    if not (coverage == "submitted and indexed" or coverage.startswith("indexed")):
        return False
    canonical = index.get("googleCanonical")
    if canonical and str(canonical).rstrip("/") != expected_url.rstrip("/"):
        return False
    return True


def issue_marker(slug: str) -> str:
    return "<!-- datalogger-gsc-indexed:" + slug + " -->"


def request_json(url: str, *, token: str, method: str = "GET",
                 payload: dict | None = None, github: bool = False):
    headers = {
        "Authorization": "Bearer " + token,
        "Accept": "application/vnd.github+json" if github else "application/json",
        "User-Agent": "Datalogger-RevA-Search-Console-Watch/1.0",
    }
    if github:
        headers["X-GitHub-Api-Version"] = "2022-11-28"
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    for attempt in range(3):
        req = Request(url, data=data, headers=headers, method=method)
        try:
            with urlopen(req, timeout=30) as response:
                raw = response.read()
            return json.loads(raw) if raw else {}
        except HTTPError as exc:
            body = exc.read(3000).decode("utf-8", "replace")
            if exc.code in (429, 500, 502, 503, 504) and attempt < 2:
                time.sleep(2 ** attempt)
                continue
            raise RuntimeError(f"{method} {url}: HTTP {exc.code}; {body}") from None
        except (URLError, TimeoutError) as exc:
            if attempt < 2:
                time.sleep(2 ** attempt)
                continue
            raise RuntimeError(f"{method} {url}: network error: {exc}") from exc
    raise RuntimeError("API request failed after retries")


def google_access_token() -> str:
    # Imported lazily so local unit tests need no Google packages or secrets.
    import google.auth
    from google.auth.transport.requests import Request as GoogleRequest
    from google.oauth2 import service_account

    key = os.environ.get("GSC_SERVICE_ACCOUNT_JSON", "").strip()
    if key:
        info = json.loads(key)
        if info.get("type") != "service_account":
            raise RuntimeError("GSC_SERVICE_ACCOUNT_JSON is not a service-account JSON key")
        creds = service_account.Credentials.from_service_account_info(info, scopes=[SCOPE])
    else:
        # Optional preferred keyless setup via google-github-actions/auth (WIF).
        creds, _ = google.auth.default(scopes=[SCOPE])
    creds.refresh(GoogleRequest())
    if not creds.token:
        raise RuntimeError("Google returned no OAuth access token")
    return creds.token


def google_inspect(url: str, token: str) -> dict:
    response = request_json(
        "https://searchconsole.googleapis.com/v1/urlInspection/index:inspect",
        token=token, method="POST",
        payload={"inspectionUrl": url, "siteUrl": SITE_URL, "languageCode": "en-US"},
    )
    return response.get("inspectionResult", {}).get("indexStatusResult", {})


def google_sitemap(token: str) -> dict:
    site_path = quote(SITE_URL, safe="")
    feed_path = quote(SITEMAP_URL, safe="")
    return request_json(
        "https://www.googleapis.com/webmasters/v3/sites/"
        + site_path + "/sitemaps/" + feed_path,
        token=token,
    )


def existing_notification_markers(github_token: str) -> set[str]:
    found: set[str] = set()
    page = 1
    while True:
        issues = request_json(
            "https://api.github.com/repos/" + REPOSITORY
            + f"/issues?state=all&per_page=100&page={page}",
            token=github_token, github=True,
        )
        if not isinstance(issues, list):
            raise RuntimeError("GitHub Issue API response was not a list")
        for issue in issues:
            if "pull_request" in issue:
                continue
            body = issue.get("body") or ""
            for slug, _, notify in PAGES:
                if notify and issue_marker(slug) in body:
                    found.add(slug)
        if len(issues) < 100:
            break
        page += 1
        if page > 100:
            raise RuntimeError("Issue history too large to verify notification deduplication")
    return found


def create_notification(slug: str, url: str, state: dict, token: str) -> dict:
    # No issue is ever opened for "home": its old indexed state is not news.
    title = "Google indexed Datalogger technical page: " + slug
    body = (
        issue_marker(slug) + "\n"
        + "Google Search Console URL Inspection returned a confirmed indexed result.\n\n"
        + f"- URL: {url}\n"
        + f"- Date checked (UTC): {datetime.now(timezone.utc).isoformat(timespec='seconds')}\n"
        + f"- Verdict: {state.get('verdict', 'unknown')}\n"
        + f"- Coverage: {state.get('coverageState', 'unknown')}\n"
        + f"- Google canonical: {state.get('googleCanonical', 'unspecified')}\n\n"
        + "Created automatically by the direct Search Console API watcher. "
        + "This Issue acts as the permanent notification record; "
        + "later runs do not re-announce the same page.\n"
    )
    return request_json(
        "https://api.github.com/repos/" + REPOSITORY + "/issues",
        token=token, github=True, method="POST",
        payload={"title": title, "body": body},
    )


def save_report(report: dict) -> None:
    REPORT_PATH.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("Wrote " + str(REPORT_PATH))
    step_summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if step_summary:
        lines = [
            "## Direct Google Search Console index watch",
            "",
            "| Page | Indexed | Coverage |",
            "| --- | --- | --- |",
        ]
        for entry in report.get("pages", []):
            coverage = str(entry.get("coverageState") or entry.get("error") or "Unknown")
            coverage = coverage.replace("|", "/").replace("\n", " ")
            lines.append(
                f"| {entry['name']} | {'YES' if entry.get('indexed') else 'No / unverified'} | {coverage[:250]} |"
            )
        lines.extend((
            "", "Sitemap: " + str(report.get("sitemap", {}).get("status", "unknown")),
            "",
            "Note: A successful sitemap submission or fetch does not imply that any URL is indexed.",
        ))
        with open(step_summary, "a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")


def main() -> int:
    report = {
        "schema": "datalogger-gsc-watch-v1",
        "checked_at_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "site_url": SITE_URL,
        "pages": [],
        "sitemap": {"url": SITEMAP_URL, "status": "unknown"},
        "notifications_created": [],
        "errors": [],
    }
    # No access credentials are serialized into the report.
    try:
        gh_token = os.environ.get("GITHUB_TOKEN", "")
        if not gh_token:
            raise RuntimeError("GITHUB_TOKEN missing: cannot safely deduplicate notifications")
        if os.environ.get("GITHUB_REPOSITORY", REPOSITORY) != REPOSITORY:
            raise RuntimeError("Unexpected repository; refusing to access GitHub Issues")
        if not (os.environ.get("GSC_SERVICE_ACCOUNT_JSON") or os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")):
            raise RuntimeError("Missing Google credentials: configure GSC_SERVICE_ACCOUNT_JSON secret or WIF")
        access_token = google_access_token()
        already_notified = existing_notification_markers(gh_token)
        for slug, url, notify in PAGES:
            entry = {"name": slug, "url": url, "indexed": False}
            try:
                state = google_inspect(url, access_token)
                entry.update({
                    "verdict": state.get("verdict"),
                    "coverageState": state.get("coverageState"),
                    "googleCanonical": state.get("googleCanonical"),
                    "lastCrawlTime": state.get("lastCrawlTime"),
                    "robotsTxtState": state.get("robotsTxtState"),
                    "pageFetchState": state.get("pageFetchState"),
                })
                entry["indexed"] = gsc_indexed(state, url)
                if notify and entry["indexed"] and slug not in already_notified:
                    issue = create_notification(slug, url, state, gh_token)
                    already_notified.add(slug)
                    report["notifications_created"].append({
                        "name": slug, "url": url, "issue_url": issue.get("html_url")
                    })
            except Exception as exc:
                entry["error"] = str(exc)
                report["errors"].append(slug + ": " + str(exc))
            report["pages"].append(entry)

        try:
            site = google_sitemap(access_token)
            report["sitemap"] = {
                "url": SITEMAP_URL,
                "status": "pending" if site.get("isPending") else "available",
                "isPending": site.get("isPending"),
                "lastDownloaded": site.get("lastDownloaded"),
                "lastSubmitted": site.get("lastSubmitted"),
                "warnings": site.get("warnings"),
                "errors": site.get("errors"),
            }
        except Exception as exc:
            report["sitemap"] = {"url": SITEMAP_URL, "status": "error", "error": str(exc)}
            report["errors"].append("sitemap: " + str(exc))
    except Exception as exc:
        report["errors"].append(str(exc))
    finally:
        save_report(report)

    if report["errors"]:
        for error in report["errors"]:
            print("ERROR: " + error, file=sys.stderr)
        return 1
    print("Direct GSC inspection complete. New technical-page notifications: "
          + str(len(report["notifications_created"])))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
