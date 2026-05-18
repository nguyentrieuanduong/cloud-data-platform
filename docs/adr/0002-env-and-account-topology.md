# ADR-0002: Environment & account topology — uat + prod in separate AWS accounts

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

We need somewhere safe to test infrastructure changes before they reach production data. The other team's landing zone already supports per-environment accounts under AWS Organizations.

## Decision

Two environments at v0: **`uat`** and **`prod`**, each in its **own AWS account**. Both deploy to `ap-southeast-1`. Environment names appear in `<org>-<dep>-<env>-<region>-<resource>` resource names.

## Consequences

- Strong blast-radius isolation: a faulty IAM policy or DMS task in uat cannot reach prod data.
- Per-account state buckets and OIDC deploy roles. CI uses different AWS roles per env.
- `dev` can be added later if local Terraform iteration becomes insufficient — the env folder pattern makes this cheap.

## Alternatives considered

- **dev + staging + prod** — rejected for v0: small team, more accounts to maintain than value gained at this stage.
- **Single account, env-prefixed resources** — rejected: weak isolation, hard to grant least-privilege per env.
