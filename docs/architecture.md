# Architecture

High-level view of the `vpbs-eda` cloud data platform, v0 (AWS `ap-southeast-1`).

## Logical layers

```mermaid
flowchart LR
    subgraph Sources
      OnPremDB[On-prem DBs]
      OnPremKafka[On-prem Kafka]
      ExtAPI[External APIs]
      SP[SharePoint]
    end

    subgraph Raw["Raw zone"]
      S3Raw[(S3 raw)]
      RDS[(RDS operational mirror)]
    end

    subgraph Curated["Curated (Redshift)"]
      RS[(Redshift RA3 multi-AZ)]
    end

    subgraph Insight
      Cube[cube.js / EC2]
      PBI[PowerBI Gateway / EC2 Win]
      SSRS[SSRS / EC2 Win]
      Self[Self-service SQL]
    end

    OnPremDB -- Glue NETWORK conn --> S3Raw
    OnPremDB -- DMS target=rds --> RDS
    OnPremDB -- DMS target=redshift --> RS
    OnPremKafka -- Lambda zip --> S3Raw
    ExtAPI -- Lambda zip --> S3Raw
    SP -- Lambda zip --> S3Raw

    S3Raw -- Spectrum / dbt / Glue / Lambda --> RS
    RDS -. ad-hoc reads .-> Cube
    RS --> Cube
    RS --> PBI
    RS --> SSRS
    RS --> Self
```

## AWS topology (per environment)

```mermaid
flowchart TB
    subgraph VPC["VPC (uat 10.10.0.0/16, prod 10.20.0.0/16)"]
      direction TB
      IGW([Internet Gateway])
      subgraph Pub["Public subnet (1 AZ)"]
        BastionPlaceholder([reserved])
      end
      subgraph Priv["Private subnets (2 AZs)"]
        MWAA[MWAA]
        LambdaENI[Lambda ENIs]
        GlueENI[Glue ENIs<br/>via NETWORK connection]
        EC2Cube[EC2 cube.js]
        EC2BI[EC2 PowerBI / SSRS]
        DMS[DMS replication]
        RDS[(RDS)]
        Redshift[(Redshift)]
      end
      VPCe[(VPC endpoints<br/>STS, KMS, S3 gw, ECR, Logs, SSM,<br/>Glue, MWAA, DMS, Redshift Data API)]
    end

    subgraph External["External (other teams)"]
      Proxy[HTTP proxy]
      RepoSrv[apt / pip mirror]
      TGW{{Transit Gateway / VGW}}
      OnPrem[On-prem]
    end

    Pub --- IGW
    Priv --- VPCe
    Priv -- proxy_host:port --> Proxy
    Priv -- repo_server_host:port --> RepoSrv
    Priv -- on-prem CIDRs --> TGW --- OnPrem
```

## MWAA-driven orchestration

```mermaid
sequenceDiagram
    participant MWAA
    participant Lambda
    participant Glue
    participant DMS
    participant Redshift

    MWAA->>Lambda: invoke(payload)
    Lambda-->>MWAA: status
    MWAA->>Glue: StartJobRun
    Glue-->>MWAA: success / fail
    MWAA->>DMS: StartReplicationTask
    DMS-->>MWAA: task state
    MWAA->>Redshift: Data API (dbt run)
    Redshift-->>MWAA: query state
```

## Decision log

Confirmed decisions live as ADRs under [`docs/adr/`](./adr/).

| # | Title |
|---|---|
| 0001 | IaC stack — Terraform + Terragrunt |
| 0002 | Environment & account topology — uat + prod separate accounts |
| 0003 | On-prem connectivity model — consume externally-managed VPN/DX |
| 0004 | Warehouse engine — Redshift RA3 multi-AZ provisioned |
| 0005 | DMS routing — per-source target (Redshift or RDS) |
| 0006 | MWAA webserver — public + IAM Identity Center auth |
| 0007 | Resource naming convention — `<org>-<dep>-<env>-<region>-<resource>` |
| 0008 | Subnet design — 1 public + 2 private (no isolated tier) |
| 0009 | Terraform state backend — S3 only, native locking, no DynamoDB |
| 0010 | Lambda packaging — Python zip, no container images |
| 0011 | Scheduling — MWAA only, no EventBridge cron |
| 0012 | Encryption — AWS-managed default KMS keys at v0 |
| 0013 | Glue VPC attachment — `NETWORK` connections, no JDBC connections |
