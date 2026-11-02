# Direct Google Search Console API monitor — Datalogger RevA

This repository now includes a GitHub Actions watcher that calls **Google's official
Search Console URL Inspection and Sitemaps APIs directly**. It replaces the paid
GSC Wizard dependency for the monitoring workflow.

**Status:** the code and scheduled workflow are installed. A successful live API
run requires one-time Google Cloud/Search Console authentication setup by the
repository owner. The source code contains NO API keys or private credentials.

## Monitored URLs

- https://mohammadhpp.github.io/Datalogger-RevA/ — already indexed; **never send a new alert** merely for this page
- https://mohammadhpp.github.io/Datalogger-RevA/hardware.html
- https://mohammadhpp.github.io/Datalogger-RevA/validation.html
- https://mohammadhpp.github.io/Datalogger-RevA/documentation.html

Sitemap: https://mohammadhpp.github.io/Datalogger-RevA/sitemap.xml

## One-time setup — service account + GitHub encrypted secret

1. Visit [Google Cloud Console](https://console.cloud.google.com/) and select
   an existing project or create a new project dedicated to Search Console.
2. In [API Library](https://console.cloud.google.com/apis/library/searchconsole.googleapis.com),
   enable **Google Search Console API** in that project.
3. Open [Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts).
   Create a dedicated service account (for example `datalogger-gsc-reader`).
   Copy its full email address ending in `.iam.gserviceaccount.com`.
   You do **not** need a broad Google Cloud project Editor/Owner role for
   reading Search Console data.
4. Open [Google Search Console](https://search.google.com/search-console/).
   Select the **exact URL-prefix property**
   `https://mohammadhpp.github.io/Datalogger-RevA/`, then
   **Settings → Users and permissions → Add user**. Add the service account
   email as **Full user** for URL Inspection. This does not change the site's
   existing HTML-file verification and does not grant access to your entire
   Google account.
5. In Google Cloud, open the new service account → **Keys → Add key → Create new key → JSON**.
   The browser downloads a private JSON key. **Never paste the JSON into a chat,
   GitHub issue, commit, or repository file.**
6. Open [repository Actions secrets](https://github.com/mohammadhpp/Datalogger-RevA/settings/secrets/actions).
   Click **New repository secret**. Set the secret **name** to
   `GSC_SERVICE_ACCOUNT_JSON`. Open the downloaded JSON file locally in a text
   editor and paste its **entire contents** into the secret **value**.
   Save it; delete the downloaded JSON from unsecured locations after setup.
7. Go to [Actions → Direct Google Search Console Index Watch](https://github.com/mohammadhpp/Datalogger-RevA/actions/workflows/gsc_direct_index_watch.yml),
   choose **Run workflow → main → Run workflow**.
   Check the run's Summary for the four URL statuses. If successful,
   the run includes a `gsc-index-report` artifact.

If key creation is blocked by your Google Cloud organization, **do not bypass
the security policy**. Configure the keyless alternative below instead.

## Preferred security alternative: Google Workload Identity Federation (WIF)

The workflow also supports keyless Google OAuth using GitHub OIDC:

1. Create a Workload Identity Pool and GitHub OIDC provider in Google Cloud.
   Restrict the provider's attribute condition to **this repository**,
   `assertion.repository == 'mohammadhpp/Datalogger-RevA'`, and preferably
   the `main` branch. Permit that provider to impersonate the dedicated
   service account via `roles/iam.workloadIdentityUser`.
2. Add the **same service account email** as a Full user on the Search Console
   property (as described above).
3. Create two GitHub repository Actions secrets:
   - `GSC_WIF_PROVIDER`: full provider resource name
     (`projects/NUMBER/locations/global/workloadIdentityPools/POOL/providers/PROVIDER`)
   - `GSC_SERVICE_ACCOUNT_EMAIL`: the service account email.
4. Leave `GSC_SERVICE_ACCOUNT_JSON` **unset** so the workflow uses WIF.

Official reference:
[Google GitHub Actions authentication](https://github.com/google-github-actions/auth#readme).
WIF is more secure than a long-lived downloaded JSON key, but requires
additional Google Cloud IAM configuration.

## What happens automatically?

- GitHub Actions runs every day at **09:07 Tehran time** (05:37 UTC),
  subject to GitHub scheduled-action delays or pauses.
- A manual run is also available through **Run workflow**.
- The script reads the Search Console **indexed version** of all four pages,
  not a live URL indexing request. It does NOT submit Google indexing requests.
- It reads the official submitted sitemap's pending/download/error status.
- It only considers a technical page newly indexed after a Google **PASS** with
  confirmed indexed coverage and no contradictory canonical.
- For each newly indexed technical page it opens exactly one GitHub Issue,
  with a stable marker to prevent repeated announcements on subsequent runs.
  The main page is intentionally excluded from alert creation.
- GitHub's Issue notifications depend on your **Watch / custom Issues**
  and notification settings. You can also review Issues manually.
- A sanitized JSON status report is attached as a run artifact; no credentials
  are included.

**Important:** a submitted sitemap, a successful page deployment, or an
`UNKNOWN` API inspection result is not proof of indexing. API 403/401 errors
must be fixed; they are not interpreted as "not indexed".

## Troubleshooting

| Error | Likely cause |
| --- | --- |
| `Missing Google credentials` | No secret or WIF settings are configured |
| `HTTP 403` during Google calls | Service account not added to the **exact** property, wrong permissions, or API not enabled |
| `HTTP 401` | Bad/expired key, invalid WIF trust configuration, or token issue |
| `HTTP 403` when creating an Issue | GitHub Actions `issues: write` permission restricted by repo/org policy |
| Sitemap 404 | Wrong sitemap URL/property or no sitemap registered in Search Console |
| No new GitHub Issue | Technical pages not yet officially indexed, or Issue already exists |
| Scheduled checks stop after extended inactivity | GitHub may disable scheduled Actions in public repos after 60 days of no activity |

## Source and tests

- Watcher: [`AI_SCRIPTS/SEO/gsc_direct_monitor.py`](../AI_SCRIPTS/SEO/gsc_direct_monitor.py)
- Offline checks: [`AI_SCRIPTS/SEO/test_gsc_direct_monitor.py`](../AI_SCRIPTS/SEO/test_gsc_direct_monitor.py)
- Schedule: [`.github/workflows/gsc_direct_index_watch.yml`](../.github/workflows/gsc_direct_index_watch.yml)

Google's documentation:
[URL Inspection API](https://developers.google.com/webmaster-tools/v1/urlInspection.index/inspect) ·
[Sitemaps API](https://developers.google.com/webmaster-tools/v1/sitemaps/get) ·
[Search Console API authorization](https://developers.google.com/webmaster-tools/v1/how-tos/authorizing).
