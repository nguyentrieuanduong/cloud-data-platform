# ADR-0013: Glue VPC attachment — `NETWORK` connections, no JDBC connections

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Glue jobs that batch-ingest from on-prem databases must reach those databases over the existing VPN. Glue jobs running in the AWS-managed network have no VPC route to on-prem; only jobs whose `connections` list contains a Glue `NETWORK`-type connection get ENIs attached in the VPC.

Separately, the team wants the job script to own the JDBC URL, driver, and credentials (from Secrets Manager) — not let Glue auto-build a connection.

## Decision

The `ingestion-glue` module provisions one `aws_glue_connection` of type **`NETWORK`** per private subnet, each referencing the subnet ID and a dedicated SG. Jobs that need on-prem reachability list the matching connection name in their `connections` argument. Jobs that read/write S3 only do not declare any connection.

**No JDBC-type Glue connections are created.** The script handles connection setup itself.

## Consequences

- Clean separation: Glue handles VPC attachment, the script handles the database protocol.
- One NETWORK connection per AZ lets Glue distribute ENIs across AZs for HA.
- A typo in the `connections` list silently disables VPC attachment for that job — caught at smoke-test time, not at plan time.
- Removing or renaming a subnet requires re-creating the matching NETWORK connection and updating dependent jobs.

## Alternatives considered

- **No Glue connection at all** — initially proposed; rejected when the team confirmed on-prem reachability is required. Without a NETWORK connection Glue ENIs land in AWS-managed networking with no route to on-prem.
- **JDBC-type Glue connections** — would let Glue auto-build the database client; rejected because we want script-owned connection details for portability and credential handling.
