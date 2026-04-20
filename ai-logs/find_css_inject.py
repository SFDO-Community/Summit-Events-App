import re

with open('force-app/main/default/staticresources/SummitEventsAssets/fullcalendar.js', encoding='utf-8') as f:
    content = f.read()

print(f"Total length: {len(content)}")

# Search for CSS injection patterns
patterns = ['function xe(', 'xe=function(', 'injectCss', 'createElement(', 'insertRule', 'styleSheet', 'data-fullcalendar']
for p in patterns:
    idx = content.find(p)
    if idx >= 0:
        print(f"\nFound '{p}' at {idx}:")
        print(content[max(0,idx-50):idx+150])

