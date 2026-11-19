# Baltic Finance guest access capstone

**Execution status:** `NOT_RUN`. See the [test matrix](../tests/test-matrix.csv) for individual observations and the [runbook](runbook.md) for investigation steps.

## Acceptance cases

| Case | Same-guest comparison | Evidence required |
| --- | --- | --- |
| Approved partner collaboration | `BFL-021.docx` opens before and during enforcement | Dated access in the controlled guest session |
| Confidential file restriction | `BFL-005.docx` opens before enforcement and is denied after the rule evaluates it | Baseline, enforced guest result, positive match and internal control access |
| Incident reconstruction | Analyst locates the matching rule and correlates the document and time | Redacted Purview event plus independent guest outcome |
| Policy recovery | Same guest reopens the same confidential fixture through the same valid link after disabling the lab policy | Before/after policy mode and repeated access test |
| Lifecycle verification | Independently verify the retained copy after the user deletes `RET-BFL-023.docx` | Label read-back, deletion and evidence of preservation |

## Timeline

| UTC timestamp | Test | Actor | File or policy | Observed outcome | Evidence |
| --- | --- | --- | --- | --- | --- |
| — | SIM-01 | ANALYST | BFL SharePoint External Access | — | — |
| — | DLP-01 | GUEST | BFL-021.docx / BFL-005.docx | — | — |
| — | DLP-02 | GUEST | BFL-021.docx / BFL-005.docx | — | — |
| — | DLP-03 | CONTROL | BFL-005.docx | — | — |
| — | LOG-01 | ANALYST | BFL Case SIT – Guest Restriction | — | — |
| — | RBK-01 | Authorized admin and GUEST | BFL SharePoint External Access / BFL-005.docx | — | — |

## Classifier comparison

Populate with the [recorded SIT observations](../tests/classification-results.csv) and [scorer](../scripts/Measure-SitClassification.ps1) after the runs. Record the contextual rule version, the remaining false positives or misses, and the decision to deploy based on the observed trade-off.

| Run | Corpus | TP | FP | FN | TN |
| --- | --- | --- | --- | --- | --- |
| v1 | Tuning | 8 | 3 | 0 | 9 |
| v2 | Tuning | 8 | 0 | 0 | 12 |
| v2 | Holdout | 4 | 0 | 0 | 6 |

The corpus measures a deliberately small synthetic case. Report results as counts on these samples.
