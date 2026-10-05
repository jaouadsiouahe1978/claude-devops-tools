import shutil
import smtplib
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import candidatures as cand  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
CSV = """entreprise,poste,email,contact,url_offre,template,accroche
Acme,DevOps,jobs@acme.fr,,https://acme.fr,devops,
Beta,Linux,rh@beta.fr,,,linux,
Gamma,SRE,pas-un-email,,,devops,
"""


class CandidaturesTest(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        (self.tmp / "cv").mkdir()
        (self.tmp / "cv" / "cv.pdf").write_bytes(b"%PDF-1.4 test")
        shutil.copytree(ROOT / "templates", self.tmp / "templates")
        cfg = (ROOT / "config.example.toml").read_text().replace(
            'cv/CV_Jaouad_DevOps.pdf', 'cv/cv.pdf').replace('delai_secondes = 120', 'delai_secondes = 0')
        (self.tmp / "config.toml").write_text(cfg)
        (self.tmp / "c.csv").write_text(CSV)
        self.patch = mock.patch.object(cand, "BASE_DIR", self.tmp)
        self.patch.start()
        self.env = mock.patch.dict("os.environ", {"SMTP_PASSWORD": "x", "SLACK_WEBHOOK_URL": ""})
        self.env.start()

    def tearDown(self):
        self.patch.stop()
        self.env.stop()
        shutil.rmtree(self.tmp)

    def run_cli(self, *args):
        return cand.main(["-c", str(self.tmp / "config.toml"), "--csv", str(self.tmp / "c.csv"),
                          "--no-dns", *args])

    def test_dry_run_sends_nothing(self):
        with mock.patch("smtplib.SMTP") as smtp:
            self.run_cli("send")
        smtp.assert_not_called()

    def test_send_all_valid_rows_once_without_human_gate(self):
        with mock.patch("smtplib.SMTP") as smtp:
            rc = self.run_cli("send", "--confirm")
            self.assertEqual(rc, 1)  # Gamma a un email invalide
            sent = smtp.return_value.__enter__.return_value.send_message
            self.assertEqual(sent.call_count, 2)  # Acme + Beta, sans validation manuelle
            self.assertEqual([c[0][0]["To"] for c in sent.call_args_list],
                             ["jobs@acme.fr", "rh@beta.fr"])
            msg = sent.call_args_list[0][0][0]
            self.assertIn("DevOps", msg["Subject"])
            self.assertEqual(len(list(msg.iter_attachments())), 1)
            # 2e exécution : aucun doublon
            self.run_cli("send", "--confirm")
            self.assertEqual(sent.call_count, 2)

    def test_daily_quota(self):
        rows = "".join(f"E{i},DevOps,a{i}@acme.fr,,,devops,\n" for i in range(15))
        (self.tmp / "c.csv").write_text(CSV.splitlines()[0] + "\n" + rows)
        with mock.patch("smtplib.SMTP") as smtp:
            self.run_cli("send", "--confirm")
        self.assertEqual(smtp.return_value.__enter__.return_value.send_message.call_count, 10)

    def test_transient_error_is_retried(self):
        err = smtplib.SMTPResponseException(451, b"try later")
        with mock.patch("smtplib.SMTP") as smtp, mock.patch("time.sleep"):
            smtp.return_value.__enter__.return_value.send_message.side_effect = [err, None, None]
            rc = self.run_cli("send", "--confirm")
        self.assertEqual(smtp.return_value.__enter__.return_value.send_message.call_count, 3)
        self.assertEqual(rc, 1)  # uniquement à cause de Gamma

    def test_failed_send_is_recorded_and_retried_next_run(self):
        with mock.patch("smtplib.SMTP") as smtp:
            smtp.return_value.__enter__.return_value.send_message.side_effect = \
                smtplib.SMTPRecipientsRefused({})
            self.run_cli("send", "--confirm")
        db = cand.open_db(self.tmp / "data" / "envois.db")
        self.assertEqual(db.execute("SELECT statut FROM envois").fetchone()[0], "echec")
        self.assertFalse(cand.already_sent(db, cand.Candidature(
            "Acme", "DevOps", "jobs@acme.fr", "devops").key))


if __name__ == "__main__":
    unittest.main()
