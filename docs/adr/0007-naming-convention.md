# ADR-0007: Resource naming convention

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Resource names need to be predictable, unique across env/region, and clearly indicate ownership when seen in logs, console searches, and IAM policies.

## Decision

Resource names follow **`<org>-<dep>-<env>-<region>-<resource>`**.

- `org = "vpbs"` (constant for this repo)
- `dep = "eda"` (constant for this repo)
- `env ∈ { "uat", "prod" }`
- `region` uses short codes: `apse1` for `ap-southeast-1`
- `resource` is the resource-specific suffix, e.g. `raw-bucket`, `mwaa-env`, `redshift-cluster`

Example: `vpbs-eda-prod-apse1-raw-bucket`.

The `org`, `dep`, and `region` short-code are sourced from `envs/_common/` locals so that downstream renames are a single-place change.

## Consequences

- Easy to grep across accounts; collision-free per AWS resource type.
- S3 bucket names stay within the 63-char DNS limit for typical suffixes.
- Cross-cloud port: replace `<org>-<dep>-<env>` with the same locals; only the region short-code differs.

## Alternatives considered

- **Random suffixes** — rejected: harder to reason about in logs and IAM policy resource ARNs.
- **Dropping `org` / `dep`** — rejected: prevents reuse of names in shared accounts when other teams pick the same `env` suffix.
