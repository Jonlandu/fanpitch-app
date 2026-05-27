# FanPitch — Submission checklist

> Deadline: **27 May 2026, end of day**
> Challenge 3 (Fan Squad) upload link:
> https://amazoncorporate.app.box.com/f/63565ac34f6b4792b06310c279c4a0b4

## Files to put in `FanPitch.zip`

- [x] **`github_link.txt`** ✅ — already drafted in `deliverables/github_link.txt`
- [ ] **`presentation_video.mp4`** — record using `deliverables/video_script.md` (≤3 min, ≤720p)
- [ ] **`executive_summary.pdf`** — build the 5 slides from `deliverables/executive_summary.md`, export to PDF
- [ ] *(optional)* `prfaq.pdf` — skip for v1, can resubmit `_v2.zip` later

## Build the 5-slide deck (15 min)

1. Open Keynote / PowerPoint / Google Slides.
2. Pick a clean dark template (green accent #00A651 matches the FanPitch brand).
3. Create 5 slides, copy-paste each `## SLIDE N` block from `executive_summary.md`.
4. For each `[VISUAL]` hint:
   - **Slide 1**: 3 phone mockups side-by-side (stat app · WhatsApp · stadium).
   - **Slide 2**: 4 screenshots of the 4 tabs (take them now from the app — iPhone simulator or device).
   - **Slide 3**: Architecture diagram — copy the ASCII box, or rebuild in Excalidraw.
   - **Slide 4**: Either a Swagger UI screenshot of `/api/docs/` or the table styled.
   - **Slide 5**: Map of Africa with country chips, three-pillar scorecard.
5. Export → File > Export to PDF. Name it `executive_summary.pdf`.

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
