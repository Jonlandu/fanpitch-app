# FanPitch — Submission checklist

> Deadline: **27 May 2026, end of day**
> Challenge 3 (Fan Squad) upload link:
> https://amazoncorporate.app.box.com/f/63565ac34f6b4792b06310c279c4a0b4

## Files to put in `FanPitch.zip`

- [x] **`github_link.txt`** ✅ — already drafted in `deliverables/github_link.txt`
- [ ] **`presentation_video.mp4`** — record using `deliverables/video_script.md` (≤3 min, ≤720p)
- [ ] **`executive_summary.pdf`** — build the 5 slides from `deliverables/executive_summary.md`, export to PDF
- [ ] *(optional)* `prfaq.pdf` — skip for v1, can resubmit `_v2.zip` later

## The deck is already built ✅

`executive_summary.pdf` (1 MB, 5 slides, landscape 1280×720) was generated from `executive_summary.html` via Chrome headless. Branded with the FanPitch palette (green / orange / gold / ink), Traction signals on slide 5, all visuals self-contained — no external images needed.

If you want to **regenerate** after edits to the HTML:
```bash
cd deliverables
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer --no-margins \
  --print-to-pdf=executive_summary.pdf \
  "file://$(pwd)/executive_summary.html"
```

### Optional — add iPhone screenshots to slide 2

The deck is already visually rich, but if you want to embed real screenshots of the 4 tabs (could nudge "Implementation Quality" higher with the judges):

1. From your iPhone, open FanPitch, screenshot each tab (Pour toi · Live · Matchs · Moi). 4 PNGs.
2. Drop them in `deliverables/screenshots/` with these exact names: `tab1_foryou.png`, `tab2_live.png`, `tab3_matches.png`, `tab4_me.png`.
3. Tell me to re-embed them; I'll update the HTML and regenerate the PDF in 30 seconds.

## Record the video (30 min)

1. Read `deliverables/video_script.md` end to end.
2. Run the simulator on EC2 before recording so events are flowing.
3. Record at **1280×720, 30 fps, mp4**. Single take ideally.
4. Trim to ≤3 min in iMovie / DaVinci / Loom.
5. Save as `presentation_video.mp4`.

## Build the zip (1 min)

```bash
cd /Users/kibundulukazadiinnocent/aws_academy
mkdir -p FanPitch_submission
cp fanpitch-app/deliverables/github_link.txt        FanPitch_submission/
cp ~/Downloads/presentation_video.mp4               FanPitch_submission/
cp ~/Downloads/executive_summary.pdf                FanPitch_submission/
cd FanPitch_submission
zip -r ../FanPitch.zip .
```

## Upload to box.com

1. Go to https://amazoncorporate.app.box.com/f/63565ac34f6b4792b06310c279c4a0b4
2. Sign in (free Box account if needed).
3. Upload `FanPitch.zip`.
4. Confirm the file appears in the team list.
5. Screenshot the confirmation page for your records.

## Sanity-check before uploading

- [ ] Zip opens cleanly, has exactly 3 files (4 if you ship the PRFAQ).
- [ ] `presentation_video.mp4` plays in QuickTime, is ≤3:00, is ≤720p.
- [ ] `executive_summary.pdf` opens, all 5 slides readable, file <10 MB.
- [ ] `github_link.txt` URLs work (Cmd+click them, you reach the repos).
- [ ] Both GitHub repos are **public** (or MoellerO invited as collaborator if private).
- [ ] **No hackathon DFL XML / data files in the repos** (already enforced by `.gitignore`).
- [ ] Latest commits pushed to `main` on both repos.

## Team / repo facts (for the box upload form)

- **Team name**: `FanPitch` *(or the team captain's email if FanPitch isn't accepted)*
- **Challenge**: Challenge 3 — Fan Squad — Real-Time Social Match Experience
- **Repos**:
  - https://github.com/Jonlandu/fanpitch-app
  - https://github.com/Jonlandu/fanpitch-api
- **Live backend**: http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com/api/docs/
- **Demo creds**: `congo_general / fanpitch2026` (20 fans across 10 countries available)
