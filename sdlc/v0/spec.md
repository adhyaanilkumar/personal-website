# Spec: personal-website V0
Author: Claude (R2 spec subagent, from `intent.md`), for adhyaanilkumar. Cycle: V0. Status: **Approved by owner, 2026-11-24.** The look and feel stays open for the design pass (section 14). Date: 2026-11-24.

A small static site at www.adhyaanilkumar.com: one main page (intro, photo, socials, resume download, timeline, skills, projects, contact form) and one detail page per project. It is built from the checked-in resume, hosted on the owner's AWS account with DNS staying on Cloudflare, and a contact form that never shows the owner's email.

```
GitHub PR (CI: lint, test, build, resume PDF, privacy scan, browser checks)
   |  owner merges, then approves the "production" environment
   v
GitHub Actions --OIDC--> AWS (us-east-1)
   S3 (private bucket) <--OAC-- CloudFront (www.adhyaanilkumar.com, ACM cert) <-- Cloudflare DNS (DNS only)
   Lambda Function URL --> SES --> owner's inbox          (contact form, Turnstile-checked)
Browser --> Cloudflare Web Analytics beacon (cookie-free), Cloudflare Turnstile (form only)
```

Terms for a new grad: **S3** is AWS file storage. **CloudFront** is AWS's CDN (copies of your files served from nearby servers). **OAC** (Origin Access Control) lets only CloudFront read the private bucket. **ACM** issues the free HTTPS certificate. **OIDC** lets GitHub Actions get short-lived AWS permissions with no stored password. **Lambda** runs a small function on demand. **SES** is AWS's email-sending service. **Turnstile** is Cloudflare's free bot check (a CAPTCHA replacement).

---

## 1. Decisions

"Owner" rows are the owner's own answers (in `intent.md` and to this spec's section 14). Rows that began as this spec's recommendations are marked **Approved**: the owner approved the spec as a whole on 2026-11-24. D8 (look and feel) is decided later, in the design pass.

| # | Date | Decision | Who / status |
|---|---|---|---|
| D1 | 2026-11-24 | Host on the owner's **AWS account** (the one Social Grid already runs on); the domain and DNS stay on Cloudflare. Use the 21st.dev MCP and the `design-taste-frontend` skill. AWS hosting is approved as a direction; the monthly INR cost is stated in section 2 and anything non-zero still needs approval. | Owner |
| D2 | 2026-11-24 | One main page (resume link, socials, photo, timeline) plus a detail page per project: Ultron, Social Grid, Sentinel-RAG. | Owner |
| D3 | 2026-11-24 | Do **not** show the email or any contact detail: not on the page, not in the page source or scripts, not in the resume PDF. Contact is by the form only. Offer a resume download and a contact form. | Owner (restated 2026-11-24) |
| D4 | 2026-11-24 | Photo: `assets/photo.jpeg` cropped to head and shoulders, resized and compressed. The original is never published. **Tighter crop, no background removal; a sliver of a neighbour may remain and the owner accepts that.** | Owner (section 14 answer 4) |
| D5 | 2026-11-24 | The resume PDF is phone-free and, per D3, **email-free**, and holds nothing else the hard rules bar. | Owner |
| D6 | 2026-11-24 | Every site version ships with the latest resume. | Owner (mechanism: D14) |
| D7 | 2026-11-24 | Analytics: Cloudflare Web Analytics. | Owner |
| D8 | 2026-11-24 | Look and feel: the design pass proposes options, the owner picks. | Owner |
| D9 | 2026-11-24 | Resume content only (plus the timeline and project pages). | Owner |
| D10 | 2026-11-24 | Show "Bengaluru, India". | Owner |
| D11 | 2026-11-24 | **Host: S3 + CloudFront** (pay-as-you-go, inside CloudFront's always-free tier). About ₹1 to ₹2 a month. Not Amplify. Cloudflare Pages is the ₹0 fallback. See section 2. | **Owner approved** (section 14 answer 1), including the ₹1 to ₹2 a month |
| D12 | 2026-11-24 | **Stack: Astro (static output) + TypeScript + React islands + Tailwind CSS + a shadcn-style `components.json`**, Node 22, npm, Makefile wrappers. See section 6. | **Approved** (owner, 2026-11-24) |
| D13 | 2026-11-24 | **Contact form: Lambda Function URL + SES + Cloudflare Turnstile**, nothing stored, the owner's address held only in the Lambda configuration. Under ₹1 a month. The domain has **no MX records**, so SES setup needs no mail-record changes. See section 4. | **Owner approved** (section 14 answer 5) |
| D14 | 2026-11-24 | **Resume mechanism:** the repo holds the owner's `.tex` as it is (the heading email stays, per D15). The build makes a **sanitised copy** with the email line removed, parses that copy into site data and compiles the PDF from it with pdflatex in a pinned TeX Live container, so the site, timeline and PDF always come from the same file and never show the email. A privacy scan fails the build on any phone number anywhere, and on any email except in two named files. See section 5. | **Approved** (owner, 2026-11-24) |
| D15 | 2026-11-24 | **Explicit owner choice: the email address stays in the repo's `resume/adhya_resume.tex` and in `sdlc/v0/intent.md`, in a public repo.** Nowhere else in the repo, and never on the site or in the PDF (D3). CLAUDE.md now carries the matching line, "Email exception (owner, 2026-11-24)". **The original `assets/photo.jpeg` stays out of git** (gitignored or moved outside the repo; only processed outputs are committed). | Owner (section 14 answer 3) |
| D16 | 2026-11-24 | Photo is processed by a repeatable script (auto-orient, tight head-and-shoulders crop, resize, strip metadata; no background removal, D4). Output in `public/images/`; the original lives outside the repo. See section 8. | **Approved** (owner, 2026-11-24) |
| D17 | 2026-11-24 | Deploy: PR with CI, owner merges, then a GitHub Environment `production` needs the owner's approval before the deploy job runs. GitHub-to-AWS by OIDC, least-privilege role. | **Approved** (owner, 2026-11-24) |
| D18 | 2026-11-24 | Infra is described in one reviewed CloudFormation template. **Reading** AWS and Cloudflare through their MCPs is allowed at any time (D23). **Changing** them is allowed after the owner approves the task's `plan.md` and its cost: the infra task applies the reviewed template through the MCPs. It creates nothing paid without approval and never touches the live `www` DNS record or the production distribution without the owner's approval. No long-lived AWS keys are created. | **Owner approved** (section 14 answer 2) |
| D19 | 2026-11-24 | The timeline has the three dated resume entries (VIT 2022 to 2026, BluBridge May to Jul 2026, Apple \| Adecco Sep 2026 to present). Projects have no dates in the resume and **stay off the timeline**. | **Owner** (section 14 answer 10) |
| D20 | 2026-11-24 | Project detail pages are **short and use only what the resume says** (title, stack line, its three bullets, links). | **Owner** (section 14 answer 7) |
| D21 | 2026-11-24 | For the design skill the site's kind is **software** (a developer portfolio). | **Approved** (owner, 2026-11-24) |
| D22 | 2026-11-24 | Canonical URL is `https://www.adhyaanilkumar.com`. The bare `adhyaanilkumar.com` redirects to it with a Cloudflare redirect rule. | **Approved** (owner, 2026-11-24) |
| D23 | 2026-11-24 | **Standing MCP permission.** Subagents may use the MCP servers named in the MCP plan (section 12: Playwright, 21st.dev, AWS, Cloudflare, and Atlassian for escalations) for this cycle and future cycles **without asking per call**. The spec-writing agent may use any available MCP directly while researching, **inspect and research only**: no paid resources, no deploys, no changes to live DNS or production infra. Guards that stay: no paid AWS or Cloudflare resource without its monthly INR cost stated and the owner's approval; no deploy to the live domain without the owner's approval; Gmail is drafts only. | Owner (relayed by the coordinator) |
| D24 | 2026-11-24 | **Reuse Social Grid's setup where it fits:** the same AWS account and its `all-projects-monthly` AWS Budget (alerts at 50% and 80% actual, 100% forecast); the `production` GitHub Environment with the owner as required reviewer; branch protection (PR required, `ci` green, zero required approving reviews, since the owner's merge click is the approval); a Makefile with `make build`, `make lint`, `make test`; the Cloudflare DNS-only record pattern. **Not reused:** the Lightsail server, Docker Compose, Caddy and SSH deploys (a static site needs none of them). The deploy login is new: OIDC instead of an SSH key. | **Approved** (owner, 2026-11-24) |
| D25 | 2026-11-24 | Copy Social Grid's Claude PR review (`claude-review.yml` plus `REVIEW.md`, on the owner's Claude plan, no extra cost) into this repo in a **later task**. | **Owner** (section 14 answer 13) |
| D26 | 2026-11-24 | **The AWS account is a paid account**; the owner uses an IAM user on it. This corrects the earlier statement that it was on the Free plan, so there is no Free-plan expiry to plan for. Normal cost monitoring applies: the existing `all-projects-monthly` budget alerts, and a look at the Billing page at each release. | Owner (correction, 2026-11-24) |
| D27 | 2026-11-24 | **21st.dev is paid by a family member and is not counted in the owner's ₹4,300 budget.** No INR line is needed for it. Reuse Social Grid's configuration: a gitignored `.mcp.json` whose `x-api-key` header is the placeholder `${API_KEY_21ST}`, with the real key in a Windows user environment variable. No secret in any committed file. | Owner (2026-11-24) |
| D28 | 2026-11-24 | **Employer detail approved:** publish the Apple \| Adecco role and the Radar bullet on the site and in the PDF. | Owner (section 14 answer 8) |
| D29 | 2026-11-24 | **Overleaf routine:** manual copy of the `.tex` into `resume/`, then `make resume-sync`, then a PR. No Overleaf Git sync. | Owner (section 14 answer 11) |
| D30 | 2026-11-24 | **Socials: GitHub and LinkedIn only.** | Owner (section 14 answer 9) |
| D31 | 2026-11-24 | **MCP setup task:** copy the AWS, Cloudflare and 21st.dev MCP setup from Social Grid into this repo's project scope as an early task. Secrets stay out of committed files. The owner checks the Cloudflare token's scope. | Owner (section 14 answer 14) |

### 1.1 Concerns found while reading the intent, the resume and the machine

1. **The email address will be in a public repo, by the owner's choice (D15).** `resume/adhya_resume.tex` has it in the heading and `sdlc/v0/intent.md` prints it. Recorded as an explicit owner decision, not an oversight. Two consequences to keep in view: git history cannot be un-published, and scrapers harvest addresses from public repos, so the contact form hides the address from the **site**, not from the internet. The rule that stays: the address appears in those two files only, never on the site, in a script, in the PDF or in any other tracked file. CLAUDE.md's hard rules say to ask before publishing an email; this answer is that permission, and the main session has added the exception to CLAUDE.md ("Email exception (owner, 2026-11-24)").
2. **`assets/photo.jpeg` sits inside the repo folder** (3.7 MB, other graduates' faces visible, EXIF orientation tag present). It must not be committed. Move it out of the repo or gitignore it.
3. **The photo cannot be cropped perfectly clean.** Looking at a downsized copy (scratchpad only, not published): another graduate's face sits right beside the owner's right ear, and more people are behind the shoulders. The owner chose a tighter crop with no background removal and accepts that a sliver of a neighbour may remain (D4). The original, which shows many faces, must still never be published.
4. **CLAUDE.md asks before publishing "employer detail".** Answered: the owner approved publishing the Apple | Adecco role and the Radar bullet (D28). Resolved.
5. **Project pages will be thin.** D9 plus the "facts from the resume" rule leave each project with a title, a stack line, three bullets and links. The owner accepts short pages (D20). Anything richer later (screenshots, architecture, a write-up) is a new fact source the owner must supply.
6. **The design skill assumes stand-in stock photos and a plain HTML kit.** Its photo search must not be used on this site (only the owner's own photo, no invented imagery). Its kit styles with its own `system.css`; D12's Tailwind has to map onto the skill's tokens rather than fight them (section 6.3).
7. **MCP availability differs by project.** In `~/.claude.json`, `playwright` is global, but the **AWS MCP** (`aws-mcp`, `https://aws-mcp.ap-southeast-1.api.aws/mcp`) and the **Cloudflare MCP** (`https://mcp.cloudflare.com/mcp`) are configured only for `C:\git\social-grid` (local scope, in `~/.claude.json`, signed in by OAuth, no key in a repo file). Social Grid's `.mcp.json` (gitignored there) defines the 21st.dev server with a `${API_KEY_21ST}` placeholder. **None of the three is connected in this repo or in the session that wrote this spec**, so no live AWS or Cloudflare inspection was possible; the AWS facts come from Social Grid's `sdlc/v0/deploy-plan.md` and `maintain-plan.md`. The owner decided to copy this setup here as an early task (D31, section 12).
8. **AWS cost has no hard cap, and the account is shared (D26).** The account is a paid one (the owner uses an IAM user), shared with Social Grid's Lightsail server. There is no Free-plan expiry. Monitoring is the existing `all-projects-monthly` budget (alerts at 50% and 80% of actual spend and 100% forecast), plus a look at the Billing page at each release. The infra task's first read-only step confirms the account's plan and that the IAM user's permissions cover S3, CloudFront, ACM, Lambda, SES and CloudFormation, and asks for nothing broader if they do not.
9. **No AWS CLI and no LaTeX on this PC** (Node 22.16 and Docker are installed). The PDF is built in a container and AWS setup uses the AWS console or CloudShell, not a local CLI.
10. **The `.tex` is pdflatex-specific** (`\input{glyphtounicode}`, `\pdfgentounicode`, FiraMono, tgheros). friday compiles its own resume with tectonic, which is XeTeX-based and may not accept these. This site uses pdflatex.

---

## 2. Hosting options

### 2.1 Assumptions behind the costs

- Traffic: 3,000 visits a month (generous for a new personal site), about 1.5 MB transferred per visit including the occasional PDF = about 4.5 GB a month, about 75,000 requests.
- 20 deploys a month of about 60 files. Site size under 50 MB.
- Exchange rate **₹95 per USD** (OFX showed 94.12 on 2026-10-21; social-grid's plan used 94.6 on 2026-11-07). AWS India invoices Indian accounts with **18% GST**, as social-grid's plan noted, so INR figures below include it.
- **Account:** the existing Social Grid AWS account, a **paid** account (D26), billed in USD with GST. The INR figures below are what it costs, with no credits assumed.
- S3 request prices for Mumbai could not be read from AWS's pages; I used US-like rates, so treat the S3 part as an estimate. It is a fraction of a rupee either way.

### 2.2 Comparison

| | **A. S3 + CloudFront** (recommended) | **B. AWS Amplify Hosting** | **C. Cloudflare Pages** (free baseline) |
|---|---|---|---|
| Monthly cost at the assumptions | **about ₹1 to ₹2** (transfer and requests sit inside the always-free tier; the rest is S3 storage and upload requests) | **about ₹120** (4.5 GB x $0.15 plus builds at $0.01 a minute, plus GST). The 12-month free tier is for older accounts, so assume none | **₹0** |
| Free-tier limits | CloudFront always free every month: 1 TB out, 10 million requests, 2 million Function invocations, free SSL certificates. Beyond that, India transfer is $0.109 a GB (about ₹12 with GST) | 12 months only: 1,000 build minutes, 15 GB served, 5 GB stored. After that $0.15 a GB served, $0.023 a GB stored | Free plan: unlimited sites, static requests and bandwidth; 500 builds a month; 20,000 files; 25 MiB a file; 100 custom domains |
| Expires after 12 months? | **No** for CloudFront and Lambda. S3 and SES have no free tier to lose here; they cost rupees a year | **Yes**: its free tier is "12 months" and is for older accounts | No |
| HTTPS and custom domain with Cloudflare DNS | ACM certificate in us-east-1, validated by a CNAME at Cloudflare; `www` CNAME to the distribution, grey cloud (DNS only) | Same pattern, set up from the Amplify console | Native: the domain is already at Cloudflare, one click |
| Deploy from a PR merge | GitHub Actions: OIDC role, `s3 sync`, CloudFront invalidation, behind an Environment approval | Built in (connect repo, build on merge, **PR previews included**) | Built in (**PR preview URLs included**) |
| Spend cap | None (pay-as-you-go). Mitigated by a budget alert and the small page weight | None | None needed |
| Extra work | Highest: bucket, distribution, a CloudFront Function for `/projects/x/` to `index.html`, response-headers policy, role | Low | Lowest |
| Weak point | No per-PR preview site | The only option that turns paid after a year; cost per GB is 1,000 times worse than CloudFront's free tier | Not on the owner's AWS account (conflicts with D1) |

Not chosen: **CloudFront's flat-rate "Free" plan** (1 M requests, 100 GB). Its docs say accounts using AWS Free Tier are not eligible, it forces a WAF association, and plain pay-as-you-go already gives more free (1 TB, 10 M requests). **Serving from social-grid's Lightsail server** would be ₹0 extra but ties two sites to one 2 GB server and one SSH key; rejected.

### 2.3 Recommendation (D11)

**A, S3 + CloudFront, about ₹1 to ₹2 a month.** It uses the owner's existing AWS account (D1, D24), the always-free tier does not expire at 12 months, and 10x the traffic would still cost nothing for transfer. It is **not ₹0, so it needed the owner's approval, which was given (D11)**. Against the ₹4,300 monthly budget it is noise (social-grid already uses about ₹1,430). It also sits far under the existing `all-projects-monthly` AWS Budget, so no new budget is needed.

**Trade-offs the owner should know:** no PR preview URL (CI posts screenshots and the owner can run `npm run preview` locally), no spend cap, and more setup than Pages. If AWS billing ever worries the owner, C is a half-day move because the output is plain static files.

### 2.4 AWS and DNS setup (D18, D24)

One CloudFormation template, `infra/site.yaml`, reviewed in the PR. The infra build task applies it through the AWS MCP once the owner has approved its `plan.md` and cost (as Social Grid's Lightsail server was created: price approved first), or the owner applies it in the AWS console or CloudShell if the MCP cannot. Everything in **us-east-1**, because CloudFront certificates must live there; the Lightsail server stays in Mumbai and the two do not interact. The first infra step is **read-only**: list what exists in the account (buckets, distributions, certificates, the budget) and the Cloudflare zone's DNS records, so nothing is duplicated or overwritten. The `www` record is added last, after the owner approves the cutover.

| Piece | Setting |
|---|---|
| S3 bucket | Private, block all public access, versioning on, lifecycle deletes old versions after 30 days, only CloudFront reads it (OAC) |
| CloudFront | Alias `www.adhyaanilkumar.com`, HTTP/3 on, redirect HTTP to HTTPS, compression on, default root `index.html`, custom 404 page, price class that includes India |
| CloudFront Function | Rewrites `/projects/ultron/` to `/projects/ultron/index.html` (2 M free invocations a month) |
| Response headers policy | HSTS (start at 1 day, raise after a clean week), `nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, a CSP allowing only `self`, `static.cloudflareinsights.com`, `cloudflareinsights.com`, `challenges.cloudflare.com` and the Lambda URL |
| Cache headers | `/_astro/*` and images: `public, max-age=31536000, immutable`. HTML and the PDF: `no-cache` (revalidate every time) |
| ACM certificate | For `www.adhyaanilkumar.com`, DNS validation. **Check Cloudflare's CAA records allow `amazon.com`**; a blocking CAA record makes ACM fail |
| Cloudflare DNS | `www` CNAME to the `dxxxx.cloudfront.net` name, **DNS only (grey cloud)**; the ACM validation CNAME; three SES DKIM CNAMEs (section 4). Apex: a proxied placeholder record plus a Redirect Rule to `https://www.adhyaanilkumar.com` (free, verify the rule quota when setting up) |
| GitHub OIDC role | Trusts only this repo and the `production` environment. Allowed: `s3:PutObject/DeleteObject/ListBucket` on the one bucket, `cloudfront:CreateInvalidation` on the one distribution. Nothing else |
| Budget alert | Reuse `all-projects-monthly` ($36). It warns at 50% and 80% of actual spend, so it will not notice a ₹2 site cost, only a runaway. Optionally add a second small budget (about $2) for this site if its price allows (check first) |

### 2.5 Deploy flow (D17)

1. **PR opened:** CI runs `make lint`, `make test`, `make build`, builds the PDF, runs the privacy scan, runs the browser checks at 1440x900 and 390x844, and attaches screenshots. Nothing deploys.
2. **Owner reviews and merges.** `main` is protected: PR required, CI green, no direct push.
3. **Deploy job** waits for the owner's approval on the GitHub Environment `production` (required reviewers work on public repos). Then: OIDC login, `aws s3 sync` with the cache headers above, invalidate `/*` (one path; the first 1,000 paths a month are free), read-only smoke test of the live URL.
4. **Rollback:** re-run the deploy for the previous commit (bucket versioning is the second safety net).

---

## 3. Site structure and content

Every sentence on the site must trace to a resume line. The build task writes a fact sheet (claim to resume line) and the owner reviews it with the intro copy.

**Main page `/`**, in this order, one idea per screen (the design skill's rule):
1. **Hero:** name, a one-line intro built only from resume facts (role, city, degree, what is built), the head-and-shoulders photo, GitHub and LinkedIn links, **Download resume** and **Contact** buttons. "Bengaluru, India" appears here (D10).
2. **Timeline:** the three dated entries (D19), newest first, each with org, role, dates, place and its bullets.
3. **Skills:** the five groups as written in the resume.
4. **Projects:** three cards linking to the detail pages.
5. **Contact:** the form (section 4).
6. **Footer:** one line about anonymous visit counts (section 7), no email, no phone.

**Project pages** `/projects/ultron/`, `/projects/social-grid/`, `/projects/sentinel-rag/`: title, stack line, the three resume bullets, a GitHub link and (Social Grid only) the live link to social-grid.dev, plus a back link. Ultron's repository link is the resume's `tree/v0-design` link. Sentinel-RAG keeps the exact result: "GraphRAG beat traditional RAG on 2 of 8 evaluation metrics: Faithfulness and Context Recall".

**Also:** a 404 page, `robots.txt`, `sitemap.xml`, canonical and Open Graph tags (share image from the processed photo), `lang="en"`.

**Socials** are GitHub and LinkedIn only (D30). Nothing else is added.

---

## 4. Contact form (D13)

### 4.1 Options

| Option | Monthly cost | Hides the email? | Spam protection | Privacy | Verdict |
|---|---|---|---|---|---|
| **Lambda Function URL + SES + Turnstile** (AWS) | Lambda: ₹0 (1 M requests and 400,000 GB-seconds a month are always free). SES: $0.10 per 1,000 emails pay-as-you-go, or $0.16 on the new Essentials plan; about 10 messages a month is under ₹1. Turnstile ₹0 | Yes: the address lives only in the Lambda configuration | Turnstile check on the server, a hidden honeypot field, length limits, Lambda concurrency limit of 2, and SES's sandbox cap of 200 messages a day | Messages pass through AWS and are not stored; Turnstile sees the visitor's browser signals | **Recommended** |
| Cloudflare Worker + Email Routing `send_email` | ₹0 | Yes | Turnstile | Same account as DNS | Good alternative; adds a second platform to maintain. Pick it if AWS SES setup proves painful |
| Form service (Web3Forms free: 250 a month; Formspree free: 50 a month, figures from comparison sites, unverified) | ₹0 | Yes, but the address sits in the vendor's dashboard | Vendor's own | A third party stores every message; free terms can change | Simplest, weakest on privacy |
| `mailto:` link | ₹0 | **No** | None | Exposes the address | Rejected (D3) |

### 4.2 Design

- **Browser to Lambda:** the form posts JSON to the Function URL. CORS allows only `https://www.adhyaanilkumar.com`. Fields: name (up to 100 characters), reply-to email (up to 254), message (up to 2,000), a hidden honeypot field, and the Turnstile token.
- **Lambda (Node 22, TypeScript):** reject if the honeypot is filled, any field is over its limit or the email is malformed; call Turnstile's `siteverify` with the secret; strip CR and LF from name and subject so nobody can inject mail headers; send one **plain-text** email with SES `SendEmail`. From `website@adhyaanilkumar.com` (an address on a verified SES domain identity; it only sends, the domain has no mailbox), To the owner, `Reply-To` the visitor. No auto-reply to the visitor (that would let anyone use the site to email strangers).
- **Responses:** 200 sent, 400 invalid, 429 over the limit, 502 if SES fails. On failure the page says "Couldn't send. Message me on LinkedIn instead."
- **Nothing stored.** No database. Logs hold a request id and an outcome code only, never the name, email or message; log retention 14 days.
- **Secrets:** the owner's destination address and the Turnstile secret are set by the owner in the Lambda configuration, never in the repo, template, CI or logs. The Turnstile **site key** is public and goes in the page.
- **SES setup:** verify the domain `adhyaanilkumar.com` (three DKIM CNAMEs at Cloudflare, DNS only; the infra task can add them through the Cloudflare MCP) and verify the destination inbox as an identity (AWS emails a link to that inbox, so **the owner clicks it**). In SES's sandbox you can send to verified addresses, so **no production-access request is needed**. The owner confirmed the domain has **no MX records**, so there is no existing mail setup to disturb; the infra task still lists the zone's records first (read-only) to check for SPF, CAA or DMARC. A DMARC record (`p=none`) is optional.
- **Test mode:** Cloudflare publishes always-pass Turnstile test keys for local and CI runs. Automated tests never send real mail (Lambda tests mock SES and `fetch`; browser tests hit a local stub). The owner does one real end-to-end send after release. This also respects "Gmail is drafts only": no Claude agent sends anything.

---

## 5. Resume pipeline (D5, D6, D14)

**Goal:** the resume the owner last updated is the resume on the site and in the PDF, with no way to ship an old one quietly.

1. **One source in the repo:** `resume/adhya_resume.tex`, the owner's file as it is (the heading email stays, D15). The Overleaf master stays the owner's editing copy. The routine is the owner's decision (D29): copy the `.tex` from Overleaf by hand, run `make resume-sync SRC=<path>`, then open a PR. `resume-sync` copies the file into `resume/`, checks it parses, and **fails if it finds a phone number**. No Overleaf Git sync.
2. **Site data from a sanitised copy:** the build first makes a copy of the `.tex` with the heading's email token and its separator removed (a pattern that matches any `\texttt{...@...}` heading entry, so the address is not written into the build scripts). It **fails if the pattern matches nothing** and **fails if any `@` is left** in the sanitised copy, so a changed heading cannot leak the address. A build step then parses that copy's macros (`\resumeSubheading`, `\resumeItem`, `\resumeProjectHeading`, the Skills lines) into `resume.json`. It turns `\href`, `\textbf`, `\emph`, `--`, `\&`, `\_` into text. An unknown macro or a section it cannot read **fails the build**, so the page cannot silently drift from the resume. The timeline, skills and project pages read only this JSON.
3. **PDF from the same sanitised copy:** `make resume` compiles it with pdflatex in a **pinned TeX Live Docker image** (the tag is chosen in the task and must include FiraMono and tgheros). Same container locally (Docker is installed) and in CI. Output `adhya-anil-kumar-resume.pdf`, with no author or contact metadata. The PDF is built, not committed (no binary churn), and uploaded with the site.
4. **Privacy scan, fail-closed, two rules** (D15). **Phone rule:** any phone-number pattern (for example 10-digit numbers, `+91` forms) in any tracked file, in `dist/`, in `resume.json` or in the PDF text (`pdftotext`) fails the build, including in the two allowed files. **Email rule:** any email address in `dist/`, `resume.json`, the PDF text, or any tracked file **other than** `resume/adhya_resume.tex` and `sdlc/v0/intent.md` fails the build. The allowed files are named by path in the scan's config, so the address is not copied into a third file. The scan also fails on any `x-api-key` value that is not a `${...}` placeholder. Unit tests plant a fake phone (including inside an allowed file), a fake email in another file and in a built page, and a literal API key, to prove each is caught.
5. **Freshness is visible:** the resume section shows "Resume updated <date of the last commit to the `.tex`>". Each release PR template has a box: "I copied the latest Overleaf version into `resume/` before this PR."
6. **Download component:** a button with the file name and size, linking to `/adhya-anil-kumar-resume.pdf` with the `download` attribute and `Content-Type: application/pdf`.

Risk: the manual Overleaf-to-repo copy is the one step a machine cannot check. Item 5 covers it with a visible date and a checklist.

---

## 6. Stack and UI (D12)

### 6.1 Choice

| Option | Fit | Verdict |
|---|---|---|
| **Astro (static) + React islands + Tailwind** | Ships almost no JavaScript by default, one file per page (project pages are trivial), React islands carry 21st.dev components, Tailwind and `components.json` are what the 21st plugin's skills look for. The design skill builds into framework projects and checks `dist/`. | **Pick** |
| Next.js static export | Works with the skill, heavier runtime, more config for a 5-page site | Not needed |
| Vite React single-page app | Familiar from social-grid, but no prerendered pages for link previews and search | Rejected |
| Plain HTML/CSS (the skill's default) | Lightest, but no component reuse and no 21st.dev | Rejected for D1 |

Tooling: Node 22 (the design skill needs Node 22+; 22.16 is installed), npm, TypeScript strict, ESLint and Prettier, `astro check`, Vitest (parser, privacy scan, Lambda), Playwright test runner (browser checks). A Makefile mirrors social-grid: `make build`, `make lint`, `make test`, `make resume`, `make preview`. The first task adds these to CLAUDE.md. `.gitignore` covers `node_modules`, `dist`, `private/` (the original photo) and `.taste-skill/chrome-*`.

### 6.2 21st.dev

React, Tailwind and shadcn-style components. Use it for pieces the design skill does not supply (the timeline, the form, the resume download card). The owner's paid plan covers component code retrieval, so it is used within that plan (D27, section 12).

### 6.3 Using `design-taste-frontend` (D8, D21)

- Kind: **software**, so one effect and one or two dealt moments are allowed. The design pass proposes options (palette, type, hero, moment) and the owner picks; the choice and why go in `plan.md`.
- Gate: its scripts need Chrome or Edge and Node 22+, and run in headless Chrome of their own. The task runs `gate.mjs` against the built `dist` until `GATE: PASS`, and checks 1440, 1024, 820, 768 and 390 widths.
- Constraints that shape the content: one section per screen (the timeline must fit one or two screens), no captions under images, equal left and right edges, 60 to 80 words a screen, contacts only on `.example` (we show none), copy-lint on every page.
- **Overrides for this repo:** no stand-in stock photos and no live photo search (the only photograph is the owner's); project pages use no invented imagery (Social Grid may later use a screenshot the owner supplies); Tailwind is configured from the skill's CSS tokens so there is one visual system.

---

## 7. Analytics (D7)

Cloudflare Web Analytics works on a host that is not proxied by Cloudflare: the owner adds the site's hostname in the Cloudflare dashboard, copies the JavaScript beacon snippet and the build places it before `</body>` (`static.cloudflareinsights.com`, allowed in the CSP). The token is a public identifier. Cloudflare describes it as free, cookie-free and not fingerprinting visitors. The footer carries one line saying so. The automatic injection (no snippet) only exists for proxied sites; we keep `www` DNS-only, so we use the snippet. Cloudflare notes some EU and UK handling differences; at this scale the risk is low, flagged for awareness only.

---

## 8. Photo (D4, D16)

Input: `assets/photo.jpeg`, 3672x4896, about 3.7 MB, EXIF orientation 2 (mirrored). **Never published or modified.** Move it to `private/` (gitignored) or outside the repo; the script reads it from there.

`scripts/process-photo.mjs` (sharp, Node) produces the web files:
1. **Auto-orient** from EXIF (`rotate()` with no arguments also fixes the mirror flag). The owner confirms left-right orientation in the preview.
2. **Crop** to 4:5, a **tight head-and-shoulders** box: cap top to upper chest, centred on the face (D4). From a downsized look, the box is about **x 630 to 2920, y 530 to 3390** in original pixels (about 2290 x 2860). The task confirms it against the real image.
3. **No background removal** (owner decision, D4). A sliver of a neighbour beside the owner's right ear may remain; the owner has accepted that. The task tightens the box as far as the framing allows without cutting the owner's cap or shoulders, and the owner approves the preview.
4. **Resize and compress:** 640x800 and 1280x1600 (never upscale), AVIF (quality about 55), WebP (about 78) and mozjpeg JPEG (about 80). Budget: the 640 file under 100 KB, the 1280 file under 350 KB.
5. **Strip all metadata** (EXIF including any location, camera and date). A test reads the outputs and asserts none remain.
6. Markup: `<picture>` with explicit width and height, `fetchpriority="high"` and no lazy loading in the hero, alt text "Adhya Anil Kumar".

Owner approves the final preview image before the PR can merge.

---

## 9. Requirements

### 9.1 Functional

| ID | Requirement | Acceptance (checked how) |
|---|---|---|
| FR1 | Main page shows name, intro, photo, GitHub and LinkedIn links, resume button, contact form, timeline, skills, projects, "Bengaluru, India" | Playwright at 1440x900 and 390x844 finds each; screenshots reviewed; design gate `GATE: PASS` |
| FR2 | Timeline has exactly the three dated resume entries, newest first, with the resume's bullets | Unit test on `resume.json`; Playwright reads the rendered text and compares |
| FR3 | Each project has a page with title, stack, three bullets and links; project cards link to them | Playwright visits all three; link targets match the resume |
| FR4 | Resume button downloads a PDF built from the repo's `.tex` | Playwright download test; PDF text matches key lines of the `.tex` |
| FR5 | The PDF, `resume.json` and the site contain **no email and no phone**; the repo contains no phone anywhere and the email only in the two allowed files | Privacy scan with its two rules plus tests with planted values; `pdftotext` on the real PDF |
| FR6 | Contact form validates, passes Turnstile, sends one email to the owner and shows success or a clear error | Lambda unit tests (valid, honeypot, bad token, oversize, header injection, SES error, CORS); Playwright against a stub; one owner-run real send |
| FR7 | The owner's email appears nowhere in the page source, JS, network traffic or PDF, and in the repo only in `resume/adhya_resume.tex` and `sdlc/v0/intent.md` | Scan of `dist/`, the PDF and the repo; Playwright network log shows no address |
| FR8 | Photo is a tight head-and-shoulders crop of the owner with metadata stripped (a sliver of a neighbour is accepted, D4) | Owner approves the preview; metadata test; visual check in a real browser |
| FR9 | Every site version ships the latest repo resume, and the build fails on an unreadable or unknown resume macro | Parser tests including a deliberately broken `.tex` |
| FR10 | `www` serves HTTPS; apex redirects to `www`; 404 page works | Post-deploy smoke test (read-only) |
| FR11 | Cloudflare Web Analytics beacon is present and sets no cookies | Playwright checks the script and that `document.cookie` is empty |

### 9.2 Non-functional

| ID | Requirement |
|---|---|
| NFR1 | Monthly cost for the site stays under ₹5 (hosting plus form). Anything paid beyond that stops for approval. |
| NFR2 | First-load transfer of the main page under 1 MB; the skill's `perf.mjs` passes. |
| NFR3 | Keyboard operable, visible focus, labelled form fields, text contrast at least WCAG AA, `prefers-reduced-motion` respected. No horizontal scroll at 320 px width. |
| NFR4 | Third-party requests limited to Cloudflare (beacon, Turnstile) and the Lambda URL; fonts self-hosted. |
| NFR5 | Security headers from section 2.4 present on every response. |
| NFR6 | No secrets in the repo, CI logs, template or client code. The 21st.dev key exists only in the owner's environment variable; `.mcp.json` holds the `${API_KEY_21ST}` placeholder and is gitignored. |
| NFR7 | Builds are reproducible: lockfile committed, TeX Live image tag and action versions pinned. |

### 9.3 Out of scope for V0

Blog or writing, the story project, a dark/light toggle beyond what the chosen design includes, CMS, comments, newsletter, auto-reply emails, storing messages, PR preview sites, WAF, per-IP rate limiting, automatic Overleaf sync, i18n, project pages beyond the resume facts.

---

## 10. Testing strategy (TDD, per CLAUDE.md)

- **Write the test first.** For each bug, commit a failing test, then fix the code.
- **Unit (Vitest):** `.tex` parser (the real resume as a fixture plus broken ones), the sanitiser (fails when the email token is not found or an `@` is left), the privacy scan (both rules, plus the API-key rule), photo-output metadata, the Lambda handler with mocked SES and `fetch`.
- **Browser (Playwright test runner, real Chromium):** the checks in section 9 at 1440x900 and 390x844, console errors, network log (no unexpected hosts), form flow against a local stub, PDF download.
- **Design gate:** the skill's `gate.mjs` on `dist`, to `GATE: PASS`, with its waivers (if any) reviewed in the PR.
- **Post-deploy smoke test:** read-only fetches of `/`, three project pages, the PDF headers, HSTS, the apex redirect and the certificate. No form submissions on production.
- Results (the build, lint and test result lines) are pasted into each task's report.

---

## 11. Cost summary

| Item | Monthly | Needs approval? |
|---|---|---|
| S3 + CloudFront | about ₹1 to ₹2 | **Yes** (non-zero) |
| Lambda | ₹0 | with the form |
| SES | under ₹1 | **Yes** (non-zero) |
| Turnstile, Cloudflare Web Analytics, GitHub Actions on a public repo, ACM, GitHub Environments | ₹0 | No |
| 21st.dev | Paid by a family member; **not counted in the ₹4,300 budget** (D27) | No |
| **Total for this site** | **about ₹2 to ₹3 a month** | |

---

## 12. MCP plan

**Standing permission (D23).** The owner has allowed subagents to use the MCP servers in this table, for this cycle and future cycles, **without asking per call**. Guards that stay on every row: no paid AWS or Cloudflare resource without its monthly INR cost stated and the owner's approval; no deploy to the live domain without the owner's approval; Gmail is drafts only. The spec-writing agent's own use is inspect and research only, and **this spec was written without any AWS, Cloudflare or 21st.dev MCP connected** (concern 7), so nothing live was inspected and nothing was changed. The owner has also decided to copy the three servers' setup from Social Grid into this repo as an early task (D31).

| Stage / agent (rung) | MCP server or tool | Used for | Why / limits |
|---|---|---|---|
| Spec, tasks, plan writers (R2) | WebFetch, WebSearch (built-in, no MCP server) | Public pricing and docs | Public pages only; no account data. Costs in this spec cite them |
| Design pass and UI developer subagents (R2 to R3) | **`design-taste-frontend` skill** (a skill, not an MCP) | Options, build, `gate.mjs` checks at 1440, 1024, 820, 768, 390 | Required by CLAUDE.md for UI work. Its own headless Chrome does the gate. Stand-in photo search is disabled for this site |
| UI developer subagent (R2 to R3) | **21st.dev MCP** (not connected in this repo yet; setup below) | `search`, `get_inspiration` and `get_component` for the timeline, form and download card | React, Tailwind, shadcn-style components. **Queries must be generic**, never resume text or personal data, because the server is third-party. The owner's paid plan covers component code retrieval (D27); AI generation is not on the plan and is not needed; any top-up or overage needs its INR cost stated and the owner's approval |
| Developer and testing subagents (R2 to R3) | **Playwright** (configured globally in `~/.claude.json`) | Browser checks at 1440x900 and 390x844: layout, links, resume download, contact form against the local stub, console errors, network requests | CLAUDE.md requires a real browser for visual criteria. Runs against the local dev or preview server. The test runner (`npx playwright test`) is the repeatable part; the MCP is for looking, screenshots and debugging |
| Testing subagent, after each deploy (R2) | Playwright | Read-only smoke test of the live site, screenshots at both widths | **Never submits the contact form on production** (it would email the owner) |
| Escalation (task fails 3 attempts) | **Atlassian** (`claude_ai_Atlassian_MCP`, v2) | File the failed task in ESC under epic `personal-website V0`, with each attempt's rung and logs | CLAUDE.md Jira rule. The Rovo connector uses a V1 endpoint removed on 2027-03-01, so avoid it |
| Infra task, read-only step (R3) | **AWS MCP** (`aws-mcp`, the official one Social Grid uses) | List what exists in the account: S3 buckets, CloudFront distributions, ACM certificates, IAM roles, the `all-projects-monthly` budget, the SES identities; confirm the account's plan | Avoids duplicating or clobbering Social Grid's resources. No writes in this step |
| Infra task, read-only step (R3) | **Cloudflare MCP** (official) | List the `adhyaanilkumar.com` zone's DNS records (existing MX, SPF, CAA, any old `www`), check whether Web Analytics is already enabled, check the API token's scope | Settles the CAA, MX and apex questions in sections 2.4 and 4 before anything is added |
| Infra task, write step (R3 or higher) | **AWS MCP** and **Cloudflare MCP** | Apply `infra/site.yaml` (bucket, distribution, function, role, Lambda, SES identities) and add the ACM validation and SES DKIM records | Only what the task's `plan.md` lists, each with its INR cost; nothing paid without approval; no long-lived keys; **the `www` record that points the live domain at CloudFront waits for the owner's OK** (D18). Social Grid created its server this way |
| Release (deploy) | **AWS MCP** (read), GitHub Actions (write) | Post-deploy checks: distribution status, certificate, last invalidation | The deploy itself is the approved GitHub Actions job, not an MCP |
| Analytics setup (R2) | **Cloudflare MCP**, else dashboard clicks | Create the Web Analytics site for `www.adhyaanilkumar.com` and read back its beacon token (public) | If the MCP cannot reach Web Analytics, the owner clicks it in the dashboard |
| Resume, contact-form code tasks (R3 or higher) | None beyond the rows above (no Gmail) | Code and tests only | These score risk 2 (security, personal data, public), so rungs.md puts them at R3 or higher. Tests never send real mail |
| Maintain | none | | |

**MCP setup task (D31, early, before the infra task).** Social Grid configures its servers in two ways, and this repo copies both:
- **AWS and Cloudflare:** HTTP servers in Claude Code's local scope, stored in `~/.claude.json`, signed in by OAuth, so **no key or token is in any repo file**. Add the same two to this repo's folder: `claude mcp add --transport http aws-mcp https://aws-mcp.ap-southeast-1.api.aws/mcp` and `claude mcp add --transport http cloudflare https://mcp.cloudflare.com/mcp` (or copy the entries from Social Grid's section of `~/.claude.json`), then sign in and check `/mcp`. **The owner checks the Cloudflare token's scope**: it should cover only the `adhyaanilkumar.com` zone's DNS and Web Analytics. The infra task starts with read-only calls to confirm what each server can do; if a call is refused for lack of permission, it gives the owner the console steps and does not ask for broader keys.
- **21st.dev:** a `.mcp.json` in this repo's root, **gitignored** like Social Grid's, with `"type": "http"`, `"url": "https://21st.dev/api/mcp"` and a header `"x-api-key": "${API_KEY_21ST}"`. The real key stays in the owner's Windows user environment variable `API_KEY_21ST`, which Social Grid already uses. The task commits a `.mcp.example.json` with the same placeholder (no secret) so a fresh clone knows what to create, and the privacy scan refuses any literal `x-api-key` value. The task also checks no project file contains the key.

Alternative to the `.mcp.json` entry: the 21st plugin (`/plugin marketplace add 21st-dev/claude-code-plugin`, `/plugin install 21st@21st`, key in `API_KEY_21ST`). Its skills activate when the project has a `components.json`, so the first build task creates one.

Considered and not used: **claude-in-chrome** (Playwright covers it), **Google Drive, Notion, Slack, Crunchbase, Calendar** (no use), **GitHub MCP** (`gh` does the job, as in Social Grid), **Gmail** (drafts only, and the site needs none).

Suggested starting rungs (final scores go in `tasks.md`): tasks and plan writers R2; the pipeline (resume parser, privacy scan, deploy workflow), the Lambda, the CloudFormation template and any AWS or Cloudflare write step R3; UI build tasks R2 to R3 by score.

---

## 13. Areas of concern

| # | Risk | Likelihood / impact | Mitigation |
|---|---|---|---|
| R1 | **Email or phone leaks** beyond what the owner chose (D15): into the page, scripts, PDF, logs, another tracked file, or a phone number anywhere | Medium / high | Sanitised build copy drops the email line and the sanitiser fails if it cannot find it; fail-closed privacy scan (phone anywhere; email anywhere except the two allowed files) on tracked files, `dist/` and PDF text. Accepted by the owner: the address is in the public repo (concern 1) |
| R2 | **Original photo published**, showing many other people | Low / high | Original kept out of the repo (`private/` gitignored); only processed outputs under `public/images/`; owner approves the preview; metadata test. The tight crop may keep a sliver of a neighbour, which the owner accepts (D4) |
| R3 | **Contact-form spam or abuse** | Medium / low | Turnstile verified server-side, honeypot, length limits, concurrency 2, SES sandbox cap 200 a day, no auto-reply, no stored data |
| R4 | **Surprise AWS bill** (no hard cap) | Low / low to medium | Always-free 1 TB covers about 10x the assumed traffic; page weight budget; the existing all-projects budget alert; Lambda concurrency cap; fallback to Pages |
| R5 | **AWS changes its free-tier terms** (for example, withdraws CloudFront's always-free allowance) | Low / low | Cost recheck at each release; NFR1 stops anything over ₹5; Cloudflare Pages is the ₹0 fallback. Amplify, whose free tier expires after 12 months, is not chosen |
| R6 | **AWS changes its pricing or free tier** (SES changed in July 2026) | Medium / low | Cost recheck at each release; NFR1 stops anything over ₹5 |
| R7 | **Stale resume** because the Overleaf copy step is manual | Medium / medium | Visible "updated" date, PR checklist, build fails on parse problems |
| R8 | **pdflatex build differs** between machines | Low / medium | Pinned container image, same locally and in CI; a test compiles the current resume |
| R9 | **Two styling systems** (skill kit and Tailwind) clash | Medium / medium | Tailwind from the skill's tokens; the skill's gate is the final judge |
| R10 | **Thin project pages look empty** | High / low | Accepted by the owner (D20); the design pass makes short pages look intentional. No invented content |
| R11 | **A personal detail beyond the owner's approvals gets published** | Low / medium | Only resume facts; the fact sheet is reviewed by the owner; the Apple | Adecco and Radar lines are approved (D28) |
| R12 | **Bad certificate, CAA or DNS setup** takes the site down | Low / medium | Runbook with a checklist; `www` is new so nothing live is disturbed; SES DNS records are additive |
| R13 | **21st.dev usage beyond the paid plan** adds cost | Low / low | The owner's plan covers code retrieval (AI generation is not on it); any top-up or overage needs its INR cost stated and the owner's approval |
| R14 | **No PR preview site** means the owner reviews less visually | Medium / low | CI screenshots at both widths attached to the PR, `npm run preview` locally |

---

## 14. Open items for the owner

The owner approved the spec as a whole on 2026-11-24, and every earlier open item is answered and recorded as a decision above. One item stays open:

1. **Look and feel** (D8): the design pass brings options and the owner picks. Not a blocker for building the non-visual tasks.

**Owner actions already agreed, listed so they are not forgotten:** click the SES verification link AWS emails to the destination inbox (D13); check the Cloudflare token's scope (D31); keep `API_KEY_21ST` set in the Windows user environment (D27).

---

## 15. Sources (checked 2026-11-24)

- CloudFront pay-as-you-go, always-free tier and India rates: https://aws.amazon.com/cloudfront/pricing/pay-as-you-go
- CloudFront flat-rate plans (Free plan limits, WAF requirement, Free Tier exclusion): https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/flat-rate-pricing-plan.html
- Amplify Hosting pricing (12-month free tier, per-GB rates): https://aws.amazon.com/amplify/pricing/
- Lambda pricing (always-free 1 M requests, 400,000 GB-seconds): https://aws.amazon.com/lambda/pricing/
- SES pricing and plans (2026-07 change): https://aws.amazon.com/ses/pricing/ and https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ses-pricing-plans/
- S3 pricing (Mumbai rates not readable; estimate only): https://aws.amazon.com/s3/pricing/
- Cloudflare Pages limits: https://developers.cloudflare.com/pages/platform/limits/ and https://www.cloudflare.com/developer-platform/pages/
- Cloudflare Web Analytics setup and privacy: https://developers.cloudflare.com/web-analytics/get-started/ and https://blog.cloudflare.com/privacy-first-web-analytics
- Cloudflare Turnstile plans: https://developers.cloudflare.com/turnstile/plans
- Form services (comparison sites, unverified): https://splitforms.com/blog/best-free-form-backend-services-2026
- 21st.dev MCP and plugin: https://github.com/21st-dev/magic-mcp and https://github.com/21st-dev/claude-code-plugin
- Exchange rate: https://www.ofx.com/en-us/exchange-rates/inr/ (94.12 on 2026-10-21); social-grid `sdlc/v0/deploy-plan.md` (94.6 on 2026-11-07, 18% GST)
- Social Grid's AWS setup (account, Budget, `production` environment, branch protection, MCP use): `C:\git\social-grid\sdlc\v0\deploy-plan.md` and `maintain-plan.md`; MCP servers in `~/.claude.json` (social-grid project scope) and `C:\git\social-grid\.mcp.json` (gitignored there; `${API_KEY_21ST}` placeholder), and Social Grid's memory note `21st-dev-mcp-setup`
- Reference formats: `C:\git\social-grid\sdlc\v1\spec.md`, `C:\git\friday\sdlc\v0\spec.md`
