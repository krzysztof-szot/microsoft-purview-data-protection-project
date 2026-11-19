# Implement and validate the SharePoint pilot

Start with [license and readiness checks](readiness.md). Use aliases `PILOT`, `CONTROL`, `GUEST` and `ANALYST` in records. Record actual timestamps in UTC. Each test refers to an entry in the [test matrix](../tests/test-matrix.csv).

## 1. Establish the pilot boundary

| Item | Procedure |
| --- | --- |
| Scope | Create `BFL-Purview-Pilot` and the `Finance-Test` and `Retention-Test` libraries. Grant `PILOT` edit rights and `CONTROL` sufficient ordinary access to read the test documents. Use a separate analyst role with access to evidence views and an existing authorized admin for configuration. |
| Expected effect | The pilot author can add documents, an internal control can open them and the controlled guest can reach only named files shared with it. |
| Test and evidence | Record site and tenant sharing, site membership and existing DLP policies that apply to it. Use authenticated Specific people links. Capture `BFL-021.docx` opening in the guest's own browser session for `ENV-01`. Record the link privately and publish only the fixture ID and redacted outcome. |
| Rollback | Revoke lab-only guest links and grants, remove temporary group assignments and restore any site setting altered by the pilot after recovery testing. Keep the site available while retention verification is open. |

Microsoft documents that a site cannot be more permissive than its tenant sharing setting. If the guest baseline fails, diagnose the underlying sharing and authentication settings first. A tenant restriction can be recorded as an environment blocker, or the pilot can use a separately documented lab-only internal access restriction with a non-owner control identity. [External sharing in SharePoint](https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off) · [Purview permissions](https://learn.microsoft.com/en-us/purview/permissions)

## 2. Compare two classifiers

| Setting | Baseline `BFL Finance Case v1` | Contextual `BFL Finance Case v2` |
| --- | --- | --- |
| Primary regex | `\b(BFLCASE-[0-9]{6})\b` | Same regex |
| Supporting element | None | String match for `synthetic finance case` within 50 characters |
| Confidence | One pattern at High | One pattern at High |

**Scope and expected effect.** Create two custom SITs under Information Protection → Classifiers → Sensitive info types. Save the same 50-character proximity on both patterns and make the supporting phrase required in v2. v1 should detect the identifier by itself. v2 should require both the identifier and the nearby phrase. Keep v1 out of DLP and auto-labeling policies.

**Test and evidence.** Use the SIT **Test** action on each of the 20 tuning fixtures twice, once per SIT. Record a returned match or an explicit no-match for the tested SIT. Keep service errors or incomplete processing as `PENDING` with a note. Freeze the selected v2 definition before opening the ten holdout files in the test workflow. Run v2 once on that set. Compare the confusion matrices and list the fixture IDs for misclassifications. If you revise the rule after seeing the holdout, reserve a fresh set for another final assessment. Record the classifier settings and redacted result artifacts. [Create a custom SIT](https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type) · [Test a SIT](https://learn.microsoft.com/en-us/purview/sit-test-a-sit)

**Rollback.** Disable or unbind dependent lab policies first. Retire or remove the lab SITs after capturing their final configuration.

## 3. Verify file sensitivity labels

| Item | Procedure |
| --- | --- |
| Scope | Publish the file-scoped labels `BFL Internal` and `BFL Finance Confidential` only to the pilot group. Use manual selection without encryption, mandatory labeling or a default label during this experiment. |
| Expected effect | An explicitly labeled file in the pilot shows its sensitivity label in SharePoint or in a reopened Office file. |
| Test and evidence | Apply `BFL Finance Confidential` to `BFL-022.xlsx` and `BFL Internal` to `BFL-024.xlsx`. Keep `BFL-005.docx` unlabelled for the SIT-based DLP case and `BFL-021.docx` unlabelled as the neutral control. Capture label publication scope and file state after reopening. |
| Rollback | Withdraw the pilot publication and verify its group scope is removed. Remove any labels on synthetic copies through a supported client when needed. Publication withdrawal and existing file metadata require separate checks. |

Check the SharePoint file-label integration setting as part of readiness. An integration change affects the tenant and requires its own recorded scope and rollback. [SharePoint sensitivity label integration](https://learn.microsoft.com/en-us/purview/sensitivity-labels-sharepoint-onedrive-files)

## 4. Simulate and enforce DLP

| Item | Procedure |
| --- | --- |
| Scope | Create `BFL SharePoint External Access` with a custom rule `BFL Case SIT – Guest Restriction`. Select SharePoint only and explicitly include the pilot site. Add `Content is shared from Microsoft 365` with the external-sharing option as the first condition. Join it with `AND` to `Content contains` with `BFL Finance Case v2` at High confidence and a minimum of one instance. Select the access restriction for external users only. Configure a DLP alert if available. |
| User notifications | Enable notifications in the rule and select the standard Office 365 policy tip for the sender, sharer, or last modifier. Leave the Microsoft 365 user override option unchecked. Keep policy tips and automatic promotion off in the simulation mode settings. |
| Expected effect | After processing, a guest with a named-file link can open the neutral control and is denied the SIT-positive file. An internal user with ordinary rights keeps access. Where SharePoint still offers a Share link, the guest's attempt to open the file is the enforcement test. |
| Simulation | Enable simulation first. Give the same controlled guest named **Can view** access to `BFL-005.docx` and `BFL-021.docx` and verify that both links open. Check that the positive fixture matches and the neutral fixture does not match after evaluation. Record policy version, scope and scan time. Use the file-level `Test-DlpPolicies` diagnostic where available to verify evaluation of the neutral file. Record `PENDING` if the neutral outcome is inconclusive. |
| Enforcement | Capture pre-enforcement guest access to both files, then enable the policy. After propagation, re-use the same guest, valid links and file versions. Capture neutral allowed, SIT-positive denied and internal access. Correlate with a Purview event in the [runbook](runbook.md). |
| Rollback | Turn off only the pilot policy and record the change. After propagation, retest the same guest, links and files. Capture restored access before revoking temporary sharing. |

The lab wizard rejected the initial content-only draft. Its validation requires the external-sharing condition first, joined with `AND` to the SIT condition, for the external-only blocking action. The two test files therefore use the same named guest and access level. [External sharing DLP example](https://learn.microsoft.com/en-us/purview/dlp-create-policy-spo-odb-external) · [DLP simulation](https://learn.microsoft.com/en-us/purview/dlp-simulation-mode-learn) · [Test DLP policies](https://learn.microsoft.com/en-us/purview/dlp-test-dlp-policies)

If sensitivity-label conditions are supported, run a separate simulation using the manually labeled `BFL-022.xlsx` and unlabelled `BFL-021.docx`. Use a distinct lab policy in simulation and record it under `SIM-02`. The primary SIT enforcement and rollback remain attributable to the SIT rule.

## 5. Verify retention and optional auto-labeling

| Control | Scope and expected effect | Test and evidence | Rollback |
| --- | --- | --- | --- |
| Retain-only | Publish `BFL Retain 30 Days` only to the pilot site. Choose a regular retain-only label starting from the date labeled, with no record declaration, automatic deletion or Preservation Lock. | Copy `BFL-023.docx` into `Retention-Test` as `RET-BFL-023.docx`. Apply the label and read it back before testing. Have an authorized user delete the copy. Record absence from the live library. After processing, check for a preserved instance using an authorized compliance view, such as an eDiscovery search scoped to the pilot site. Save deletion and preservation as separate results. | Withdraw the pilot publication after evidence collection. Review an applied label separately from its publication and record any retained artifacts. Keep existing holds and preserved copies governed by the service. |
| Service-side auto-labeling | Run only with verified entitlement. Use a pilot-site policy that applies `BFL Finance Confidential` from the contextual SIT. | Compare simulation against the fixture manifest using fresh unlabeled copies. When the simulation supports promotion, turn on the policy and verify labeling on a fresh positive and the state of a fresh neutral after processing. Record the two types of evidence separately. | Disable the pilot auto-labeling policy and verify its state. Inventory labels that remain on files and remove them from disposable test copies if needed. |

Start retention early enough to account for asynchronous evaluation. Check the tenant's setting for deleting content labeled for retention before the user deletion test. If it prevents deletion, record the observed restriction and the blocked preservation check. An item visible in the recycle bin supports the user deletion event. A matching retained copy supports preservation. [Publish and apply retention labels](https://learn.microsoft.com/en-us/purview/create-apply-retention-labels) · [SharePoint retention behavior](https://learn.microsoft.com/en-us/purview/retention-policies-sharepoint) · [Service-side automatic labeling](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically)

## 6. Close the pilot

Use the [capstone](capstone.md) to record allow, deny, triage and recovery before the billing boundary. Export selected evidence, check DLP and auto-labeling modes and verify temporary permissions, labels, guest links, and subscription renewal state. If a trial was activated, verify its end separately from policy state. Existing DLP policies can remain active after a trial ends. An Exchange or Endpoint DLP extension can follow after the core capstone closes and only when licensed. [Purview trial behavior](https://learn.microsoft.com/en-us/purview/purview-trial)
