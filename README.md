![dbt CI](https://github.com/JumpyB/github-pulse/actions/workflows/ci.yml/badge.svg)

# GitHub Open Source Pulse

An end-to-end analytics pipeline on the GitHub Archive public dataset —
and a case study in detecting and diagnosing upstream data degradation.

**Stack**: BigQuery · dbt Core · dbt Semantic Layer · GitHub Actions · Looker Studio

## Live Dashboard

🔗 [View Dashboard](https://datastudio.google.com/reporting/103ac1bd-8de4-47a9-b259-0d34040464fb)

![GitHub Pulse Dashboard](docs/images/dashboard.png)

> **⚠️ On the star figures**: This dashboard refreshes daily, and current
> star counts are a tiny fraction of historical levels. This reflects
> upstream capture degradation, not a pipeline defect — see
> [Upstream Coverage Degradation](#upstream-coverage-degradation) for the
> full investigation.

## Architecture

```
GH Archive (BigQuery public dataset)
        ↓
Staging (dbt views, deduplicated)
        ↓
Dims: dim_repo (SCD Type 2) · dim_actor · dim_date
        ↓
Facts: fct_pull_requests · fct_repo_engagement · fct_repo_lifecycle
        ↓
Semantic Layer (10 metrics) → Looker Studio
```

![dbt Lineage Graph](docs/images/lineage.png)

## What's Here

| Layer | Contents |
|---|---|
| Staging | 4 models, 1:1 with source event types, deduplicated via `QUALIFY ROW_NUMBER()` |
| Dimensions | `dim_repo` (SCD Type 2 via snapshot), `dim_actor` (Type 1), `dim_date` |
| Facts | 3 tables in a constellation schema sharing conformed dimensions |
| Semantic Layer | 10 metrics — merge rate, label velocity, branch net growth |
| Tests | 54 data tests across sources, staging, and marts |
| Orchestration | GitHub Actions — CI on every push, daily refresh via cron |
| Docs | dbt docs with full lineage, published to GitHub Pages |

## Upstream Coverage Degradation

The most substantive finding in this project came from investigating why
dashboard metrics collapsed, and it took three rounds of self-correction.

### The observation

Star events recorded per day:

| Date | WatchEvents | Total events | PushEvent share |
|---|---|---|---|
| 2025-01-15 | 211,526 | 5,307,607 | 62.7% |
| 2025-04-15 | **218,621** | 5,634,352 | 62.2% |
| 2025-05-15 | 207,879 | 5,547,296 | 61.7% |
| 2025-07-15 | 172,465 | 3,810,192 | 60.4% |
| 2025-10-15 | 91,091 | 3,465,925 | 68.0% |
| 2026-04-28 | 27,015 | 3,658,498 | 77.4% |
| 2026-07-31 | **738** | 4,013,080 | 95.5% |

Against the 2025-04 baseline, capture has fallen to **0.34%**.

### Correction 1 — the timeline

I initially dated the degradation to May 2026, based on the two dates I
had measured. GH Archive's own issue tracker documents it starting around
**June 2025**, verified against GitHub's stargazers API as ground truth:
capture fell from a 95–100% baseline to under 20% during 2026.

My 2026-04 figure of 27,015 was never a baseline — it was already ~12% of
true activity.

### Correction 2 — the magnitude

Querying back into 2025 established the real baseline at ~215,000
WatchEvents/day. The actual decline is from 218,621 to 738, not from
27,015 to 738. My original estimate understated it by an order of
magnitude.

### Correction 3 — the causal direction

I hypothesized that automation traffic was crowding out other event types,
citing PushEvent share rising from 77% to 95.5%. **The timeline rules this
out.** When degradation began in mid-2025, push share was *falling* —
62.7% → 62.2% → 61.7%. It only rose past 68% in late 2025, months after
the onset.

Push share increasing is a *consequence* of other event types being
dropped, not a cause. I had the causal arrow backwards.

The actual onset coincides with total captured volume falling 32%
(5.63M → 3.81M) in mid-2025, with WatchEvent discarded at a far higher
rate than PushEvent.

### What I verified independently

- **Thirteen unrelated event types declined by an almost identical ≈96%.**
  Wiki edits, forks, releases, and starring have no shared real-world
  driver that would move them at the same rate — uniformity across
  unrelated categories is the signature of sampling.
- **The hourly distribution flattened.** April 2026 showed a 5×
  peak-to-trough diurnal swing; July 2026 was nearly flat (12–76/hour).
  Genuine global developer activity always has a day/night cycle.

### What I could not verify

Independent verification against GitHub's own per-day star counts proved
impractical: the stargazers endpoint requires authentication, and
pagination caps at 400 pages, placing recent stars on any repo above
~40,000 total out of reach. The confirmation above comes from GH Archive's
issue tracker, where another contributor completed this comparison.

### Implication

PushEvent data remains complete — 3,831,460 rows on 2026-07-31 with zero
duplicate IDs. Push-based metrics are reliable. Engagement and PR metrics
are directional only, and the dashboard reflects this.

## Data Caveats

- **Payload simplification is selective, not uniform.** `PullRequestEvent`
  payloads are stripped to ~500 characters — no title, author, state, or
  line counts — so merge detection uses the top-level `action` field
  rather than the nested `pull_request.merged`. But
  `PullRequestReviewEvent` payloads remain complete at ~2,000 characters
  with `review.state` populated. The cuts appear driven by object size
  (a PR object embeds two full repository objects) rather than by event
  category.
- **PushEvent payloads carry only five fields** — `repository_id`,
  `push_id`, `ref`, `head`, `before`. No `commits[]` array or `size`,
  so commit-level analysis is impossible; push-level activity is
  countable.
- **GH Archive uses at-least-once delivery.** Duplicate event IDs appear
  in the source. All staging models deduplicate via
  `QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY created_at) = 1`.
  The source-level uniqueness test is retained as a non-blocking monitor
  rather than removed — it tracks upstream quality without failing runs
  over a known condition.
- **`WatchEvent` means starring**, not watching — legacy naming in the
  GitHub Events API.

## Push Concentration

While investigating the degradation, the push data yielded a separate
finding. Bucketing repositories by daily push volume on 2026-07-31:

| Tier | Repos | Pushes | Share of all pushes |
|---|---|---|---|
| 1000+ | 24 | 49,521 | 1.3% |
| 100–999 | 13,214 | 2,579,390 | **67.3%** |
| 10–99 | 13,969 | 521,507 | 13.6% |
| 1–9 | 424,720 | 681,042 | 17.8% |

**2.9% of active repositories generate 67.3% of all pushes.**

The extreme outliers turned out not to matter — the top tier, including
repos pushing 6,791 times a day (one commit every 13 seconds), accounts
for only 1.3% of traffic. The mass sits in the 100–999 tier: sustained
rates of 4–40 pushes per hour that no individual developer produces.

Percentile distribution supports the threshold: p50 = 1, p90 = 4,
p95 = 17, p99 = 194. The 11× jump between p95 and p99 marks where the
distribution breaks.

## Models

```
models/
├── staging/                    # 1:1 with source event types, deduplicated
│   ├── stg_github__pull_request_events.sql
│   ├── stg_github__watch_events.sql
│   ├── stg_github__create_events.sql
│   └── stg_github__delete_events.sql
└── marts/
    ├── core/                   # Conformed dimensions
    │   ├── dim_date.sql
    │   ├── dim_actor.sql
    │   ├── dim_repo.sql        # SCD Type 2 via snapshot
    │   └── metricflow_time_spine.sql
    ├── pull_requests/
    │   └── fct_pull_requests.sql
    ├── engagement/
    │   └── fct_repo_engagement.sql
    └── lifecycle/
        └── fct_repo_lifecycle.sql

snapshots/
└── snap_repos.sql              # SCD Type 2 change tracking
```

## Setup

```bash
uv add dbt-bigquery
uv run dbt deps

# Configure ~/.dbt/profiles.yml with your GCP project

uv run dbt snapshot
uv run dbt run
uv run dbt test
```

Run against a specific date:

```bash
uv run dbt run --vars '{"default_event_date": "2025-04-15"}'
```