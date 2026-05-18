# ADR-0005: DMS CDC routing — per-source target (Redshift or RDS)

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

We need CDC from on-prem databases for two distinct use cases: analytical tables in the warehouse and an operational mirror for tooling/queries that should not hit Redshift.

## Decision

A single **DMS replication instance** in the private subnets hosts multiple tasks. Each task declares its target via a module input: **`target = redshift`** or **`target = rds`**. The DMS module exposes a per-task wrapper accepting the source endpoint, target type, and table-mapping rules.

## Consequences

- One replication instance to size and monitor; tasks scale independently.
- Operational and analytical mirrors stay in lock-step with the same DMS engine; differences are pure routing.
- Mis-routing is a config bug, not an architectural one, and is detectable at PR review.

## Alternatives considered

- **DMS → Redshift only, downstream job mirrors to RDS** — adds latency and a separate failure surface for the operational mirror.
- **DMS → RDS only, downstream job loads Redshift** — increases lag to warehouse; tooling already-good DMS-to-Redshift integration is wasted.
- **Fan-out (single task writes both)** — DMS does not natively dual-write; would require Kinesis or custom plumbing.
