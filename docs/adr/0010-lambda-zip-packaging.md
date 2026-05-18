# ADR-0010: Lambda packaging — Python zip, no container images

- **Status**: Accepted
- **Date**: 2026-05-18
- **Deciders**: vpbs-eda-platform

## Context

Ingestion from Kafka, external APIs, and SharePoint is implemented as one Lambda function per source. Lambda supports both zip and container-image packaging.

## Decision

Use **Python zip** packaging for all ingestion Lambdas. The zip artifact is built outside this repo (in the source's own repo or a CI job) and uploaded to an S3 artifact prefix. Terraform references the artifact via `s3_bucket` / `s3_key` / `s3_object_version`.

## Consequences

- No ECR repos or image builds required → smaller infra surface.
- Faster cold starts than container images for small payloads.
- Layers can be used for shared dependencies if size pressure appears.
- Function payloads up to ~250 MB unzipped — sufficient for current source set.

## Alternatives considered

- **Container images** — useful for large dependency footprints; not justified at v0 and would force ECR provisioning + image-build pipelines.
