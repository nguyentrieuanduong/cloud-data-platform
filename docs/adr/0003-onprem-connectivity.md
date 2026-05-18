# ADR-0003: On-prem connectivity — consume externally-managed VPN/DX

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Ingestion needs to reach on-prem databases and Kafka. A Site-to-Site VPN / DirectConnect is already configured manually by the network team and is out of scope for this repo.

## Decision

This repo **does not provision** any VPN, DX, Customer Gateway, or Transit Gateway resources. It **consumes** the existing path:

- `_common` exposes `on_prem_cidrs` (list), `transit_gateway_id` (or `vgw_id`).
- The `network` module adds routes to those CIDRs via the supplied gateway attachment ID.
- Workload SGs allow egress only to those CIDRs on declared DB ports.

## Consequences

- Operational dependency on the network team to keep the tunnel up; this repo cannot self-recover from a tunnel outage.
- Per-env CIDR variables are mandatory and must be reviewed when promoting from uat to prod.
- A future move to provisioning the tunnel here can be done by adding resources without restructuring downstream modules.

## Alternatives considered

- **On-prem push to S3 over internet** — would invert the data flow; rejected because Glue and DMS need to pull from on-prem.
- **Provision VPN here** — rejected: contractually owned by the network team, and AWS Site-to-Site VPN requires symmetric config on the on-prem device.
