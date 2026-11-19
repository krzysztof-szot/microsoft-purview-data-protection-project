# Stage 0 · Tenant and subscription readiness

## Observed on 18 November 2026

| Product | Observed availability | Project use |
| --- | --- | --- |
| Microsoft 365 Business Premium | Active in the lab | Core SharePoint pilot, subject to per-user service plan and role checks |
| Microsoft 365 E5 Information Protection and Governance | Available but unassigned | Candidate for service-side auto-labeling after prerequisite and assignment verification |
| Microsoft 365 E5 | Disabled in the lab | Excluded from the entitlement calculation |

The lab operator confirmed SharePoint Online access and a controlled guest identity. The dates shown for Business Premium and the E5 Information Protection and Governance add-on are expiration dates. Recurring billing remains to be verified for both. Use the earliest confirmed end date among the required subscriptions and reserve the final five days for retesting, evidence export and rollback.

The lab operator reached **Data Loss Prevention → Policies** and confirmed that **SharePoint sites** is selectable in the custom-policy wizard. Deployment permissions and effective policy behavior will be tested during the pilot. See the [sanitized portal observation](../evidence/README.md#dlp-portal-baseline).

## Pilot entitlement check

On 19 November 2026, the lab operator reported the following assigned licenses and enabled service plans.

| Test role | Assigned license | SharePoint service |
| --- | --- | --- |
| `PILOT` | Microsoft 365 Business Premium with Copilot | SharePoint Online Plan 1 enabled |
| `CONTROL` | Microsoft 365 Business Premium | SharePoint Online Plan 1 enabled |

This readback satisfies `LIC-02`. Site access and effective file permissions are checked separately.

## Advanced labeling entitlement check

The Microsoft Customer Agreement prerequisites list Business Premium as a qualifying base license for E5 Information Protection and Governance. Microsoft's service description includes service-side automatic sensitivity labeling in the add-on. The operator selected `BFL-Purview-Pilot` as the single SharePoint site in the auto-labeling wizard. The [Stage 0 capture](../evidence/stage-00/02-LIC-03-auto-labeling-sharepoint-scope.png) verifies the selectable scope. The operator confirmed that `PILOT` has both Business Premium with Copilot and E5 Information Protection and Governance assigned in **Licenses and apps**. [Product Terms for Microsoft Customer Agreement](https://www.microsoft.com/licensing/terms/en-US/productoffering/MicrosoftPurview/MCA#LicensePrerequisites) · [Purview service description](https://learn.microsoft.com/en-us/office365/servicedescriptions/microsoft-365-service-descriptions/microsoft-365-tenantlevel-services-licensing-guidance/microsoft-purview-service-description#microsoft-purview-information-protection-sensitivity-labeling)

## SharePoint sharing baseline

| Scope | External sharing | Default file link and permission |
| --- | --- | --- |
| SharePoint tenant | Anyone | Anyone with the link |
| `BFL-Purview-Pilot` | Only people in your organization | Inherits the organization link type and Edit default |

The operator supplied this readback before testing guest access. The operator confirmed that the controlled test identity already exists as a guest in Microsoft Entra ID. After updating the pilot site, the operator reopened its settings and confirmed **Existing guests only**, **Specific people**, and a default permission of **View**. This prepares the scope for a named-file access check. [Site sharing settings](https://learn.microsoft.com/en-us/sharepoint/change-external-sharing-site)

## Checks before policy changes

| Check | Read-only verification | Record |
| --- | --- | --- |
| Base subscription | Microsoft 365 admin center → Billing → Your products → Microsoft 365 Business Premium | Record the confirmed expiration and check the recurring billing setting |
| Advanced add-on | Open the E5 Information Protection and Governance product details. Verify its exact offer, prerequisite base SKU under the applicable agreement and recurring billing | Record whether this offer can be used with the pilot user's base license |
| Pilot, control and analysts | Users → Active users → each relevant account → Licenses and apps | Record assigned products and enabled SharePoint service using aliases. Confirm required feature licenses for site owners, members and Purview-role users. Keep the guest view-only |
| Purview solutions | Sign in to [Microsoft Purview](https://purview.microsoft.com/) with the lab work account. Open Solutions → Data Loss Prevention → Policies and Solutions → Information Protection → Classifiers → Sensitive info types. Check Audit and Data Lifecycle Management with the appropriate roles | Record accessible locations and actions. Check role assignments before attributing a missing menu to licensing |
| DLP workload | Create policy → Enterprise applications & devices → Categories: Custom → Regulations: Custom. Advance to Locations and check whether SharePoint sites is selectable. Close the wizard without saving | SharePoint sites selectable, as reported by the lab operator |
| SharePoint baseline | Read the tenant and proposed site sharing settings. Confirm that the site can use a named guest without changing tenant-wide sharing | Record effective sharing level and who can share. Run the neutral-document guest access test once the site is ready |
| Analysts | Check assigned Purview role groups and available DLP alerts, Activity Explorer and Audit views | Record which signal can be investigated and which content details the role can access |

Microsoft lists Business Premium for SharePoint DLP, manual sensitivity labels and published retention labels. Begin with those controls and check Audit (Standard) access. Service-side automatic sensitivity labeling is covered by eligible E5 Information Protection and Governance subscriptions, with offer prerequisites and user assignments still to confirm. The E5 Information Protection and Governance add-on and Microsoft Purview Suite for Business Premium are distinct offers. [Purview service description](https://learn.microsoft.com/en-us/office365/servicedescriptions/microsoft-365-service-descriptions/microsoft-365-tenantlevel-services-licensing-guidance/microsoft-purview-service-description) · [Product Terms for Microsoft Customer Agreement](https://www.microsoft.com/licensing/terms/en-US/productoffering/MicrosoftPurview/MCA) · [Purview licensing guidance](https://www.microsoft.com/licensing/guidance/Microsoft-Purview)

If the core controls are available, proceed on Business Premium. Check tenant-specific offers only if an advanced requirement remains. Microsoft documents a 90-day Purview Suite trial for qualifying E3 configurations. Use the earliest confirmed end date among the required base and add-on subscriptions for any advanced testing. [Purview Suite trial](https://learn.microsoft.com/en-us/purview/purview-trial) · [Recurring billing](https://learn.microsoft.com/en-us/microsoft-365/commerce/subscriptions/renew-your-subscription?view=o365-worldwide)

## Working schedule

| Window | Milestone |
| --- | --- |
| Readiness | Confirm entitlements, roles and sharing. Set up the pilot and test baseline guest access |
| First half of the lab window | Compare the classifiers, freeze the selected rule, start DLP simulation and start retention once the label is available |
| Before the final five days | Validate enforcement, correlate telemetry and run the capstone |
| Final five days | Retest, export evidence, verify withdrawal, and check final billing and policy state |

Move any milestone tied to asynchronous processing according to service observations.

## Readiness decision

- **Core SharePoint pilot:** Base SKU, SharePoint access and guest identity identified. Confirm per-user service plans, product details and policy permissions.
- **Automatic labeling readiness (`LIC-03`):** `PASS`. The pilot add-on assignment and SharePoint wizard scope were verified. File-level automatic labeling is planned for Stage 3.
- **Next action:** Finish the read-only checks and record the relevant outcomes in [the test matrix](../tests/test-matrix.csv).
