import json
from pathlib import Path
import shutil
import subprocess

manifest_path = Path("target/manifest.json")
dot_path = Path("target/full_lineage_ui_style.dot")
png_path = Path("target/full_lineage_ui_style.png")

manifest = json.loads(manifest_path.read_text())
nodes = manifest.get("nodes", {})
sources = manifest.get("sources", {})

ALLOWED_TYPES = {"model", "seed", "snapshot"}

TYPE_STYLE = {
    "source":   {"badge_bg": "#14B8A6", "badge_fg": "#062B27", "text": "Source"},
    "model":    {"badge_bg": "#0EA5E9", "badge_fg": "#05293A", "text": "Model"},
    "seed":     {"badge_bg": "#84CC16", "badge_fg": "#1C2A06", "text": "Seed"},
    "snapshot": {"badge_bg": "#F59E0B", "badge_fg": "#3B2405", "text": "Snapshot"},
}

def esc(s: str) -> str:
    return (
        str(s)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )

def node_name(obj):
    return obj.get("name") or obj.get("alias") or obj.get("unique_id")

def html_card(title: str, kind: str) -> str:
    style = TYPE_STYLE.get(kind, TYPE_STYLE["model"])
    badge_text = style["text"]
    return f"""<
<TABLE BORDER="0" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0">
  <TR>
    <TD>
      <TABLE BORDER="1" COLOR="#3B3B44" BGCOLOR="#242226" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0">
        <TR><TD ALIGN="LEFT" BALIGN="LEFT" CELLPADDING="16"><FONT COLOR="#F3F4F6" FACE="Helvetica" POINT-SIZE="20"><B>{esc(title)}</B></FONT></TD></TR>
        <TR><TD HEIGHT="1" BGCOLOR="#3B3B44"></TD></TR>
        <TR>
          <TD ALIGN="LEFT" CELLPADDING="12" BGCOLOR="#302D31">
            <TABLE BORDER="0" CELLBORDER="0" CELLPADDING="0" CELLSPACING="0">
              <TR>
                <TD BGCOLOR="{style["badge_bg"]}" COLOR="{style["badge_bg"]}" BORDER="1" CELLPADDING="8">
                  <FONT COLOR="{style["badge_fg"]}" FACE="Helvetica" POINT-SIZE="14"><B>{badge_text}</B></FONT>
                </TD>
              </TR>
            </TABLE>
          </TD>
        </TR>
      </TABLE>
    </TD>
  </TR>
</TABLE>>"""

with dot_path.open("w") as f:
    f.write("digraph dbt_ui {\n")
    f.write("  rankdir=LR;\n")
    f.write('  graph [bgcolor="#111216", pad="0.5", nodesep="0.8", ranksep="1.0", splines="spline"];\n')
    f.write('  node [shape=plain];\n')
    f.write('  edge [color="#5B5D66", penwidth=1.1, arrowsize=0.7];\n\n')

    for uid, obj in sources.items():
        title = f'{obj.get("source_name", "source")}_{obj.get("name", "")}'
        f.write(f'  "{uid}" [label={html_card(title, "source")}];\n')

    for uid, obj in nodes.items():
        rtype = obj.get("resource_type")
        if rtype not in ALLOWED_TYPES:
            continue
        f.write(f'  "{uid}" [label={html_card(node_name(obj), rtype)}];\n')

    f.write("\n")
    for uid, obj in nodes.items():
        if obj.get("resource_type") not in ALLOWED_TYPES:
            continue
        for dep in obj.get("depends_on", {}).get("nodes", []):
            if dep in nodes or dep in sources:
                f.write(f'  "{dep}" -> "{uid}";\n')

    f.write("}\n")

print(f"Wrote {dot_path}")

dot_bin = shutil.which("dot")
if not dot_bin:
    print("Graphviz 'dot' not found. Install with: brew install graphviz")
    raise SystemExit(1)

subprocess.run([dot_bin, "-Tpng", str(dot_path), "-o", str(png_path)], check=True)
print(f"Wrote {png_path}")