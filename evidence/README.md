# Evidence index

Publish evidence after each live test is observed. Use repo-relative paths in the [test matrix](../tests/test-matrix.csv). Keep raw exports and share links in private storage.

## DLP portal baseline

**LIC-04 · 18 November 2026.** The supplied capture shows the lab operator on Microsoft Purview → Data Loss Prevention → Policies with the **Create policy** command visible. The visible default policies are for Copilot interactions, Teams and devices. Their names and modes support a baseline inventory. Read the policy details to establish their actual locations before the pilot. This observation verifies page visibility. The original portal capture remains private.

**LIC-05 · 18 November 2026.** The lab operator confirmed that **SharePoint sites** is selectable in the custom DLP policy wizard under **Enterprise applications & devices**. This verifies availability in the wizard. Pilot scoping and enforcement have their own tests.

## SharePoint pilot setup

The lab operator reported creating `BFL-Purview-Pilot` using the Team site template without a Microsoft 365 group. The site is the scope for the configuration and file-level checks in the [pilot procedure](../docs/lab-guide.md#1-establish-the-pilot-boundary).

The operator confirmed that `Finance-Test` contains the four synthetic pilot files and that the empty `Retention-Test` library is available for the later retention exercise.

The initial pilot-site scope was **Only people in your organization**. The operator verified the controlled guest in Microsoft Entra ID and confirmed the stored pilot-site settings **Existing guests only**, **Specific people**, and **View**. See the [readiness record](../docs/readiness.md#sharepoint-sharing-baseline) for the before-and-after settings.

The first recipient lookup for `ENV-01` displayed a directory group. The operator is verifying the controlled guest by its original external email address before sending the named link.

| File in Finance-Test | Purpose |
| --- | --- |
| `BFL-005.docx` | SIT-positive fixture for the DLP run |
| `BFL-021.docx` | Neutral fixture for the guest baseline and DLP control |
| `BFL-022.xlsx` | Manual `BFL Finance Confidential` label test |
| `BFL-024.xlsx` | Manual `BFL Internal` label test |

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

### Initial attempt and readback

[05 · Initial v2 draft](stage-01/05-SIT-02-v2-pattern.png) shows the intended High-confidence pattern before the operator finished saving it. The draft included the primary regex `BFLCaseIdRegex`, the supporting list `BFLFinanceCaseContext` and a 50-character proximity.

Readback confirmed one High-confidence pattern. The saved primary element was the keyword list `BFLFinanceCaseContext`. The saved proximity was 50 characters and the supporting-elements list was empty. The operator confirmed that the intended changes were not saved. This persisted keyword-only pattern explains the initial test outcomes below.

The initial observations remain evidence of the configuration error. Results from the saved correction appear under the corrected v2 run below.

### Same-file comparison

| Fixture | v1 baseline | Initial saved v2 |
| --- | --- | --- |
| `BFL-014.xlsx` | `MATCH` with one unique identifier and no supporting element. [04 · v1 result](stage-01/04-SIT-01-v1-BFL-014.png) | `NO_MATCH`. [06 · v2 result](stage-01/06-SIT-02-v2-BFL-014.png) |

The lab operator selected `BFL Finance Case v2` as initially saved for the second test. The result screen confirms the fixture and no-match message.

### Positive control on initial v2

[07 · BFL-006 match results](stage-01/07-SIT-02-v2-BFL-006.png) confirms one unique match for `BFL Finance Case v2` at each confidence level. Purview displayed `synthetic finance case` under **Matches** and `None` under **Supporting elements**. This is a true positive at file level. The malformed-ID fixture `BFL-016.xlsx` provides a separate check of whether the phrase can trigger a match without a valid identifier.

### Malformed-ID control

The v1 test returned `NO_MATCH` on `BFL-016.xlsx`. The operator reported one unique v2 match at Low, Medium and High. Purview displayed `synthetic finance case` under **Matches** and `None` under **Supporting elements**. The seven-digit ID places this fixture outside the positive ground truth. This is a new file-level false positive for v2.

The [diagnostic workbook](../fixtures/diagnostics/phrase-only.xlsx) keeps the same workbook content except that the seven-digit identifier in cell A5 is replaced with `omitted`. Use this control to check whether the saved v2 classifier returns a match when the phrase appears without an identifier. The diagnostic is outside the 20-file tuning matrix and the holdout set.

### Phrase-only diagnostic

[08 · Phrase-only v2 result](stage-01/08-SIT-02-v2-phrase-only.png) shows that `BFL Finance Case v2` returned `MATCH` on `phrase-only.xlsx`. The result displayed one unique match at each confidence level with `synthetic finance case` under **Matches** and `None` under **Supporting elements**. The workbook contains the phrase and no case identifier. This result is consistent with the saved keyword list functioning as the primary element.

After saving the corrected v2 pattern, the operator retested the same `phrase-only.xlsx` workbook and reported `NO_MATCH`. The initial saved pattern returned `MATCH` on this workbook. The corrected pattern passed this diagnostic control. This diagnostic remains outside the 20-file tuning matrix.

### Corrected v2 tuning run

[09 · BFL-006 positive retest](stage-01/09-SIT-02-v2-retest-BFL-006.png) shows a single unique match for `BFL Finance Case v2` at each confidence level. **Matches** shows `BFLCASE-249898` and **Supporting elements** shows `synthetic finance case`. The same saved configuration returned `NO_MATCH` on the phrase-only diagnostic. This begins the corrected 20-file tuning run.

The operator reported `NO_MATCH` on all five near-match fixtures in the corrected tuning run. `BFL-013`, `BFL-014` and `BFL-017` had triggered v1. The five- and seven-digit controls `BFL-015` and `BFL-016` also returned `NO_MATCH`, including the seven-digit example that had triggered the initial keyword-only v2 pattern.

All eight positive tuning fixtures matched after the correction. For each of the seven additional DOCX and XLSX files the operator reported one unique case ID and the supporting phrase `synthetic finance case`. `BFL-006` is documented in screenshot 09. The [per-file register](../tests/classification-results.csv) contains the unique observations.

The remaining seven neutral fixtures returned `NO_MATCH`, completing all 20 trials. The corrected v2 run had 8 true positives, 0 false positives, 0 false negatives and 12 true negatives. On this tuning set, precision improved from 72.7% to 100% and recall was 100% in both runs. The [capstone comparison](../docs/capstone.md#classifier-comparison) records the confusion matrices.

### Frozen pattern for holdout

Use the saved `BFL Finance Case v2` pattern with High confidence. The primary element is `BFLCaseIdRegex`. The supporting list `BFLFinanceCaseContext` contains the case-insensitive string `synthetic finance case` with a 50-character proximity. The separate 10-file holdout evaluates this configuration once before any additional tuning.

### Holdout evaluation

The operator reported results for all ten held-out files using the frozen `BFL Finance Case v2` pattern. All four finance cases matched, including the DOCX and XLSX examples where the supporting phrase precedes the ID. The no-phrase, wrong-prefix and distant-phrase controls returned `NO_MATCH`, as did the three neutral files.

The holdout result was 4 true positives, 0 false positives, 0 false negatives and 6 true negatives. See the [per-file register](../tests/classification-results.csv) and the [confusion matrices](../docs/capstone.md#classifier-comparison).

## Sensitivity label setup

The operator confirmed that `BFL Internal` and `BFL Finance Confidential` were created. Both labels use the **Files & other data assets** scope. The review screens showed no access control, content marking, or automatic labeling. The operator created the `BFL-Purview-Label-Pilot` security group for the publishing policy. A membership check found the site administrator in the group. The pilot tests require a licensed, non-administrative group member.

The operator reported publishing both labels in `BFL Purview Pilot Labels` with `BFL-Purview-Label-Pilot` as the single included group. The policy is for manual labeling with no default or required label. The operator reported that policy sync was in progress. The lab operator subsequently confirmed adding a test user with Business Premium with Copilot to the group. Final membership, site edit access, and availability in the pilot user's session are pending verification.

File-label tests `LBL-01` and `LBL-02` will verify that the assigned labels persist after applying them to the target files in `Finance-Test`.

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
