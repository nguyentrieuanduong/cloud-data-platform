# AWS Bootstrap

Run once per environment account before Terragrunt stacks are initialized.

This creates:

- S3 state bucket with versioning, public access block, and native S3 lockfile compatibility.
- GitHub OIDC provider.
- Environment deploy role for GitHub Actions.

No DynamoDB lock table is created.
