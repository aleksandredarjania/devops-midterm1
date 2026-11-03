"""ბონუსი: logs/health.log-დან აგენერირებს status.html დეშბორდს."""
from pathlib import Path

root = Path(__file__).resolve().parent.parent
lines = []
log = root / "logs" / "health.log"
if log.exists():
    lines = [l for l in log.read_text(encoding="utf-8").splitlines() if l.strip()]

last = lines[-1] if lines else "no data"
up = " UP " in last
color = "#2ea44f" if up else "#d73a49"
rows = "".join(
    f"<tr><td>{'<br>'.join([l])}</td></tr>" for l in reversed(lines[-20:])
)
html = f"""<!doctype html><html><head><meta charset="utf-8"><title>Status</title>
<style>body{{font-family:sans-serif;max-width:800px;margin:40px auto}}
.badge{{display:inline-block;padding:12px 24px;color:#fff;border-radius:8px;
background:{color};font-size:24px}}td{{border-bottom:1px solid #ddd;padding:6px;
font-family:monospace;font-size:13px}}</style></head><body>
<h1>Application Status</h1>
<div class="badge">{'UP' if up else 'DOWN'}</div>
<p>Last check: {last}</p><h3>Last 20 checks</h3><table>{rows}</table>
</body></html>"""
(root / "status.html").write_text(html, encoding="utf-8")
print("status.html generated")
