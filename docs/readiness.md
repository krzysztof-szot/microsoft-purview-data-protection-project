# Stage 0 · Tenant and subscription readiness

## Observed on 18 November 2026

| Product | Observed availability | Project use |
| --- | --- | --- |
| Microsoft 365 Business Premium | Active in the lab | Core SharePoint pilot, subject to per-user service plan and role checks |
| Microsoft 365 E5 Information Protection and Governance | Available but unassigned | Candidate for service-side auto-labeling after prerequisite and assignment verification |
| Microsoft 365 E5 | Disabled in the lab | Excluded from the entitlement calculation |

The lab operator confirmed SharePoint Online access, a controlled guest identity and the base subscription's expiration date. Use the earliest confirmed end date among the required subscriptions and reserve the final five days for retesting, evidence export and rollback.

The lab operator reached **Data Loss Prevention → Policies** and confirmed that **SharePoint sites** is selectable in the custom-policy wizard. Deployment permissions and effective policy behavior will be tested during the pilot. See the [sanitized portal observation](../evidence/README.md#dlp-portal-baseline).

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
- **Automatic labeling:** `NOT_RUN` until offer prerequisites, assignments and feature availability are confirmed.
- **Next action:** Finish the read-only checks and record the relevant outcomes in [the test matrix](../tests/test-matrix.csv).
