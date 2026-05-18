# ADR-0008: Subnet design — 1 public + 2 private, no isolated tier

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

The proxy and the internal apt/pip mirror are singletons owned by another team and live outside this VPC. Internet egress for our workloads always flows through that external proxy. Nothing in our workload set requires inbound from the internet at v0.

## Decision

Each env's VPC contains:

- **1 public subnet** (single AZ) — minimal; exists only because an IGW must be attached and we may need a reserved space for future public-facing helpers.
- **2 private subnets** (2 AZs) — host MWAA, Lambda ENIs, EC2 (cube.js, BI), DMS, RDS, Redshift, and Glue ENIs (via `NETWORK` connection).

No separate "isolated" tier for Redshift — its security comes from SGs, VPC endpoints, and no IGW route in the private route table.

## Consequences

- Lower IP-range fragmentation and simpler route tables.
- MWAA HA requirement (≥2 AZs of workers) is satisfied by the 2 private subnets.
- Single public subnet is single-AZ — acceptable because nothing critical runs there.

## Alternatives considered

- **2 public subnets across 2 AZs** — wasted address space; we run nothing critical in public.
- **Separate isolated subnets for Redshift** — over-engineered at v0; SGs + no IGW route already isolate Redshift.
