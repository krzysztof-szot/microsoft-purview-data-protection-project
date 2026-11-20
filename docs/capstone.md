# Baltic Finance guest access capstone

**Execution status:** `PENDING`. DLP recovery and administrative closeout were verified. The retention lifecycle tests remain open. See the [test matrix](../tests/test-matrix.csv) for individual observations and the [runbook](runbook.md) for investigation steps.

## Acceptance cases

| Case | Same-guest comparison | Evidence required |
| --- | --- | --- |
| Approved partner collaboration | `BFL-021.docx` opens before and during enforcement | Dated access in the controlled guest session |
| Confidential file restriction | `BFL-005.docx` opens before enforcement and is denied after the rule evaluates it | Baseline, enforced guest result, positive match and internal control access |
| Incident reconstruction | Analyst locates the matching rule and correlates the document and time | Redacted Purview event plus independent guest outcome |
| Policy recovery | Same guest reopens the same confidential fixture through the same valid link after disabling the lab policy | Before/after policy mode and repeated access test |
| Lifecycle verification | Independently verify the retained copy after the user deletes `RET-BFL-023.docx` | Label read-back, deletion and evidence of preservation |

## Timeline

| Time | Test | Actor | Observed outcome | Evidence |
| --- | --- | --- | --- | --- |
| — | SIM-01 | ANALYST | Purview scanned 13 files on the pilot site and reported one match, `BFL-005.docx`. | [Simulation result](../evidence/stage-02/03-SIM-01-BFL-005-match.png) |
| — | DLP-01 | GUEST | `BFL-021.docx` and `BFL-005.docx` both opened in view-only mode before enforcement. | [Guest baseline](../evidence/README.md#guest-access-before-enforcement) |
| — | DLP-02 | GUEST | After enforcement took effect, `BFL-005.docx` returned HTTP 403 and `BFL-021.docx` opened in view-only mode. | [Enforcement observation](../evidence/README.md#access-after-policy-activation) |
| — | DLP-03 | CONTROL | The internal control user opened `BFL-005.docx` after activation. | [Internal access](../evidence/README.md#access-after-policy-activation) |
| 2026-11-19 14:20:50 UTC | LOG-01 | ANALYST reviewed the service audit event | Audit associated `BFL-005.docx` with the enabled `BFL Case SIT – Guest Restriction` rule and logged `SPAccessTimeControl` under an administrative identity. | [Redacted audit fields](../evidence/README.md#dlp-audit-correlation) |
| 2026-11-20 (local date) | RBK-01 | GUEST and authorized admin | The guest reconfirmed the denial and the neutral control. The administrator submitted the change to turn off the policy and reported synchronization in progress. | [Rollback verification](../evidence/README.md#rollback-verification) |
| 2026-11-20 (local date) | RBK-01 | GUEST and authorized admin | `BFL-005.docx` reopened in **Viewing** and `BFL-021.docx` still opened through its retained link. The operator confirmed the DLP policy was **Off** with **Sync completed**. | [Guest recovery](../evidence/stage-04/01-RBK-01-guest-recovery-BFL-005.png) · [Policy and control readback](../evidence/README.md#rollback-verification) |
| 2026-11-20 (local date) | CLS-01 | GUEST and authorized admin | The administrator revoked both test links after recovery verification. In the guest session both links returned **This link has been removed**. | [Pilot closure](../evidence/README.md#pilot-closure) |
| 2026-11-20 (local date) | CLS-01 | Authorized admin | The auto-labeling pilot showed **Off**. Four sensitivity labels remained visible in the test library. Two trial readbacks displayed **Expires on**. | [Policy, label and billing readback](../evidence/README.md#pilot-closure) |

The original baseline links were unavailable by the first enforcement retest. The replacement links from `DLP-02` provide the comparison for `RBK-01`. The audit timestamp identifies the rule event. The guest's access results were observed separately.

## Classifier comparison

The v2 supporting phrase removed all three false positives on the tuning set while retaining all eight true positives. The frozen v2 classifier also detected all four positive cases in the ten-file holdout. These observed results supported selecting v2 for the pilot DLP rule. See the [per-file observations](../tests/classification-results.csv) and [scorer](../scripts/Measure-SitClassification.ps1).

| Run | Corpus | TP | FP | FN | TN |
| --- | --- | --- | --- | --- | --- |
| v1 | Tuning | 8 | 3 | 0 | 9 |
| v2 | Tuning | 8 | 0 | 0 | 12 |
| v2 | Holdout | 4 | 0 | 0 | 6 |

The corpus measures a deliberately small synthetic case. Report results as counts on these samples.
