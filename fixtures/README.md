# Synthetic SharePoint test corpus

The [manifest](manifest.csv) contains the labeled ground truth for 30 files. Each file has the reference fixture ID in its content. File names use only the fixture ID, which prevents accidental classifier matches on names.

| Class | Tuning | Holdout | Total |
| --- | ---: | ---: | ---: |
| Finance case | 8 | 4 | 12 |
| Near match | 5 | 3 | 8 |
| Neutral | 7 | 3 | 10 |
| Total | 20 | 10 | 30 |

The `tuning/` and `holdout/` folders contain 15 ready-to-upload XLSX files. Generate the 15 DOCX files from the corpus definition with Python 3 and `python-docx`:

```text
python -m pip install python-docx
python fixtures/generate-docx.py
```

Run both commands from the repo root. Use `py` in place of `python` if your Windows Python launcher uses that name. The generator adds the DOCX fixtures to the paths listed in the manifest.

Keep holdout files out of the classifier optimization loop, then test them once with the frozen rule. Ground truth for a finance case is a properly formed synthetic case ID with the supporting finance context nearby. Near matches include malformed IDs, unrelated context, and an exact phrase deliberately distant from an otherwise valid ID. Match outcomes for those cases are hypotheses to check in Purview.

`expected_guest_access` assumes the underlying SharePoint link already grants access and the contextual SIT rule is enforced. For the label-only test, apply `BFL Finance Confidential` to `BFL-022.xlsx` separately. It is neutral with respect to the SIT.

The optional manual confidentiality label is applied in the tenant during the lab. The distributed files contain only synthetic content.
