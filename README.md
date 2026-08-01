![dbt CI](https://github.com/JumpyB/github-pulse/actions/workflows/ci.yml/badge.svg)

# GitHub Open Source Pulse

End-to-end analytics pipeline tracking the daily pulse of open source —
pull request throughput, merge rate, and trending repositories.

## Live Dashboard

🔗 [View Dashboard](https://datastudio.google.com/reporting/103ac1bd-8de4-47a9-b259-0d34040464fb)

![GitHub Pulse Dashboard](docs/images/dashboard.png)

> **⚠️ Note on star volume**: This dashboard is live and refreshes daily, so
> current star counts will look far smaller than the figures cited below.
> This is upstream data degradation, not a pipeline defect — see
> [Upstream Coverage Degradation](#upstream-coverage-degradation).

## Architecture
```
GH Archive (BigQuery public dataset)
↓
Staging (dbt views, deduped)
↓
Dims: dim_repo (SCD2) · dim_actor · dim_date
↓
Facts: fct_pull_requests · fct_repo_engagement · fct_repo_lifecycle
↓
Looker Studio Dashboard
```
## Lineage Graph

![dbt Lineage Graph](docs/images/lineage.png)

## Stack

| Layer | Tool |
|---|---|
| Source | GitHub Archive (BigQuery public dataset) |
| Warehouse | BigQuery |
| Transformation | dbt Core 1.11 + dbt-utils |
| Orchestration | GitHub Actions (coming soon) |
| BI | Looker Studio |
| IaC | Terraform (stretch) |

## Key Findings

- **27,015 stars** recorded on 2026-04-28
- Top trending repo: `mattpocock/skills` (497 stars) — reflecting the AI agent skills ecosystem
- Star activity peaks at **2-6AM UTC** (Asia/Europe overlap) and dips mid-day UTC
- **6 of top 10** trending repos are AI agent / Claude skills related — capturing the 2026 open source zeitgeist
- Discovered GH Archive uses at-least-once delivery: 2 duplicate event IDs in source,
  handled via `QUALIFY ROW_NUMBER()` deduplication in all staging models

## Data Caveats

- PR payload simplified in GH Archive 2026: `additions`, `deletions`, `merged` (nested) are NULL
  → merge detection uses top-level `action = 'merged'` instead
- PushEvent payload omits `size` and `commits[]` array → commit-level analysis not possible
- WatchEvent = starring (legacy naming from GitHub API)

### Upstream Coverage Degradation

Between May and July 2026, GH Archive's non-push event volume fell ~97% while
total daily event count held flat (3.7M → 4.0M).

| Event type | 2026-04-28 | 2026-07-31 | Change |
|---|---|---|---|
| PushEvent | 2,832,008 | 3,831,460 | **+35%** |
| PullRequestEvent | 97,872 | 3,825 | −96.1% |
| WatchEvent | 27,015 | 738 | −97.3% |
| IssuesEvent | 36,810 | 1,369 | −96.3% |
| ForkEvent | 5,975 | 198 | −96.7% |

**Root cause**: collector-side sampling under a fixed capacity ceiling.
Fifteen unrelated event types declined by an almost identical ≈96% — a
uniformity that rules out any GitHub API policy change, since wiki edits and
forks would not fall at the same rate as starring. Over the same period
PushEvent share rose from 77% to 95.5%.

Inspecting the top PushEvent repositories confirms it: the highest-volume
repos are automation bots using git as a datastore — `er-forge-probe`
(6,791 pushes/day), `email-probe` (5,323), `conda-forge-bot-data` (1,257).
At 6,791 pushes/day that is one commit every 13 seconds. This traffic
saturates the collector and crowds every other event type down to a ~3%
retention rate.

PushEvent data remains complete (3,831,460 rows, zero duplicate IDs), so
push-based metrics stay reliable. Engagement metrics remain directionally
useful but are no longer volumetrically representative.

## Models

```
models/
├── staging/                    # 1:1 with source event types, deduped
│   ├── stg_github__pull_request_events.sql
│   ├── stg_github__watch_events.sql
│   ├── stg_github__create_events.sql
│   └── stg_github__delete_events.sql
└── marts/
    ├── core/                   # Shared dimensions
    │   ├── dim_date.sql
    │   ├── dim_actor.sql
    │   └── dim_repo.sql        # SCD Type 2 via snapshot
    ├── pull_requests/
    │   └── fct_pull_requests.sql
    ├── engagement/
    │   └── fct_repo_engagement.sql
    └── lifecycle/
        └── fct_repo_lifecycle.sql

snapshots/
└── snap_repos.sql              # SCD Type 2 tracking
```

## Setup

```bash
# Install dependencies
uv add dbt-bigquery
uv run dbt deps

# Configure BigQuery credentials
# Copy profiles.yml.example to ~/.dbt/profiles.yml and fill in your GCP project

# Run pipeline
uv run dbt snapshot
uv run dbt run
uv run dbt test
```