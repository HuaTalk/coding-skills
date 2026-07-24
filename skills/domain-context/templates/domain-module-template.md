<!--
Domain module template (v2)

Usage:
1. Copy this file to knowledge/domain/<module>.md.
2. Replace every <angle-bracket placeholder> with real content.
3. Sections 2-7 are required. If one does not apply, write `N/A - <one-line reason>`; never delete the section.
4. Sections 8-11 are optional. If empty, keep the heading and `_Not captured yet_`; never delete the section.
5. Remove instructional comments after writing. Keeping them is valid but adds noise.

Principles:
- Record why, not what. Omit facts that source inspection can reconstruct.
- Use stable `Class#method` grep anchors, never line numbers.
- Keep TL;DR entries to constraints and traps, one short line each.
- Keep exclusion logic in its own section because it is a frequent diagnostic entry point.
- Blast Radius must name response fields and downstream consumers.

Reading order:
TL;DR -> Inputs -> Contracts -> Pipeline position -> Output logic -> Exclusion logic
-> Blast radius -> Flags -> Tests -> Why -> References
-->

# <Domain Module Title>

> Module: <module-name> | Layer: Domain
> Architecture dependency: [[architecture/<module>]]
> Last updated: <YYYY-MM-DD> | Primary source of truth: <config key | package path | document URL>

## TL;DR

<!-- Write 3-5 short lines containing only constraints, traps, and implicit conventions. -->

- <One-line definition of the domain>
- <Most common trap>
- <Second common trap>
- <Implicit convention, cache window, or naming collision>

**Common scenarios:** <scenario 1> | <scenario 2> | <scenario 3>

**Related modules:** [[domain/example-a]] [[domain/example-b]]

---

## Contents

- Section 2: Inputs and data sources
- Section 3: Data contracts and model mapping
- Section 4: Pipeline position
- Section 5: Output logic
- Section 6: Exclusion logic
- Section 7: Blast radius
- Section 8: Flags and observability
- Section 9: Test focus
- Section 10: Why and history
- Section 11: References and cross-module links

---

## Section 2: Inputs and Data Sources

<!-- Order sources by importance and upstream position. Capture origin, cache, invalidation, and control flags. -->

### 2.1 Underlying Data Sources

| Data source | Key fields | Cached | Cache layer | Invalidation |
|-------------|------------|--------|-------------|--------------|
| `<database.table>` | `<column1>` / `<column2>` | yes / no | <local / distributed / none> | <config key and default> |

### 2.2 Upstream APIs and Services

| Service | Interface | Invocation point | Contract |
|---------|-----------|------------------|----------|
| `<service-name>` | `<method>` | <pipeline stage> | <contract reference> |

### 2.3 Configuration Controls

| Source | Key | Purpose | Default | Rollout |
|--------|-----|---------|---------|---------|
| `<configuration source>` | `<config.key>` | <one line> | `<default>` | <global / allowlist / experiment> |

### 2.4 Request Control Fields

| Field | Source | Meaning | Effect |
|-------|--------|---------|--------|
| `<requestField>` | <client / upstream service> | <semantics> | <selected branch> |

---

## Section 3: Data Contracts and Model Mapping

<!-- Resolve synonym mismatches between business concepts and code models. -->

### 3.1 API Contract

- Service: `<service>` | Interface: `<method>` | Key DTO: `<fully.qualified.DTO>`

### 3.2 Code Model to Business Concept

| Business concept | Code class (grep anchor) | Key fields |
|------------------|--------------------------|------------|
| <concept> | `com.example.Entity` | `field1` / `field2` |

### 3.3 Key Enums and Constants

| Constant | Value | Business meaning |
|----------|-------|------------------|
| `<EnumConst.NAME>` | `<value>` | <semantics> |

---

## Section 4: Pipeline Position

<!-- Give every node a stable Class#method anchor. -->

### 4.1 Entry Point

- **Trigger:** `<Class#method>`
- **Stage:** <chain / interceptor / cache layer>

### 4.2 Processing Nodes in Order

```text
<upstream load>
  -> <processing node 1>
    -> <processing node 2>
      -> <output node>
```

| # | Node | Grep anchor | Responsibility |
|---|------|-------------|----------------|
| 1 | <load> | `<Class#method>` | <one line> |
| 2 | <process> | `<Class#method>` | <one line> |
| 3 | <output> | `<Class#method>` | <one line> |

### 4.3 Output Node

- **Write location:** `<Class#method>` -> `<response field>`
- **Response assembly:** <final response construction step>

---

## Section 5: Output Logic

<!-- Give every rule a source of truth: configuration, field value, or hard-coded behavior. -->

### 5.1 Primary or Deduplication Key

- **Key:** `<field1> + <field2> + ...`
- **Strategy:** <first wins / highest score wins / merge>
- **Source of truth:** `<Class#method>`

### 5.2 Ordered Filter Chain

| # | Condition | Trigger | Source of truth | Rejection behavior |
|---|-----------|---------|-----------------|--------------------|
| 1 | <condition> | <expression> | <config / field> | <discard / degrade> |

### 5.3 Aggregation and Merge

- **Multiple-match strategy:** <winner or ordering rule>
- **Merged fields:** <fields and merge rules>

### 5.4 Sorting, Top-N, and Fallback

- **Sort key:** `<field>` ASC / DESC
- **Top-N:** <value and config key>
- **Fallback:** <empty set / default / error>

---

## Section 6: Exclusion Logic

<!-- Order from frequent filtering to rare silent drops and disabled rollout paths. -->

### 6.1 Explicit Filters

| # | Reason | Trigger | Log keyword | Verification |
|---|--------|---------|-------------|--------------|
| 1 | <reason> | <condition> | `<keyword>` | <grep / dashboard> |

### 6.2 Silent Drops and Boundaries

| # | Scenario | Symptom | Investigation |
|---|----------|---------|---------------|
| 1 | <missing field / empty data / version mismatch> | <disappears without a log> | <inspect intermediate state / temporary log> |

### 6.3 Flags, Experiments, and Rollout

- **Key flag:** `<config key>` -> when disabled, the path <skips / degrades to X>
- **Experiment dimension:** <dimension and current rollout>
- **How to detect disablement:** <metric or log keyword>

### 6.4 Investigation Order

> Missing output -> inspect `<A>`, then `<B>`, then `<C>`.

---

## Section 7: Blast Radius

### 7.1 Response Fields Written

| Response field | Meaning | Consumer |
|----------------|---------|----------|
| `<response.path.field>` | <meaning> | <list page / detail page / downstream> |

### 7.2 Downstream Systems

| Downstream | Consumption | Impact |
|------------|-------------|--------|
| <orders / risk / monitoring> | <API / event / shared data> | <one line> |

### 7.3 Domain Consumers

- [[domain/example-a]] - <usage>
- [[domain/example-b]] - <usage>

### 7.4 Easy-to-Miss Boundaries

- <fact 1>
- <fact 2>

---

## Section 8: Flags and Observability

_Not captured yet_

---

## Section 9: Test Focus

_Not captured yet_

---

## Section 10: Why and History

_Not captured yet_

---

## Section 11: References and Cross-Module Links

### 11.1 Source Anchors

- `<Class#method>` - <one line>
- `<Class#method>` - <one line>

### 11.2 External Documents

- <document title and URL>
- <pull request or incident review URL>

### 11.3 Cross-Module Links

- [[architecture/<module>]] - <reason for the link>
- [[domain/<module>]] - <reason for the link>
