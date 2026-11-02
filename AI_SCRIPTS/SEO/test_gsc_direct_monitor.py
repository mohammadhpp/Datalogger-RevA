"""Offline tests for exact indexed-status and deduplicated issue-marker logic."""
import unittest

from gsc_direct_monitor import SITE_URL, gsc_indexed, issue_marker


class IndexedStatusTests(unittest.TestCase):
    def test_submitted_and_indexed(self):
        status = {
            "verdict": "PASS",
            "coverageState": "Submitted and indexed",
            "googleCanonical": SITE_URL + "hardware.html",
        }
        self.assertTrue(gsc_indexed(status, SITE_URL + "hardware.html"))

    def test_indexed_without_sitemap(self):
        status = {
            "verdict": "PASS",
            "coverageState": "Indexed, not submitted in sitemap",
            "googleCanonical": SITE_URL + "validation.html",
        }
        self.assertTrue(gsc_indexed(status, SITE_URL + "validation.html"))

    def test_unknown_not_reported_as_indexed(self):
        status = {"verdict": "NEUTRAL", "coverageState": "URL is unknown to Google"}
        self.assertFalse(gsc_indexed(status, SITE_URL + "hardware.html"))

    def test_sitemap_submission_not_indexing(self):
        status = {"verdict": "NEUTRAL", "coverageState": "Submitted"}
        self.assertFalse(gsc_indexed(status, SITE_URL + "validation.html"))

    def test_pass_with_different_canonical_not_announced(self):
        status = {
            "verdict": "PASS",
            "coverageState": "Submitted and indexed",
            "googleCanonical": SITE_URL + "hardware.html",
        }
        self.assertFalse(gsc_indexed(status, SITE_URL + "documentation.html"))

    def test_pass_without_indexed_coverage_not_announced(self):
        status = {"verdict": "PASS", "coverageState": "Crawled - currently not indexed"}
        self.assertFalse(gsc_indexed(status, SITE_URL + "hardware.html"))

    def test_issue_marker_stable(self):
        self.assertEqual(
            issue_marker("documentation"),
            "<!-- datalogger-gsc-indexed:documentation -->",
        )


if __name__ == "__main__":
    unittest.main()
