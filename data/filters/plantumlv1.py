#!/usr/bin/env python
import os
import subprocess
import sys
import hashlib

import panflute as pf

PLANTUML_BIN = os.environ.get("PLANTUML_BIN", "plantuml")


def rel_mkdir_symlink(src, dest):
    dest_dir = os.path.dirname(dest)
    if dest_dir and not os.path.exists(dest_dir):
        os.makedirs(dest_dir)

    if os.path.exists(dest):
        os.remove(dest)

    src = os.path.relpath(src, dest_dir)
    os.symlink(src, dest)


def get_extension(format_, ext, html="png", latex="pdf"):
    """Get appropriate file extension based on output format"""
    if format_ in ["html", "html5"]:
        return html
    elif format_ == "latex":
        return latex
    else:
        return ext

def get_filename4code(prefix, code):
    """Generate filename from code content"""
    return f"{prefix}-{hashlib.sha1(code.encode()).hexdigest()[:8]}"

def calculate_filetype(format_, plantuml_format):
    if plantuml_format:
        # File-type is overwritten via cli or metadata
        if isinstance(plantuml_format, pf.MetaString):
            return plantuml_format.text
        elif isinstance(plantuml_format, pf.MetaInlines):
            return pf.stringify(plantuml_format)
        elif isinstance(plantuml_format, str):
            return plantuml_format
        else:
            # Try to convert to string
            return str(plantuml_format)

    # Default per output-type - use PNG for LaTeX since SVG requires conversion
    # and PlantUML can't generate PDF directly without Batik
    return get_extension(format_, "png", html="svg", latex="png")


def plantuml(elem, doc):
    if isinstance(elem, pf.CodeBlock) and "plantuml" in elem.classes:
        code = elem.text
        
        # Get caption and other attributes
        caption = []
        typef = ""
        
        filename = get_filename4code("plantuml", code)
        plantuml_format_meta = doc.get_metadata("plantuml-format")
        filetype = calculate_filetype(doc.format, plantuml_format_meta)

        # Create plantuml output directory (relative to project root)
        plantuml_dir = "../output/plantuml"
        os.makedirs(plantuml_dir, exist_ok=True)

        src = os.path.join(plantuml_dir, filename + ".uml")
        dest = os.path.join(plantuml_dir, filename + "." + filetype)

        # Generate image only once
        if not os.path.isfile(dest):
            txt = code
            if not txt.startswith("@start"):
                txt = "@startuml\n" + code + "\n@enduml\n"
            
            try:
                with open(src, "w", encoding="utf-8") as f:
                    f.write(txt)

                subprocess.check_call([*PLANTUML_BIN.split(), "-t" + filetype, src])
                pf.debug(f"Created image {dest}")
            except Exception as e:
                pf.debug(f"Error creating PlantUML image: {e}")
                return elem

        # Check for custom filename in attributes
        for attr in elem.attributes:
            if attr[0] == "plantuml-filename":
                link = attr[1]
                rel_mkdir_symlink(dest, link)
                dest = link
                break

        return pf.Para(pf.Image(pf.Str(""), url=dest, title=""))


def main(doc=None):
    return pf.run_filter(plantuml, doc=doc)


if __name__ == "__main__":
    main()