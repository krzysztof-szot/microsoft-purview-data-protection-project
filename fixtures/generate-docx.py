"""Generate the DOCX portion of the synthetic classification corpus."""

import argparse
import json
from pathlib import Path

from docx import Document
from docx.shared import Inches, Pt, RGBColor


def write_fixture(fixture, destination):
    document = Document()
    section = document.sections[0]
    section.left_margin = section.right_margin = Inches(0.9)
    section.top_margin = Inches(0.8)

    normal = document.styles["Normal"]
    title = document.styles["Title"]
    for style in (normal, title):
        style.font.name = "Arial"
        style.font.color.rgb = RGBColor.from_string("000000")
    normal.font.size = Pt(11)
    title.font.size = Pt(26)
    title.paragraph_format.space_after = Pt(14)
    for border in title.element.xpath("./w:pPr/w:pBdr"):
        border.getparent().remove(border)

    properties = document.core_properties
    properties.author = properties.last_modified_by = "Baltic Finance Lab"
    properties.title = fixture["title"]
    properties.subject = "Synthetic lab fixture"
    properties.comments = ""

    document.add_paragraph(fixture["title"], "Title")
    document.add_paragraph(f'Baltic Finance lab fixture {fixture["fixture"]}')
    document.add_paragraph(fixture["intro"])
    document.add_paragraph(fixture["detail"])
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("xb") as stream:
        document.save(stream)


def main():
    root = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=root)
    options = parser.parse_args()

    fixtures = json.loads((root / "docx-content.json").read_text(encoding="utf-8"))
    for fixture in fixtures:
        destination = options.output_dir / fixture["split"] / f'{fixture["fixture"]}.docx'
        if destination.exists():
            print(f"Skipped existing file {destination}")
            continue
        write_fixture(fixture, destination)


if __name__ == "__main__":
    main()
