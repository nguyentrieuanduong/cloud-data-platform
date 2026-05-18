# ADR-0012: Encryption — AWS-managed default KMS keys at v0

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Every at-rest service in our stack (S3, RDS, Redshift, Secrets Manager, MWAA, CloudWatch Logs) supports encryption. The choice is between AWS-managed default keys (`aws/<service>`) and customer-managed CMKs.

## Decision

Use **AWS-managed default keys** at v0. No customer-managed CMKs are provisioned by this repo.

## Consequences

- Simpler IAM — no key policy authoring or cross-account key grants.
- No KMS request cost.
- We give up the ability to revoke per-resource encryption or audit per-key usage. Cross-account share of encrypted resources is also limited.
- Migrating to CMKs later is non-trivial for some services (S3 buckets can re-key via batch operations; Redshift cluster re-key is offline).

## Alternatives considered

- **CMK per data domain (lake / warehouse / ops / logs)** — recommended baseline at scale; deferred to a future ADR triggered by regulatory or audit requirement.
