# cloud-data-platform

Infrastructure-as-Code for the `vpbs-eda` cloud data platform.

v0 targets AWS `ap-southeast-1` with separate `uat` and `prod` accounts. Terraform modules live under
`modules/aws`, while Terragrunt composes per-environment stacks under `envs/<env>/ap-southeast-1`.

## Layout

- `bootstrap/aws` - one-time state bucket and GitHub OIDC deploy role per AWS account.
- `modules/aws/network` - VPC, one public subnet, two private subnets, on-prem routes, VPC endpoints, egress SGs.
- `modules/aws/storage-lake` - S3 buckets for raw, transform scripts, logs, Athena, staging, artifacts, and MWAA DAGs.
- `modules/aws/catalog` - Glue Data Catalog databases and catalog encryption settings.
- `modules/aws/warehouse` - Redshift RA3 multi-AZ cluster and Spectrum role.
- `modules/aws/operational-db` - private RDS operational mirror database.
- `modules/aws/ingestion-*` - Glue batch jobs, ZIP Lambda ingestion, and DMS CDC routing.
- `modules/aws/orchestration-mwaa` - public-webserver MWAA environment and execution role.
- `modules/aws/compute-*` - SSM-only EC2 fleets for cube.js and BI services.
- `modules/aws/governance-lakeformation` - S3 location registration and LF-tag baseline.
- `modules/aws/observability` - alert topic and baseline service alarms.

## Environment Inputs

Update these placeholders before planning:

- `envs/uat/env.hcl` and `envs/prod/env.hcl`: account IDs, VPC CIDRs, gateway IDs, permissions boundary.
- `envs/_common/common.hcl`: proxy, repo server, proxy/repo CIDRs, and on-prem CIDRs.
- `bootstrap/aws`: pass the GitHub repository subjects allowed to assume the deploy role.

Terraform state uses one S3 bucket per account with native S3 lockfiles (`use_lockfile = true`). No DynamoDB
lock table is provisioned.
