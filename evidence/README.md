# Evidence index

Publish evidence after each live test is observed. Use repo-relative paths in the [test matrix](../tests/test-matrix.csv). Keep raw exports and share links in private storage.

## DLP portal baseline

**LIC-04 · 18 November 2026.** The supplied capture shows the lab operator on Microsoft Purview → Data Loss Prevention → Policies with the **Create policy** command visible. The visible default policies are for Copilot interactions, Teams and devices. Their names and modes support a baseline inventory. Read the policy details to establish their actual locations before the pilot. This observation verifies page visibility. The original portal capture remains private.

**LIC-05 · 18 November 2026.** The lab operator confirmed that **SharePoint sites** is selectable in the custom DLP policy wizard under **Enterprise applications & devices**. This verifies availability in the wizard. Pilot scoping and enforcement have their own tests.

## Baseline sensitive information type

The lab operator configured `BFL Finance Case v1` and observed the portal's creation confirmation. The configuration captures show what was saved. File-level matching is tracked separately under `SIT-01`.

| Screenshot | What it shows |
| --- | --- |
| [01 · Regular expression](stage-01/01-SIT-01-v1-regex.png) | `BFLCaseIdRegex` has one capturing group for the six-digit case identifier. It uses String match with no validators |
| [02 · Pattern settings](stage-01/02-SIT-01-v1-pattern.png) | High confidence, 50-character proximity, and a single primary element with no supporting elements or additional checks |
| [03 · Creation confirmation](stage-01/03-SIT-01-v1-created.png) | Portal confirmation after the operator submitted the baseline SIT |

### Baseline tuning observations

| Fixture | Purview v1 result | Interpretation and evidence |
| --- | --- | --- |
| `BFL-006.xlsx` | One unique identifier `BFLCASE-249898` shown at Low, Medium and High | True positive on known finance-case content. Result reported by the lab operator |
| `BFL-014.xlsx` | One unique identifier `BFLCASE-254834` shown at Low, Medium and High | False positive on an identifier with unrelated context. [04 · Match results](stage-01/04-SIT-01-v1-BFL-014.png) |
| `BFL-026.xlsx` | No sensitive information detected | True negative on the neutral control. Result reported by the lab operator |

The baseline classified all 20 tuning fixtures. The eight finance cases matched and nine non-case fixtures returned no match. Precision was 72.7% (8 of 11 matches) and recall was 100% (8 of 8 finance cases) on the tuning set.

| False-positive fixture | Why the pattern-only rule matched |
| --- | --- |
| `BFL-013.docx` | Well-formed ID without the supporting phrase |
| `BFL-014.xlsx` | Well-formed ID next to unrelated context |
| `BFL-017.docx` | Well-formed ID with the supporting phrase over 500 characters away |

The five- and seven-digit controls `BFL-015.docx` and `BFL-016.xlsx` returned no match. The v2 experiment will require the supporting phrase within 50 characters of the case ID. See the [per-file register](../tests/classification-results.csv) for the observed results.

## Contextual sensitive information type

[05 · v2 pattern settings](stage-01/05-SIT-02-v2-pattern.png) shows the `BFL Finance Case v2` pattern at High confidence. It reuses the primary regex `BFLCaseIdRegex` and adds the supporting keyword list `BFLFinanceCaseContext` with a 50-character proximity. The operator configured the list with the case-insensitive phrase `synthetic finance case`. The operator saved the SIT and began the `SIT-02` tuning run.

### Same-file comparison

| Fixture | v1 baseline | v2 with context |
| --- | --- | --- |
| `BFL-014.xlsx` | `MATCH` with one unique identifier and no supporting element. [04 · v1 result](stage-01/04-SIT-01-v1-BFL-014.png) | `NO_MATCH`. [06 · v2 result](stage-01/06-SIT-02-v2-BFL-014.png) |

The lab operator selected `BFL Finance Case v2` for the second test. The result screen confirms the fixture and no-match message. This is the first observed correction on the tuning set. The remaining v2 cases include positive controls to check for missed finance cases.

### Contextual positive control

[07 · BFL-006 match results](stage-01/07-SIT-02-v2-BFL-006.png) confirms one unique match for `BFL Finance Case v2` at each confidence level. Purview displayed `synthetic finance case` under **Matches** and `None` under **Supporting elements**. This is a true positive at file level. The malformed-ID fixture `BFL-016.xlsx` provides a separate check of whether the phrase can trigger a match without a valid identifier.

### Malformed-ID control

The v1 test returned `NO_MATCH` on `BFL-016.xlsx`. The operator reported one unique v2 match at Low, Medium and High. Purview displayed `synthetic finance case` under **Matches** and `None` under **Supporting elements**. The seven-digit ID places this fixture outside the positive ground truth. This is a new file-level false positive for v2.

The [diagnostic workbook](../fixtures/diagnostics/phrase-only.xlsx) keeps the same workbook content except that the seven-digit identifier in cell A5 is replaced with `omitted`. Use this control to check whether the saved v2 classifier returns a match when the phrase appears without an identifier. The diagnostic is outside the 20-file tuning matrix and the holdout set.

### Phrase-only diagnostic

[08 · Phrase-only v2 result](stage-01/08-SIT-02-v2-phrase-only.png) shows that `BFL Finance Case v2` returned `MATCH` on `phrase-only.xlsx`. The result displayed one unique match at each confidence level with `synthetic finance case` under **Matches** and `None` under **Supporting elements**. The workbook contains the phrase and no case identifier. The observed SIT test therefore accepts a file that fails the required ID-and-context condition. The next diagnostic step is to inspect the saved pattern and its elements. Explain the behavior before selecting a classifier for DLP.

## Captures to collect

| Capture | What to show |
| --- | --- |
| ENV-01 | Named guest opening the neutral fixture in a separate session |
| SIT-01 to SIT-03 | Rule definitions and sanitized per-file classifier outcomes |
| SIM-01 | Pilot-site scope, simulation mode and matched fixture |
| DLP-02 and DLP-03 | Guest allow/deny and an ordinary internal user's access |
| LOG-01 | Rule, file, workload and UTC time in the cited signal |
| RET-01 to RET-03 | Label state, deletion and independently confirmed preservation |
| RBK-01 | Disabled pilot policy and reopened confidential file using the original guest link |

Preserve fixture names, policy names, role aliases and UTC timestamps where safe. Redact tenant/account identifiers, URLs and tokens, IP addresses, device identifiers, billing profiles, notifications and other visible browser context. Review the redacted file itself before committing it.
