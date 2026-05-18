# ADR-0006: MWAA webserver — public endpoint with IAM Identity Center auth

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Engineers and data ops need access to the Airflow UI to inspect DAG runs. The VPN to on-prem is owned by another team and is not intended as a general-purpose UI access path.

## Decision

Use MWAA's **public webserver** access mode, with **IAM Identity Center (SSO)** as the authentication source. Workers and the scheduler remain in private subnets.

## Consequences

- No VPN dependency for Airflow UI access; SSO handles authentication centrally.
- The webserver endpoint is exposed to the internet; mitigated by IAM auth (no anonymous access) and CloudTrail/Login auditing.
- Permission sets in Identity Center must be maintained per env account.

## Alternatives considered

- **Private webserver** — requires users to be on the VPN; rejected because VPN is not intended for UI access.
- **Private webserver + AWS Client VPN** — adds another network path to maintain just for Airflow; not worth it at v0.
