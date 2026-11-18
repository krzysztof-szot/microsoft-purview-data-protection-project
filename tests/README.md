# Record live test results

Use [test-matrix.csv](test-matrix.csv) as the control register and [classification-results.csv](classification-results.csv) for per-fixture SIT results.

| Status | Use |
| --- | --- |
| PASS | Observed behavior satisfies the expected result and has an evidence reference |
| FAIL | Observed behavior contradicts the expected result |
| PENDING | Test started and processing or evidence is pending |
| NOT_RUN | Test has yet to start or is blocked. Record the reason in `notes` |

For the classifier CSV, set each worked row's `result` to `MATCH`, `NO_MATCH`, `PENDING` or `NOT_RUN`. Use `NO_MATCH` only when the service explicitly returns that result. Capture the observation time in UTC and reference the evidence that supports it. A single sanitized batch record can substantiate multiple rows. From the repo root, run:

```powershell
pwsh -File ./scripts/Measure-SitClassification.ps1
```

The script counts TP, FP, FN and TN against the manifest only when all files in a run have a confirmed result. It shows coverage for incomplete runs and lists misclassified fixture IDs for complete runs.
