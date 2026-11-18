<h1 align="center">Microsoft Purview Data Protection &amp; Governance Project</h1>

<p align="center"><strong>SharePoint Online · Information Protection · Data Loss Prevention · Data Lifecycle Management</strong></p>

<p align="center">
  <img alt="Project in progress" src="https://img.shields.io/badge/STATUS-IN%20PROGRESS-9A6700?style=for-the-badge">
  <img alt="30 synthetic test fixtures" src="https://img.shields.io/badge/CORPUS-30%20FIXTURES-6f42c1?style=for-the-badge">
  <img alt="24 defined validation checks" src="https://img.shields.io/badge/VALIDATION-24%20CHECKS%20DEFINED-0078D4?style=for-the-badge">
</p>

<p align="center">
  <img alt="Microsoft Purview" src="https://img.shields.io/badge/Microsoft-Purview-0078D4?style=flat-square">
  <img alt="SharePoint Online" src="https://img.shields.io/badge/Microsoft-SharePoint%20Online-038387?style=flat-square">
  <img alt="Data loss prevention" src="https://img.shields.io/badge/Purview-Data%20Loss%20Prevention-5C2D91?style=flat-square">
  <img alt="PowerShell reporting" src="https://img.shields.io/badge/PowerShell-Classification%20Reporting-3973B9?style=flat-square">
</p>

<p align="center">
  <a href="#project-overview">Overview</a> ·
  <a href="#target-architecture">Architecture</a> ·
  <a href="#featured-implementation-evidence">Featured evidence</a> ·
  <a href="#implementation-progress">Lab roadmap</a> ·
  <a href="#supporting-documentation">Documentation</a> ·
  <a href="#security-design-principles">Security principles</a>
</p>

**Baltic Finance** needs to share routine finance documents with a partner while keeping confidential case files inside the organization. This Microsoft Purview lab uses two SharePoint documents to trace the full decision. A partner should be able to open a routine document, lose access to a classified case file when DLP takes effect, and regain access to that test file after the policy is withdrawn.

## Project Overview

The capstone compares access using the **same guest account and file links** before enforcement, during enforcement, and after rollback. An analyst correlates the policy match with the file and access attempt. A separate retention test checks whether SharePoint preserves a copy after a user deletes the live document.

The [test matrix](tests/test-matrix.csv) records **2 PASS, 1 PENDING and 21 NOT_RUN**. Both passes cover tenant readiness. Microsoft 365 Business Premium is the baseline for the core SharePoint scenario. The [readiness review](docs/readiness.md) tracks the remaining entitlement checks for service-side auto-labeling.

## Explore the Project

| Architecture | Implementation | Validation | Evidence |
| :---: | :---: | :---: | :---: |
| [View control flow](#target-architecture) | [Follow the lab guide](docs/lab-guide.md) | [Open the test matrix](tests/test-matrix.csv) | [Browse evidence](evidence/README.md) |
| File classification, guest access and retention | Configuration, expected behavior, tests and rollback | Ground truth and recorded observations | Sanitized verification records |

## Technologies and Concepts

| Area | Lab scope |
| --- | --- |
| Information Protection | Custom sensitive information types (SITs), contextual matching and manual sensitivity labels |
| SharePoint DLP | Pilot-site scope, simulation, external-only access restriction and neutral-file control |
| Incident triage | Correlate the rule, file, action, actor and UTC timestamp with the observed access result |
| Data Lifecycle Management | Retain-only label, deletion from the live library and independent verification of the preserved copy |
| PowerShell reporting | Score classifier runs against labeled fixtures and report TP, FP, FN and TN once a run is complete |

## Featured Implementation Evidence

| Check | Recorded result | Evidence |
| --- | --- | --- |
| `LIC-04` · Purview portal access | The DLP Policies page opened and **Create policy** was visible | [Sanitized portal observation](evidence/README.md#dlp-portal-baseline) |
| `LIC-05` · SharePoint workload | **SharePoint sites** was selectable in the custom DLP policy wizard | [Sanitized workload observation](evidence/README.md#dlp-portal-baseline) |

The [capstone](docs/capstone.md) defines the evidence required for a policy match, guest denial, internal access, incident reconstruction and recovery.

## Target Architecture

```mermaid
flowchart LR
    Author["Finance author"] --> Finance["SharePoint pilot · Finance-Test"]
    Finance --> DLP{"Purview DLP · contextual SIT"}
    DLP -->|"Neutral control"| Allow["Guest opens the approved file"]
    DLP -->|"Confidential case"| Deny["Guest access restricted"]
    Deny --> Triage["Analyst correlates rule and file activity"]
    Triage --> Recovery["Disable pilot policy and retest original links"]
    Author --> Retention["SharePoint pilot · Retention-Test"]
    Retention --> Preserve["Verify retained copy after user deletion"]
```

The primary DLP rule uses the custom SIT. If the tenant supports sensitivity-label conditions, a separate simulation tests the manual label as a trigger. The retention test uses a dedicated copy so it can be verified independently.

## Implementation Progress

| Stage | Validation milestone | Status |
| --- | --- | --- |
| 0 · Tenant readiness | Confirm base subscription, pilot accounts, guest baseline and SharePoint DLP availability | In progress |
| 1 · Classification and labeling | Compare a pattern-only SIT and a contextual SIT on 20 tuning files. Test the frozen rule on 10 reserved files | `NOT_RUN` |
| 2 · DLP and triage | Simulate the rule, verify guest allow and deny outcomes, and correlate the policy signal | `NOT_RUN` |
| 3 · Lifecycle controls | Verify preservation after deletion. Exercise service-side auto-labeling if the license permits | `NOT_RUN` |
| 4 · Capstone and closure | Repeat the allow and deny cases, then verify recovery after policy withdrawal | `NOT_RUN` |

## Supporting Documentation

| Resource | Contents |
| --- | --- |
| [Tenant readiness](docs/readiness.md) | Licenses, roles and pre-deployment checks |
| [Lab guide](docs/lab-guide.md) | Configuration scope, expected behavior, evidence and rollback |
| [Synthetic corpus](fixtures/README.md) and [manifest](fixtures/manifest.csv) | 12 finance cases, 8 near matches and 10 neutral controls |
| [Classification results](tests/classification-results.csv) and [PowerShell scorer](scripts/Measure-SitClassification.ps1) | Per-file observations and reproducible confusion matrices |
| [Capstone](docs/capstone.md) and [triage runbook](docs/runbook.md) | Guest access timeline, policy attribution and verified withdrawal criteria |

## Security Design Principles

- Scope policy changes to the dedicated SharePoint pilot site and use named, authenticated links for the controlled guest.
- Record the baseline, simulate the rule and compare access with a neutral control before attributing a denial to DLP.
- Publish synthetic fixtures and sanitized evidence. Keep guest links and raw tenant exports private.

## Related Portfolio Projects

[Microsoft 365 Administration & Support](https://github.com/krzysztof-szot/m365-administration-support-project) · [Hybrid Enterprise Security](https://github.com/krzysztof-szot/hybrid-enterprise-security-project) · [IAM PowerShell Automation](https://github.com/krzysztof-szot/iam-powershell-automation-project) · [Microsoft Entra Identity & Access](https://github.com/krzysztof-szot/entra-identity-access-project)
