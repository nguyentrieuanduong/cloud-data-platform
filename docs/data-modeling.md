# Data Modeling Summary

## Final Position

For large-scale data warehouse/lakehouse with many sources and many consumer types:

```text
Bronze: raw source history
Silver: cleaned foundation - identities, events, current entities, daily snapshots
Gold: flat-first production serving products
Mart: optional dimensional stars for BI
Explore: expert ad-hoc SQL
```

Use dimensional modeling as **design discipline**, not mandatory physical warehouse core.

Default production contract: **flat facts, daily snapshots, aggregates, feature/export tables, governed metrics**.

Dimensional stars are allowed in data marts or BI semantic layers where useful.

---

## Dimensional Modeling

### What It Is

Dimensional modeling organizes analytics around:

- Facts: business events or measures.
- Dimensions: descriptive context.
- Grain: exact meaning of one row.
- Conformed dimensions: shared vocabulary across processes.
- SCD patterns: handling attribute history.

Example:

```text
fact_sales
  -> dim_customer
  -> dim_product
  -> dim_store
  -> dim_date
```

### Pros

- Easy for BI users and tools to understand.
- Strong discipline around process, grain, facts, and dimensions.
- Good semantic vocabulary for measures and attributes.
- Conformed dimensions help align business definitions.
- Kimball bus is a valid enterprise architecture in BI-heavy, modest-source environments.
- Good fit for marts, cubes, semantic layers, and exploratory analyst SQL.

### Cons

- Runtime joins become expensive and fragile at scale.
- SCD2 creates effective-date range join complexity.
- Adding dimensions can create governance and BI maintenance work.
- Many-to-many bridges and role-playing dimensions are easy to misuse.
- Backfills require reconstructing historical dimension state.
- Non-BI consumers still need flat rows: ML, reverse ETL, exports, LLM tools, data apps.
- Semantic layers do not cover every consumer.
- Can bias the warehouse core toward BI instead of broader enterprise consumption.

### Best Use

Use dimensional models for:

- BI marts.
- Semantic layers.
- Analyst exploration.
- Domains with modest source complexity and BI-dominant usage.
- Planning vocabulary: bus matrix, grain, conformance, facts, dimensions.

Do not force all production consumers through dimensional joins.

---

## Flat-First Solution

### Core Idea

Build governed flat facts and snapshots as first-class warehouse products.

Example:

```text
gold.fact_subscription_day
  snapshot_date
  subscription_id
  customer_id
  mrr_cents
  plan_code_as_of_day
  customer_segment_as_of_day
  customer_segment_current
  region_as_of_day
  rule_version
  built_at
```

The table stores measures and high-use attributes together at a declared grain.

### Pros

- Fewer joins for consumers.
- Faster common dashboard and product queries.
- Easier backfills via partition rebuild.
- Explicit temporal semantics: `_as_of_day`, `_at_event`, `_current`, `_as_published`.
- Better reproducibility for finance, audit, ML, and exports.
- Easier LLM/text-to-SQL surface.
- Works naturally for ML features, reverse ETL, data shares, and data apps.
- Columnar storage and compression reduce duplication cost.
- Reduces dimension-addition headache for high-use attributes.

### Cons

- More storage.
- Requires strong governance to avoid uncontrolled wide-table sprawl.
- New attributes may require column adds and partition rebuilds.
- Not ideal for unanticipated ad-hoc exploration.
- Must maintain upstream conformed definitions.
- Daily snapshots may miss intra-day change order unless events are retained.

### Governance Required

A flat table is a warehouse core product only if it has:

- Declared grain.
- Owner and SLA.
- Source lineage.
- Rule version.
- Temporal semantics.
- Key and measure tests.
- Rebuild policy.
- Freshness checks.
- Deprecation policy.

Without these, it is just an extract or exploratory table.

---

## Signed Lakehouse Pattern

### Bronze

Raw, append-only, source-faithful.

Contains:

- CDC/events/files.
- Source payloads.
- Ingestion metadata.
- Schema version.

### Silver

Cleaned, conformed foundation. Not SCD2 by default.

Contains:

- Identity maps.
- Canonical entity IDs.
- Atomic events.
- Current entity/state tables.
- Daily entity/state snapshots.
- Selective SCD2 only for exact valid-time needs.

Default state pattern:

```text
silver.customer_profile_current
silver.customer_profile_day
silver.subscription_state_current
silver.subscription_state_day
silver.event_subscription_state_change
```

Prefer daily snapshots over SCD2 when business grain is daily.

### Gold

Production serving layer.

Contains:

- Flat facts.
- Daily/period snapshots.
- Aggregates.
- Feature tables.
- Export-ready tables.
- Metric tables.

Consumers should start here by default.

### Mart

Optional BI presentation layer.

Contains:

- Star schemas.
- Cubes.
- Semantic-over-star models.

Built from Gold, not directly from raw sources.

---

## Daily Snapshot vs SCD2

Prefer daily snapshots when:

- Reporting grain is daily.
- Backfills are common.
- ML needs point-in-time features.
- Consumers need simple equality joins.
- Columnar storage/compression is available.

Use SCD2 selectively when:

- Intra-day ordering matters.
- Exact valid-time audit is required.
- Source emits effective-dated records.
- Attribute changes are rare and daily expansion is wasteful.

Daily snapshot join:

```sql
fact.snapshot_date = profile.snapshot_date
and fact.customer_id = profile.customer_id
```

SCD2 range join:

```sql
fact.event_time >= profile.effective_from
and fact.event_time < profile.effective_to
```

The daily snapshot pattern is easier to test, explain, and backfill.

---

## Decision Rules

Use Kimball bus / dimensional core when:

- BI dominates.
- Sources are modest.
- Team needs fast time-to-value.
- Most consumers use one BI semantic layer.

Use hybrid foundation + flat-first serving when:

- Many source systems exist.
- Consumers include BI, ML, reverse ETL, exports, LLM tools, apps.
- Backfills and reproducibility matter.
- Runtime joins and SCD logic are causing pain.
- Flat rows are needed outside BI.

For our target architecture:

> Hybrid foundation + flat-first Gold + optional dimensional marts.

---

## Short Pitch

Dimensional modeling gives us useful language: grain, facts, dimensions, conformance, SCD thinking.

But production consumers should not repeatedly pay for join graphs and SCD predicates.

In a modern columnar lakehouse, publish governed flat facts and daily snapshots as warehouse products. Keep raw events and daily snapshots in Silver, serve flat contracts in Gold, and build dimensional marts only where BI benefits.

