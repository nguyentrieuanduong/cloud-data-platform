# ADR-0004: Warehouse engine — Redshift RA3 multi-AZ provisioned

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

The curated DWH layer needs predictable performance for dbt-driven transforms and BI workloads (cube.js, PowerBI, SSRS), plus Spectrum access to the Glue catalog for raw-zone data.

## Decision

Provision a **Redshift RA3 multi-AZ cluster** (managed storage; node size chosen at module-instantiation time). Spectrum is enabled and bound to the Glue Data Catalog via an external schema.

## Consequences

- Predictable cost at steady load; finer-grained tuning (WLM, sort/dist keys) than Serverless.
- Multi-AZ gives automatic failover for the warehouse.
- Capacity-planning overhead: we have to size and scale nodes proactively.

## Alternatives considered

- **Redshift Serverless** — simpler bootstrap and good for spiky workloads, but cost becomes unpredictable at steady dbt-driven load and some advanced features lag the provisioned engine.
- **Single-AZ provisioned** — cheaper, but HA is a stated goal.
