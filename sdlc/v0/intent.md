# Intent: personal website (V0 cycle)
Author: Claude, drafted for the owner. Cycle: V0. Status: Draft, awaiting owner approval. Date: 2026-11-23. Version: V0.

## Problem
The owner has no personal site. The domain www.adhyaanilkumar.com is registered at Cloudflare but serves nothing. Anyone who looks the owner up today, such as a recruiter or hiring manager, only finds GitHub and LinkedIn.

The resume shows an early-career profile: a B.Tech in Computer Science at VIT Vellore (2022 to 2026), an AI research internship at BluBridge Technologies (May to Jul 2026), and a current SDET role at Apple | Adecco in Bengaluru (since Sep 2026). It also lists three projects: Ultron, Social Grid (live at social-grid.dev) and Sentinel-RAG. None of this is visible in one place a visitor can open and read in a minute. A site would give the owner a single page of their own to send in applications and messages.

## Proposed outcome
A small V0 site live at www.adhyaanilkumar.com, written from resume facts only. A visitor can:
- See who the owner is within a few seconds: name, a short intro and a photo of the owner alone.
- Read the experience, education, projects and skills sections, matching the resume.
- Follow links to GitHub, LinkedIn, each project's repository and the live Social Grid site.
- Read it comfortably on a phone and on a desktop.

One page is the starting point. Stack, hosting and structure are decided in the spec with the owner, not here.

## Affected users and systems
- Recruiters and hiring managers: the main audience, who need the profile quickly.
- Peers and other developers: a secondary audience, who may follow the project links.
- The owner: keeps the site accurate and approves every release.
- The domain and Cloudflare DNS: the domain must point at wherever the site is served.
- The GitHub repo `personal-website`: holds the source and the SDLC artifacts. Work happens on branches and the owner merges.
- The resume (`resume/adhya_resume.tex`, master copy on Overleaf): the only source of facts for the site.
- Whichever free host the spec picks: the new system that serves the site.

## Constraints
- Facts come from the resume only. Nothing invented: no skills, roles, dates or numbers.
- The site and the repo are public. No phone number, home address, ID, bank or account numbers, OTPs or passwords. The resume's phone line is already removed.
- The email address on the site needs the owner's OK. The photo needs the owner's OK; the owner has now supplied one (`assets/photo.jpeg`).
- The photo is a graduation-day selfie with other graduates' faces visible behind the owner. It must be cropped to the owner alone before it goes anywhere public, and resized and compressed for the web (the original is 3672x4896, about 3.7 MB). The uncropped original must not be published.
- Budget: ₹4,300 a month across all personal projects. Prefer free hosting. Any paid item needs its monthly INR cost stated and the owner's approval first. The V0 target is ₹0 a month.
- Follow the AI-native SDLC: Plan, Design, Tasks, Build, Test, Deploy, Maintain, with the owner approving each artifact.
- Never push to `main`. Work on a branch and open a PR, which the owner reviews, merges and approves for the live domain.
- Any UI work uses the `design-taste-frontend` skill and its browser checks, with the result checked at desktop and mobile widths.
- Gmail is drafts only. Nothing is sent for the owner.

## Open questions
1. Stack and hosting: which stack, and which free host (for example a static host on a free tier) serves www.adhyaanilkumar.com through Cloudflare DNS?
2. One page or several: should V0 be a single scrolling page, or separate pages for projects and experience?
3. Contact: show the email address, offer a contact form, or show neither and rely on the GitHub and LinkedIn links? (The resume's email is `adhya.a1205@gmail.com`.)
4. Photo: crop the supplied graduation photo to the owner alone, or use a different photo? If cropped, what framing?
5. Resume PDF: offer a downloadable resume? If yes, a phone-free PDF has to be built, since the `.tex` master may carry details that should not be public.
6. Staying in sync: how do the site and the Overleaf master resume stay consistent (manual copy per update, or a checked-in `.tex` the site is built from)?
7. Analytics: none, or a privacy-friendly free counter?
8. Look and feel: dark, light or both, and any visual direction the owner wants before the design pass proposes options?
9. Extra sections: should V0 stay strictly to the resume, or include anything beyond it, such as writing or the story project?
10. City: the resume shows "Bengaluru, India". Show it on the site, or leave it out?

## Owner answers (2026-11-24)
Collected by form. The spec must build on these and resolve what is still open.
1. Hosting: **AWS is approved** (Social Grid already hosts there; reuse its setup). The owner has MCP servers for **AWS and Cloudflare**. The owner has an **AWS account** for the site (domain stays on Cloudflare DNS). The owner also has the **21st.dev MCP** (UI components) and wants the **design-taste-frontend** skill used. The spec researches AWS hosting options and states each one's monthly INR cost; the budget rule still applies (prefer ₹0, stop for approval on anything paid).
2. Structure: one main page with a resume link, links to all socials, the owner's photo and a **timeline**; plus a **detail page per project** (Ultron, Social Grid, Sentinel-RAG).
3. Contact: do not show the email or other contact details. Add a **resume download** component and a **contact form**.
4. Photo: crop `assets/photo.jpeg` to **head and shoulders**, owner only; resize and compress. Never publish the original.
5. Resume PDF: yes (see 3). It must be phone-free and contain nothing barred by the hard rules.
6. Sync: **every site version ships with the latest resume**. The spec decides the mechanism.
7. Analytics: **Cloudflare Web Analytics**.
8. Look and feel: the design pass proposes options; the owner picks.
9. Extras: **resume content only** in V0 (plus the timeline and project pages above).
10. City: **show "Bengaluru, India"**.
