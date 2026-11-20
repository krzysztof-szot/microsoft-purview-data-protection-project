# Evidence index

Publish evidence after each live test is observed. Use repo-relative paths in the [test matrix](../tests/test-matrix.csv). Keep raw exports and share links in private storage. Number screenshots from `01` within each stage directory.

## Auto-labeling wizard scope

**LIC-03.** [Stage 0 screenshot 02](stage-00/02-LIC-03-auto-labeling-sharepoint-scope.png) shows **Specific sites and adaptive scopes** with a single selected item, `BFL-Purview-Pilot`. It verifies selection of the pilot SharePoint site in the auto-labeling wizard. The operator separately confirmed the E5 Information Protection and Governance add-on assignment to `PILOT` in **Licenses and apps**.

## DLP portal baseline

**LIC-04 · 18 November 2026.** The supplied capture shows the lab operator on Microsoft Purview → Data Loss Prevention → Policies with the **Create policy** command visible. The visible default policies are for Copilot interactions, Teams and devices. Their names and modes support a baseline inventory. Read the policy details to establish their actual locations before the pilot. This observation verifies page visibility. The original portal capture remains private.

**LIC-05 · 18 November 2026.** The lab operator confirmed that **SharePoint sites** is selectable in the custom DLP policy wizard under **Enterprise applications & devices**. This verifies availability in the wizard. Pilot scoping and enforcement have their own tests.

## SharePoint pilot setup

The lab operator reported creating `BFL-Purview-Pilot` using the Team site template without a Microsoft 365 group. The site is the scope for the configuration and file-level checks in the [pilot procedure](../docs/lab-guide.md#1-establish-the-pilot-boundary).

The operator confirmed that `Finance-Test` contains the four synthetic pilot files and that the empty `Retention-Test` library is available for the later retention exercise.

The initial pilot-site scope was **Only people in your organization**. The operator verified the controlled guest in Microsoft Entra ID and confirmed the stored pilot-site settings **Existing guests only**, **Specific people**, and **View**. See the [readiness record](../docs/readiness.md#sharepoint-sharing-baseline) for the before-and-after settings.

### Named-guest access baseline

The first recipient lookup for `ENV-01` displayed a directory group. The operator resolved the intended guest by entering its original external email address and confirmed the named share. The operator then supplied [Stage 0 screenshot 01](stage-00/01-ENV-01-guest-view-BFL-021.png) for the separate guest session. It shows `BFL-021.docx` open in Word for the web with the synthetic meeting agenda visible. This establishes the neutral-file access baseline before DLP enforcement.

| File in Finance-Test | Purpose |
| --- | --- |
| `BFL-005.docx` | SIT-positive fixture for the DLP run |
| `BFL-021.docx` | Neutral fixture for the guest baseline and DLP control |
| `BFL-022.xlsx` | Manual `BFL Finance Confidential` label test |
| `BFL-024.xlsx` | Manual `BFL Internal` label test |

### Internal access baseline

The operator verified that `CONTROL` could open `BFL-005.docx` in view-only mode before DLP enforcement. This is the pre-policy reference for `DLP-03`.

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

The operator published both labels in `BFL Purview Pilot Labels` with `BFL-Purview-Label-Pilot` as the single included group and reported adding `PILOT` to that group. The policy is for manual labeling with no default or required label. The operator observed **Sync completed**. The pilot user's Excel for the web session showed editing mode and both published labels.

### Manual label persistence

**LBL-01 · PASS.** The **Sensitivity** column in `Finance-Test` shows `BFL Finance Confidential` for `BFL-022.xlsx` after manual labeling.

**LBL-02 · PASS.** The same library shows `BFL Internal` for `BFL-024.xlsx` after manual labeling. [Stage 01 screenshot 10](stage-01/10-LBL-01-LBL-02-sharepoint-sensitivity.png) captures both saved labels with **Modified By** hidden.

## DLP rule validation

**SIM-01.** The initial draft reached the review step in simulation mode. The portal rejected submission because external sharing must be the first condition joined by `AND` to the other conditions when blocking external access. The corrected design adds this condition before `BFL Finance Case v2`. The [lab guide](../docs/lab-guide.md#4-simulate-and-enforce-dlp) records the test setup.

The next submission returned `InvalidBlockAccessActionException` with `NotifyUser` missing for the external blocking action. The rule setup now includes the user-notification configuration from the Microsoft example.

### Simulation mode

[Stage 02 screenshot 01](stage-02/01-SIM-01-dlp-policy-in-simulation.png) shows `BFL SharePoint External Access` in **In simulation without notifications** after successful submission. The policy sync status was **Sync in progress** at capture time. The [guest baseline](#guest-access-before-enforcement) confirmed named view-only access for both files.

### Simulation result

**SIM-01 · PASS.** The pilot SharePoint site scan completed at 100%. Purview reported 13 files scanned, 1 of 1 sites scanned, and 0 sites that failed to scan. `BFL-005.docx` was the only match. `BFL-021.docx` had named guest access in the same pilot site, so its no-match outcome is inferred from the completed site scan and the sole reported match. [Stage 02 screenshot 03](stage-02/03-SIM-01-BFL-005-match.png) records the dashboard totals and the matched file.

### Guest access before enforcement

**DLP-01 · PASS.** The same controlled guest opened `BFL-005.docx` and `BFL-021.docx` through their named links in view-only mode while the DLP policy was in simulation. [Stage 02 screenshot 02](stage-02/02-DLP-01-guest-view-BFL-005.png) shows `BFL-005.docx` in Word for the web with **Viewing** selected. The operator separately confirmed the view-only readback for `BFL-021.docx`. The original links were unavailable for the first [enforcement retest](#access-after-policy-activation).

### Access after policy activation

The operator reported **On** and **Sync completed** for `BFL SharePoint External Access`. The original guest links were unavailable, so the operator generated replacement links for both fixtures. The operator confirmed that the replacement link for `BFL-005.docx` uses **People you choose**, the named-recipient sharing option. [Microsoft sharing options](https://support.microsoft.com/en-us/sharepoint/libraries/sharing-files-folders-and-list-items)

The first enforcement retest opened both files. The Audit query for `DlpRuleMatch` on `BFL-005.docx` returned 0 results for 18 November 2026 at 00:00 UTC through 19 November at 14:00 UTC. The file diagnostic rejected the sharing-link format and then reported a failed `Test-DlpPolicies` call with a direct-path format. [Purview diagnostics](https://learn.microsoft.com/en-us/troubleshoot/microsoft-365/purview/diagnostics/purview-compliance-diagnostics#available-diagnostics)

- **DLP-02 · PASS.** On the later guest retest, `BFL-005.docx` returned **403 Forbidden** and `BFL-021.docx` opened in view-only mode. The cropped capture shows the HTTP response. The operator's test readback supplies the file and guest context. `LOG-01` tracks correlation with a DLP rule event. [Stage 02 screenshot 04](stage-02/04-DLP-02-guest-denied-BFL-005.png)
- **DLP-03 · PASS.** The operator confirmed that `CONTROL` opened `BFL-005.docx` after activation.

### DLP audit correlation

**LOG-01 · PASS.** The first query for `DlpRuleMatch` with the `BFL-005.docx` object filter returned 0 records from 00:00 to 15:00 UTC. The follow-up query with record type `ComplianceDLPSharePoint` returned 2 records from 00:00 to 20:00 UTC on 19 November 2026. The reviewed record contained the following fields.

| Field | Recorded value |
| --- | --- |
| Event time | `2026-11-19 14:20:50 UTC` |
| Workload and operation | `SharePoint` · `DLPRuleMatch` |
| File | `BFL-005.docx` |
| Policy | `BFL SharePoint External Access` |
| Rule and mode | `BFL Case SIT – Guest Restriction` · `Enable` |
| Matching conditions | `AccessScope: IncludeExternalUsers` and `BFL Finance Case v2` with confidence score 85 and count 1 |
| Logged actions | `SPAccessTimeControl`, `NotifyUser`, `GenerateAlert` |
| Severity | `Medium` |
| Evaluation source | `DlpPolicyEventBasedAssistantSharePoint` |

The record associates the file with the enabled rule and its logged actions. The event was recorded under an administrative identity. The guest outcome comes from the paired access retest. [DLP audit record schema](https://learn.microsoft.com/en-us/office/office-365-management-api/office-365-management-activity-api-schema#dlp-schema) · [Guest access after policy activation](#access-after-policy-activation)

### Sensitivity-label simulation

**SIM-02 · PASS.** The `BFL SharePoint Label Simulation` finished in simulation mode. In **Items for review**, the SharePoint filter for 20 November 2026 showed three rows under `BFL Confidential Label Match`. All three displayed `BFL-022.xlsx`, and the selected row matched one policy rule. The unlabeled `BFL-021.docx` control was absent from the displayed results. [Stage 02 screenshot 05](stage-02/05-SIM-02-BFL-022-label-match.png)

## Automatic sensitivity label simulation

**AUTO-01 · PASS.** The operator confirmed that the `BFL SharePoint Auto-Label Pilot` simulation was complete. **Items to review** showed one SharePoint candidate, `BFLAutoPilot BFL-007.docx`, with `BFL Finance Case v2`. The policy's target label was `BFL Finance Confidential`. The neutral `BFLAutoPilot BFL-025.docx` was absent from the displayed results. The policy had been scoped to `BFL-Purview-Pilot` with the contextual classifier and the `BFLAutoPilot` file-name marker. [Stage 03 screenshot 01](stage-03/01-AUTO-01-sharepoint-simulation-match.png)

**AUTO-02 · PASS.** The operator uploaded the fresh copies `BFLAutoPilot BFL-001.docx` and `BFLAutoPilot BFL-027.docx` to `Finance-Test`. The SharePoint **Sensitivity** column showed `BFL Finance Confidential` on the positive file and a blank value on the neutral control. The operator confirmed the positive file in **Labeled items** for `BFL SharePoint Auto-Label Pilot`. [Stage 03 screenshot 02](stage-03/02-AUTO-02-sharepoint-label-applied.png)

## Retention label pilot

**RET-01 · PENDING.** The operator created `BFL Retain 30 Days v2` using Security and Compliance PowerShell. `Get-ComplianceTag` confirmed `RetentionDuration: 30`, `RetentionType: TaggedAgeInDays`, and `RetentionAction: Keep`. The operator uploaded `RET-BFL-023.docx` to `Retention-Test`. On 20 November 2026, `BFL Retention Pilot Labels` showed **Enabled (Success)**, **Policy lookup** listed it for the pilot site, and its published label was v2. The pilot user and the site administrator both lacked **Apply label** on the test file. A read of the available labels from SharePoint omitted v2. The file-level test awaits label availability and application. [SharePoint label publication](https://learn.microsoft.com/en-us/purview/create-apply-retention-labels#when-retention-labels-become-available-to-apply)

The portal-created label `BFL Retain 30 Days` displayed 29 days. After recreation with a reported input of 30 days, the publication review and the export still showed 29, and PowerShell confirmed the stored value `RetentionDuration: 29`. The cause of the input-to-storage discrepancy is unverified. [PowerShell label readback](https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-compliancetag)

**RET-02 prerequisite.** In Records Management settings, **Allow users to delete items on SharePoint sites** was **On** under **Deleting content labeled for retention**. The deletion test follows file-level label verification in `RET-01`. [Retention behavior in SharePoint](https://learn.microsoft.com/en-us/purview/retention-policies-sharepoint)

## Rollback verification

**RBK-01 · PASS.** On 20 November 2026, the operator confirmed that the same guest and links from `DLP-02` still produced HTTP 403 for `BFL-005.docx` and view-only access to `BFL-021.docx`. The operator reported synchronization in progress after submitting the change to turn off `BFL SharePoint External Access`. A PowerShell readback confirmed `Mode: Disable` and `DistributionStatus: Pending`. A guest retest while distribution was pending still returned HTTP 403 for `BFL-005.docx` while `BFL-021.docx` opened. The guest later opened `BFL-005.docx` in **Viewing** using the retained enforcement link. The neutral `BFL-021.docx` still opened in **Viewing** using its retained link in the same guest session. The operator confirmed **Off** and **Sync completed** for `BFL SharePoint External Access`. [Stage 04 screenshot 01](stage-04/01-RBK-01-guest-recovery-BFL-005.png)

## Pilot closure

**CLS-01 · PASS.** After verifying recovery in `RBK-01`, the operator revoked the two test sharing links for `BFL-005.docx` and `BFL-021.docx`. A guest-session retest of each retained link returned **This link has been removed**. The operator confirmed **Off** for `BFL SharePoint Auto-Label Pilot`. A SharePoint readback showed these four remaining sensitivity labels in `Finance-Test`.

| File | Sensitivity label |
| --- | --- |
| `BFL-022.xlsx` | BFL Finance Confidential |
| `BFL-024.xlsx` | BFL Internal |
| `BFLAutoPilot BFL-001.docx` | BFL Finance Confidential |
| `BFLAutoPilot BFL-007.docx` | BFL Finance Confidential |

One initial closeout readback showed **Recurring billing: On** with a scheduled conversion to a paid subscription. The two final trial readbacks both showed **Expires on** in the recurring billing section. The supplied excerpts contained the expiry readbacks only. Assignment of the individual expiry dates to product names remains unverified. [Microsoft recurring billing guidance](https://learn.microsoft.com/en-us/microsoft-365/commerce/subscriptions/renew-your-subscription?view=o365-worldwide)

## Captures to collect

| Capture | What to show |
| --- | --- |
| ENV-01 | Named guest opening the neutral fixture in a separate session |
| SIT-01 to SIT-03 | Rule definitions and sanitized per-file classifier outcomes |
| SIM-01 | Pilot-site scope, simulation mode and matched fixture |
| DLP-02 and DLP-03 | Guest allow/deny and an ordinary internal user's access |
| AUTO-01 | Completed simulation showing the expected positive fixture in Items to review |
| RET-01 to RET-03 | Label state, deletion and independently confirmed preservation |
| RBK-01 | Disabled pilot policy and reopened confidential file using the same link tested under enforcement |

Preserve fixture names, policy names, role aliases and UTC timestamps where safe. Redact tenant/account identifiers, URLs and tokens, IP addresses, device identifiers, billing profiles, notifications and other visible browser context. Review the redacted file itself before committing it.
