# ADR-0009: Terraform state backend — S3 only, no DynamoDB

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Terraform 1.10+ supports native S3 object-based state locking via `use_lockfile = true`, removing the long-standing need for a companion DynamoDB lock table.

## Decision

Use **S3 only** as the Terraform state backend. Enable `use_lockfile = true` so concurrent `apply` is serialised by an S3 lockfile. No DynamoDB table is provisioned for locking. State buckets are versioned, encrypted with the default AWS-managed key, public-block on. One state bucket per AWS account.

## Consequences

- One fewer resource type to provision, monitor, and pay for.
- Requires Terraform ≥ 1.10 on developer machines and CI runners — pinned in CI and pre-commit.
- Stale locks are visible directly as S3 objects (easier to inspect than DynamoDB items).

## Alternatives considered

- **S3 + DynamoDB lock table** — the historical pattern; rejected because S3-native locking is now the default upstream guidance.
- **Terraform Cloud / HCP** — adds external dependency and cost; not justified at v0.
