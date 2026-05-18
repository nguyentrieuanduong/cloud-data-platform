# ADR-0011: Scheduling — MWAA only, no EventBridge cron

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Lambda ingestion jobs, Glue jobs, DMS tasks, and dbt runs all need scheduling. AWS offers both EventBridge rules and MWAA-driven DAGs.

## Decision

**MWAA is the sole scheduler.** DAGs trigger Lambda (`boto3 lambda.invoke`), Glue (`StartJobRun`), DMS (`StartReplicationTask`), and Redshift dbt (Redshift Data API). The Terraform modules expose no `aws_cloudwatch_event_rule` or `aws_cloudwatch_event_target` resources for scheduling.

## Consequences

- Single pane of glass for runtime, retries, dependencies, and run history.
- Cross-job dependencies (Lambda → Glue → dbt) are first-class in Airflow.
- MWAA becomes a critical dependency for ingestion freshness — alarms and backup paths required.
- No race between EventBridge and Airflow triggering the same job.

## Alternatives considered

- **EventBridge for Lambda, MWAA for everything else** — splits operational view across two systems with no clear win.
- **EventBridge Scheduler with Step Functions** — viable, but the team picked Airflow as the orchestrator and we should not duplicate.
