"""
Extracts all CSS injected by FullCalendar's xe() function from the bundle,
writes it to a standalone CSS file, and writes a patched JS that no-ops xe().
"""
import re

JS_INPUT  = 'force-app/main/default/staticresources/SummitEventsAssets/fullcalendar.js'
CSS_OUT   = 'force-app/main/default/staticresources/SummitEventsAssets/css/fullcalendar-extracted.css'
JS_OUT    = 'force-app/main/default/staticresources/SummitEventsAssets/fullcalendar-patched.js'

with open(JS_INPUT, encoding='utf-8') as f:
    source = f.read()

print(f"Source length: {len(source)} chars")

# -----------------------------------------------------------------------
# Step 1 – collect all CSS strings passed to xe("...") / xe('...')
# The bundle calls xe() with single long CSS strings.
# We walk through and extract each argument manually to handle escaped quotes.
# -----------------------------------------------------------------------
css_blocks = []
search_start = 0

while True:
    call_idx = source.find('xe(', search_start)
    if call_idx == -1:
        break

    # Make sure it's actually a call (not part of a variable name like dxe or xe2)
    pre_char = source[call_idx - 1] if call_idx > 0 else ' '
    if pre_char.isalnum() or pre_char == '_':
        search_start = call_idx + 1
        continue

    arg_start = call_idx + 3   # position of the opening quote (or whatever follows xe()
    if arg_start >= len(source):
        break

    quote_char = source[arg_start]
    if quote_char not in ('"', "'", '`'):
        search_start = call_idx + 1
        continue

    # Walk forward to find the closing (unescaped) quote
    idx = arg_start + 1
    while idx < len(source):
        c = source[idx]
        if c == '\\':
            idx += 2          # skip escaped character
            continue
        if c == quote_char:
            break
        idx += 1

    css_text = source[arg_start + 1 : idx]   # content between the quotes

    # Only keep if it looks like CSS (contains { or :)
    if '{' in css_text or ':' in css_text:
        # Un-escape common JS escape sequences
        css_text = css_text.replace('\\n', '\n').replace('\\t', '\t').replace("\\'", "'").replace('\\"', '"')
        css_blocks.append(css_text)

    search_start = idx + 1

print(f"Extracted {len(css_blocks)} CSS blocks")

combined_css = '\n'.join(css_blocks)
with open(CSS_OUT, 'w', encoding='utf-8') as f:
    f.write('/* FullCalendar v6.1.20 - CSS extracted from JS bundle for LWC compatibility */\n')
    f.write(combined_css)

print(f"CSS written to: {CSS_OUT}  ({len(combined_css)} chars)")

# -----------------------------------------------------------------------
# Step 2 – patch the JS: prepend a no-op override for xe and _e
# The xe() function pushes CSS to Ce[] and forwards to Te().
# We override xe so it does nothing (CSS is loaded separately).
# We also override _e (the style-element factory) to be safe.
# -----------------------------------------------------------------------
PATCH_HEADER = """\
/*!
 * LWC-PATCHED: CSS injection neutralized.
 * xe() and _e() are no-ops; CSS is loaded separately via loadStyle().
 */
var xe=function(){};
var _e=function(){};
"""

patched = PATCH_HEADER + source

with open(JS_OUT, 'w', encoding='utf-8') as f:
    f.write(patched)

print(f"Patched JS written to: {JS_OUT}")
print("Done.")

