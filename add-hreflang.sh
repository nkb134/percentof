#!/bin/bash
# Add hreflang tags to English and Hindi long-tail pages
cd "$(dirname "$0")"

COMMON_PAIRS=(
  "5,1000" "5,5000" "5,10000" "5,50000" "5,100000"
  "8,10000" "8,50000" "8,100000"
  "10,200" "10,500" "10,1000" "10,2000" "10,5000" "10,10000" "10,20000" "10,50000" "10,100000"
  "12,1000" "12,5000" "12,10000" "12,50000" "12,100000"
  "15,1000" "15,2000" "15,5000" "15,10000" "15,50000"
  "18,500" "18,1000" "18,2000" "18,5000" "18,10000" "18,50000" "18,100000"
  "20,500" "20,1000" "20,2000" "20,5000" "20,10000" "20,50000" "20,100000"
  "25,400" "25,1000" "25,2000" "25,5000" "25,10000" "25,50000"
  "28,1000" "28,5000" "28,10000"
  "30,1000" "30,2000" "30,5000" "30,10000" "30,50000"
  "33,1000" "33,5000" "33,10000"
  "40,1000" "40,2000" "40,5000" "40,10000"
  "50,500" "50,1000" "50,2000" "50,5000" "50,10000" "50,50000"
  "60,1000" "60,5000" "60,10000"
  "70,1000" "70,5000"
  "75,100" "75,200" "75,500" "75,1000" "75,5000"
  "80,1000" "80,5000"
  "90,1000" "90,5000"
)

EN_COUNT=0
HI_COUNT=0

for pair in "${COMMON_PAIRS[@]}"; do
  IFS=',' read -r X Y <<< "$pair"
  SLUG="what-is-${X}-percent-of-${Y}"

  # English page
  EN_FILE="${SLUG}/index.html"
  if [ -f "$EN_FILE" ] && ! grep -q 'hreflang' "$EN_FILE" 2>/dev/null; then
    # Insert hreflang block after the <!-- Canonical --> line
    python3 -c "
import sys
f = '${EN_FILE}'
slug = '${SLUG}'
with open(f, 'r') as fh:
    content = fh.read()
hreflang = '''
  <link rel=\"alternate\" hreflang=\"en\" href=\"https://percentof.in/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"hi\" href=\"https://percentof.in/hi/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"te\" href=\"https://percentof.in/te/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"ta\" href=\"https://percentof.in/ta/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"bn\" href=\"https://percentof.in/bn/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"x-default\" href=\"https://percentof.in/{slug}/\" />'''.format(slug=slug)
# Insert after canonical line
canon_line = '<link rel=\"canonical\" href=\"https://percentof.in/' + slug + '/\">'
content = content.replace(canon_line, canon_line + '\n' + hreflang)
with open(f, 'w') as fh:
    fh.write(content)
"
    EN_COUNT=$((EN_COUNT + 1))
  fi

  # Hindi page
  HI_FILE="hi/${SLUG}/index.html"
  if [ -f "$HI_FILE" ] && ! grep -q 'hreflang="te"' "$HI_FILE" 2>/dev/null; then
    python3 -c "
import sys
f = 'hi/${SLUG}/index.html'
slug = '${SLUG}'
with open(f, 'r') as fh:
    content = fh.read()
# Remove old partial hreflang
import re
content = re.sub(r'  <link rel=\"alternate\" hreflang=\"hi\"[^\n]*\n', '', content)
content = re.sub(r'  <link rel=\"alternate\" hreflang=\"en\"[^\n]*\n', '', content)
content = re.sub(r'  <link rel=\"alternate\" hreflang=\"x-default\"[^\n]*\n', '', content)
hreflang = '''
  <link rel=\"alternate\" hreflang=\"en\" href=\"https://percentof.in/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"hi\" href=\"https://percentof.in/hi/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"te\" href=\"https://percentof.in/te/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"ta\" href=\"https://percentof.in/ta/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"bn\" href=\"https://percentof.in/bn/{slug}/\" />
  <link rel=\"alternate\" hreflang=\"x-default\" href=\"https://percentof.in/{slug}/\" />'''.format(slug=slug)
canon_line = '<link rel=\"canonical\" href=\"https://percentof.in/hi/' + slug + '/\">'
content = content.replace(canon_line, canon_line + '\n' + hreflang)
with open(f, 'w') as fh:
    fh.write(content)
" 2>/dev/null
    HI_COUNT=$((HI_COUNT + 1))
  fi
done

echo "Added hreflang to ${EN_COUNT} English pages"
echo "Updated hreflang on ${HI_COUNT} Hindi pages"
