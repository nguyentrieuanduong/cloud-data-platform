# ADR-0001: IaC stack — Terraform + Terragrunt

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

We need an IaC stack that supports the stated multi-cloud roadmap (AWS today, Azure / GCP later) and lets us cleanly separate state per environment and per module. The team is small and we want to avoid hand-rolling environment scaffolding.

## Decision

Use **Terraform (HCL)** for all infrastructure modules, and **Terragrunt** to compose environments and centralise backend configuration. Modules live under `modules/<cloud>/<name>/`; environments under `envs/<env>/<region>/<stack>/`.

## Consequences

- Multi-cloud is supported natively by Terraform providers; no rewrite is forced if we add Azure or GCP.
- Terragrunt's `remote_state` and `generate` blocks keep backend and provider config DRY without copy-pasting per env.
- Per-stack state isolation limits blast radius and parallelises plan/apply.
- Adds a second tool (Terragrunt) to install on dev machines and in CI; mitigated by pinning the version in pre-commit / CI.

## Alternatives considered

- **Plain Terraform with workspaces** — rejected: workspaces don't cleanly separate state across stacks, and provider config duplication grows quickly.
- **AWS CDK** — rejected: AWS-only, undermines the multi-cloud goal.
- **Pulumi** — viable, but the team is more familiar with HCL and the AWS provider is more battle-tested for this surface area.
