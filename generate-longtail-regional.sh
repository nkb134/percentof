#!/bin/bash
# Generate Telugu, Tamil, Bengali long-tail "X% of Y" pages
# Usage: bash generate-longtail-regional.sh

cd "$(dirname "$0")"

# Same curated pairs as Hindi (high-volume queries)
PAIRS=(
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

# Language configs: code, locale, title_template, desc_template, labels...
generate_lang() {
  local LANG_CODE="$1"
  local LOCALE="$2"
  local TITLE_TPL="$3"      # {Y} యొక్క {X} శాతం ఎంత? → uses {X} {Y} {R}
  local DESC_TPL="$4"
  local H1_TPL="$5"
  local HERO_LABEL="$6"     # {Y} యొక్క {X}% =
  local H2_CALC="$7"        # Calculate heading
  local LBL_PCT="$8"        # Percentage label
  local LBL_AMT="$9"        # Amount label
  local PH_PCT="${10}"       # Placeholder pct
  local PH_AMT="${11}"       # Placeholder amt
  local H2_STEP="${12}"      # Step by step heading
  local INTRO="${13}"        # Intro paragraph
  local H3_FORMULA="${14}"
  local FORMULA_TEXT="${15}"  # "Result = (Percentage × Number) ÷ 100"
  local STEP1="${16}"        # "Write the formula"
  local STEP2="${17}"        # "Multiply"
  local STEP3="${18}"        # "Divide by 100"
  local THEREFORE="${19}"    # "Therefore,"
  local H3_ALT="${20}"       # "Alternative method"
  local ALT_CONVERT="${21}"  # "Convert to decimal"
  local ALT_MULTIPLY="${22}" # "Multiply"
  local H3_USES="${23}"      # "Where is it useful?"
  local USE_SHOP="${24}"
  local USE_TAX="${25}"
  local USE_INT="${26}"
  local USE_EXAM="${27}"
  local H3_RELATED="${28}"   # "Related calculations"
  local TH_CALC="${29}"      # "Calculation"
  local TH_RESULT="${30}"    # "Result"
  local CALC_LINK="${31}"    # "calculator" link text
  local CALC_LINK2="${32}"   # "View in English"
  local NAV_HOME="${33}"
  local NAV_CALC="${34}"
  local COUNT=0

  for pair in "${PAIRS[@]}"; do
    IFS=',' read -r X Y <<< "$pair"

    RESULT=$(echo "scale=2; $X * $Y / 100" | bc)
    RESULT=$(echo "$RESULT" | sed 's/\.00$//')
    MULT=$(echo "$X * $Y" | bc)
    DECIMAL=$(echo "scale=4; $X / 100" | bc | sed 's/0*$//' | sed 's/\.$//')

    DIRNAME="${LANG_CODE}/what-is-${X}-percent-of-${Y}"
    EN_DIRNAME="what-is-${X}-percent-of-${Y}"
    mkdir -p "$DIRNAME"

    Y_FORMATTED=$(printf "%'d" "$Y")
    if echo "$RESULT" | grep -q '\.'; then
      RESULT_FORMATTED="$RESULT"
    else
      RESULT_FORMATTED=$(printf "%'d" "$RESULT")
    fi

    # Build related rows
    RELATED_YS=()
    if [ "$Y" -le 500 ]; then
      for offset in -200 -100 100 200 500; do
        RY=$((Y + offset)); [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
      done
    elif [ "$Y" -le 2000 ]; then
      for offset in -500 -200 200 500 1000; do
        RY=$((Y + offset)); [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
      done
    elif [ "$Y" -le 10000 ]; then
      for offset in -2000 -1000 1000 2000 5000; do
        RY=$((Y + offset)); [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
      done
    else
      for offset in -10000 -5000 5000 10000 50000; do
        RY=$((Y + offset)); [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
      done
    fi

    RELATED_ROWS=""
    for RY in "${RELATED_YS[@]}"; do
      RRESULT=$(echo "scale=2; $X * $RY / 100" | bc | sed 's/\.00$//')
      if echo "$RRESULT" | grep -q '\.'; then RRF="$RRESULT"; else RRF=$(printf "%'d" "$RRESULT"); fi
      RY_F=$(printf "%'d" "$RY")
      RDIR="${LANG_CODE}/what-is-${X}-percent-of-${RY}"
      FOUND=0
      for p2 in "${PAIRS[@]}"; do
        IFS=',' read -r PX PY <<< "$p2"
        [ "$PX" = "$X" ] && [ "$PY" = "$RY" ] && FOUND=1 && break
      done
      if [ "$FOUND" -eq 1 ]; then
        RELATED_ROWS="${RELATED_ROWS}<tr><td><a href=\"/${RDIR}/\">${RY_F} — ${X}%</a></td><td>${RRF}</td></tr>"
      else
        RELATED_ROWS="${RELATED_ROWS}<tr><td>${RY_F} — ${X}%</td><td>${RRF}</td></tr>"
      fi
    done

    # Substitute templates
    TITLE=$(echo "$TITLE_TPL" | sed "s/{X}/$X/g; s/{Y}/$Y_FORMATTED/g; s/{R}/$RESULT_FORMATTED/g")
    DESC=$(echo "$DESC_TPL" | sed "s/{X}/$X/g; s/{Y}/$Y_FORMATTED/g; s/{R}/$RESULT_FORMATTED/g")
    H1=$(echo "$H1_TPL" | sed "s/{X}/$X/g; s/{Y}/$Y_FORMATTED/g")
    HERO=$(echo "$HERO_LABEL" | sed "s/{X}/$X/g; s/{Y}/$Y_FORMATTED/g")
    H2C=$(echo "$H2_CALC" | sed "s/{X}/$X/g; s/{Y}/$Y_FORMATTED/g")
    H2S=$(echo "$H2_STEP" | sed "s/{X}/$X/g; s/{Y}/$Y_FORMATTED/g")
    INTRO_P=$(echo "$INTRO" | sed "s/{X}/$X/g; s/{Y}/$Y_FORMATTED/g")
    H3R=$(echo "$H3_RELATED" | sed "s/{X}/$X/g")

    cat > "$DIRNAME/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="${LANG_CODE}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <link rel="preconnect" href="https://www.googletagmanager.com">
  <link rel="preconnect" href="https://pagead2.googlesyndication.com" crossorigin>

  <script async src="https://www.googletagmanager.com/gtag/js?id=G-20Y5F7DX7X"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-20Y5F7DX7X');
  </script>

  <title>${TITLE} | Percentof</title>
  <meta name="description" content="${DESC}">

  <link rel="canonical" href="https://percentof.in/${DIRNAME}/">

  <link rel="alternate" hreflang="${LANG_CODE}" href="https://percentof.in/${DIRNAME}/" />
  <link rel="alternate" hreflang="en" href="https://percentof.in/${EN_DIRNAME}/" />
  <link rel="alternate" hreflang="hi" href="https://percentof.in/hi/${EN_DIRNAME}/" />
  <link rel="alternate" hreflang="te" href="https://percentof.in/te/${EN_DIRNAME}/" />
  <link rel="alternate" hreflang="ta" href="https://percentof.in/ta/${EN_DIRNAME}/" />
  <link rel="alternate" hreflang="bn" href="https://percentof.in/bn/${EN_DIRNAME}/" />
  <link rel="alternate" hreflang="x-default" href="https://percentof.in/${EN_DIRNAME}/" />

  <meta property="og:title" content="${TITLE}">
  <meta property="og:description" content="${DESC}">
  <meta property="og:image" content="https://percentof.in/og-image.jpg">
  <meta property="og:url" content="https://percentof.in/${DIRNAME}/">
  <meta property="og:type" content="website">
  <meta property="og:locale" content="${LOCALE}">

  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${TITLE}">
  <meta name="twitter:description" content="${DESC}">
  <meta name="twitter:image" content="https://percentof.in/og-image.jpg">

  <link rel="icon" href="/favicon.ico">
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">

  <link rel="manifest" href="/site.webmanifest">
  <meta name="theme-color" content="#0ea5e9">

  <link rel="stylesheet" href="/assets/css/styles.min.css">
  <script src="/assets/js/main.min.js" defer></script>

  <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "${H1}",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "${Y_FORMATTED} × ${X} ÷ 100 = ${RESULT_FORMATTED}"
      }
    }
  ]
}
</script>

  <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "${NAV_HOME}", "item": "https://percentof.in/" },
    { "@type": "ListItem", "position": 2, "name": "${NAV_CALC}", "item": "https://percentof.in/${LANG_CODE}/percentage-calculator/" },
    { "@type": "ListItem", "position": 3, "name": "${Y_FORMATTED} — ${X}%", "item": "https://percentof.in/${DIRNAME}/" }
  ]
}
</script>

  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-5874718379352488"
     crossorigin="anonymous"></script>
</head>

<body>
<header>
<div class="header">
<div class="logo"><a href="/" style="text-decoration:none;color:inherit;display:flex;gap:10px;align-items:center"><span>%</span>Percentof</a></div>
<div class="tabs">
<a href="/${LANG_CODE}/percentage-calculator/">${NAV_CALC}</a>
<a href="/${EN_DIRNAME}/">English</a>
</div>
</div>
</header>

<div class="layout">
<main>
<div class="breadcrumb">
<a href="/">${NAV_HOME}</a> &rsaquo; <a href="/${LANG_CODE}/percentage-calculator/">${NAV_CALC}</a> &rsaquo; ${Y_FORMATTED} — ${X}%
</div>

<h1>${H1}</h1>

<div class="answer-hero">
<div class="answer-label">${HERO}</div>
<div class="answer-value">${RESULT_FORMATTED}</div>
</div>

<section class="card">
<h2>${H2C}</h2>
<div class="inputs">
<div><label>${LBL_PCT}</label><input id="p1" inputmode="decimal" placeholder="${PH_PCT}" value="${X}"></div>
<div><label>${LBL_AMT}</label><input id="a1" inputmode="decimal" placeholder="${PH_AMT}" value="${Y}"></div>
</div>
<div class="result" id="r1" data-example="${X}% of ${Y} is ${RESULT}" data-template="<div class='nl'><span class='pill'>{V1}%</span> of <span class='pill'>{V2}</span> = <b>{R}</b></div>"></div>
</section>

<div class="ad-slot ad-after-calculator">
<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-5874718379352488" data-ad-slot="TODO_AFTER_CALC" data-ad-format="auto" data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>

<section class="content">
<h2>${H2S}</h2>

<p>${INTRO_P}</p>

<h3>${H3_FORMULA}</h3>
<p><code>${FORMULA_TEXT}</code></p>

<div class="step-box">
<div class="step">
<span class="step-num">1</span>
<strong>${STEP1}:</strong> (${X} × ${Y_FORMATTED}) ÷ 100
</div>
<div class="step">
<span class="step-num">2</span>
<strong>${STEP2}:</strong> ${X} × ${Y_FORMATTED} = ${MULT}
</div>
<div class="step">
<span class="step-num">3</span>
<strong>${STEP3}:</strong> ${MULT} ÷ 100 = <strong>${RESULT_FORMATTED}</strong>
</div>
</div>

<p>${THEREFORE} <strong>${Y_FORMATTED} — ${X}% = ${RESULT_FORMATTED}</strong></p>

<h3>${H3_ALT}</h3>
<ul>
<li>${ALT_CONVERT}: ${X} ÷ 100 = ${DECIMAL}</li>
<li>${ALT_MULTIPLY}: ${DECIMAL} × ${Y_FORMATTED} = ${RESULT_FORMATTED}</li>
</ul>

<h3>${H3_USES}</h3>
<ul>
<li><strong>${USE_SHOP}:</strong> ₹${Y_FORMATTED} — ${X}% = ₹${RESULT_FORMATTED}</li>
<li><strong>${USE_TAX}:</strong> ₹${Y_FORMATTED} — ${X}% = ₹${RESULT_FORMATTED}</li>
<li><strong>${USE_INT}:</strong> ₹${Y_FORMATTED} — ${X}% = ₹${RESULT_FORMATTED}</li>
<li><strong>${USE_EXAM}:</strong> ${RESULT_FORMATTED} / ${Y_FORMATTED} = ${X}%</li>
</ul>

<div class="ad-slot ad-in-content">
<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-5874718379352488" data-ad-slot="TODO_IN_CONTENT" data-ad-format="auto" data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>

<h3>${H3R}</h3>
<table class="quick-table">
<thead><tr><th>${TH_CALC}</th><th>${TH_RESULT}</th></tr></thead>
<tbody>
<tr><td><strong>${Y_FORMATTED} — ${X}%</strong></td><td><strong>${RESULT_FORMATTED}</strong></td></tr>
${RELATED_ROWS}
</tbody>
</table>

<p><a href="/${LANG_CODE}/percentage-calculator/">${CALC_LINK}</a> | <a href="/${EN_DIRNAME}/">${CALC_LINK2}</a></p>
</section>

</main>
<aside class="sidebar-ad">
<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-5874718379352488" data-ad-slot="TODO_SIDEBAR" data-ad-format="auto" data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</aside>
</div>

<footer>
<div class="footer">
<div class="footer-links">
<a href="/about/">About</a>
<a href="/privacy-policy/">Privacy Policy</a>
<a href="/terms-of-service/">Terms of Service</a>
<a href="/contact/">Contact</a>
<a href="/sitemap.xml">Sitemap</a>
</div>
<div class="footer-copy">&copy; 2025 Percentof. All rights reserved.</div>
</div>
</footer>

</body>
</html>
HTMLEOF

    COUNT=$((COUNT + 1))
  done

  echo "Generated ${COUNT} ${LANG_CODE} pages."
}

# ========================
# TELUGU (te)
# ========================
generate_lang "te" "te_IN" \
  "{Y} యొక్క {X} శాతం ఎంత? జవాబు: {R}" \
  "{Y} యొక్క {X}% = {R}. {Y} యొక్క {X} శాతం లెక్కించడం నేర్చుకోండి — ఫార్ములా మరియు దశల వారీగా." \
  "{Y} యొక్క {X} శాతం ఎంత?" \
  "{Y} యొక్క {X}% =" \
  "{Y} యొక్క {X}% లెక్కించండి" \
  "శాతం (%)" \
  "మొత్తం" \
  "ఉదా. 25" \
  "ఉదా. 400" \
  "{Y} యొక్క {X} శాతం — దశల వారీగా" \
  "{Y} యొక్క {X} శాతం లెక్కించడం చాలా సులభం. షాపింగ్ డిస్కౌంట్, GST, పన్ను, లేదా పరీక్షా మార్కులు లెక్కించాలన్నా — ఇక్కడ పూర్తి పరిష్కారం ఉంది." \
  "ఫార్ములా" \
  "ఫలితం = (శాతం × సంఖ్య) ÷ 100" \
  "ఫార్ములా వ్రాయండి" \
  "గుణించండి" \
  "100తో భాగించండి" \
  "కాబట్టి," \
  "ప్రత్యామ్నాయ పద్ధతి" \
  "దశాంశంగా మార్చండి" \
  "గుణించండి" \
  "ఎక్కడ ఉపయోగపడుతుంది?" \
  "షాపింగ్" \
  "పన్ను/GST" \
  "వడ్డీ" \
  "పరీక్ష" \
  "సంబంధిత గణనలు: ఇతర విలువల {X}%" \
  "గణన" \
  "ఫలితం" \
  "శాతం కాలిక్యులేటర్" \
  "English లో చూడండి" \
  "హోమ్" \
  "శాతం కాలిక్యులేటర్"

# ========================
# TAMIL (ta)
# ========================
generate_lang "ta" "ta_IN" \
  "{Y} இன் {X} சதவீதம் எவ்வளவு? பதில்: {R}" \
  "{Y} இன் {X}% = {R}. {Y} இன் {X} சதவீதம் கணக்கிட கற்றுக்கொள்ளுங்கள் — சூத்திரம் மற்றும் படிப்படியாக." \
  "{Y} இன் {X} சதவீதம் எவ்வளவு?" \
  "{Y} இன் {X}% =" \
  "{Y} இன் {X}% கணக்கிடுங்கள்" \
  "சதவீதம் (%)" \
  "தொகை" \
  "எ.கா. 25" \
  "எ.கா. 400" \
  "{Y} இன் {X} சதவீதம் — படிப்படியாக" \
  "{Y} இன் {X} சதவீதம் கணக்கிடுவது மிக எளிது. ஷாப்பிங் தள்ளுபடி, GST, வரி அல்லது தேர்வு மதிப்பெண்கள் கணக்கிட — இங்கே முழு தீர்வு உள்ளது." \
  "சூத்திரம்" \
  "முடிவு = (சதவீதம் × எண்) ÷ 100" \
  "சூத்திரம் எழுதுங்கள்" \
  "பெருக்குங்கள்" \
  "100 ஆல் வகுக்கவும்" \
  "எனவே," \
  "மாற்று முறை" \
  "தசமத்திற்கு மாற்றுங்கள்" \
  "பெருக்குங்கள்" \
  "எங்கு பயன்படும்?" \
  "ஷாப்பிங்" \
  "வரி/GST" \
  "வட்டி" \
  "தேர்வு" \
  "தொடர்புடைய கணக்குகள்: பிற மதிப்புகளின் {X}%" \
  "கணக்கு" \
  "முடிவு" \
  "சதவீத கணிப்பான்" \
  "English இல் பாருங்கள்" \
  "முகப்பு" \
  "சதவீத கணிப்பான்"

# ========================
# BENGALI (bn)
# ========================
generate_lang "bn" "bn_IN" \
  "{Y} এর {X} শতাংশ কত? উত্তর: {R}" \
  "{Y} এর {X}% = {R}। {Y} এর {X} শতাংশ বের করা শিখুন — সূত্র ও ধাপে ধাপে সমাধান।" \
  "{Y} এর {X} শতাংশ কত?" \
  "{Y} এর {X}% =" \
  "{Y} এর {X}% বের করুন" \
  "শতাংশ (%)" \
  "পরিমাণ" \
  "যেমন ২৫" \
  "যেমন ৪০০" \
  "{Y} এর {X} শতাংশ — ধাপে ধাপে" \
  "{Y} এর {X} শতাংশ বের করা খুবই সহজ। শপিং ডিসকাউন্ট, GST, ট্যাক্স বা পরীক্ষার নম্বর বের করতে — এখানে সম্পূর্ণ সমাধান দেওয়া হলো।" \
  "সূত্র" \
  "ফলাফল = (শতাংশ × সংখ্যা) ÷ ১০০" \
  "সূত্র লিখুন" \
  "গুণ করুন" \
  "১০০ দিয়ে ভাগ করুন" \
  "সুতরাং," \
  "বিকল্প পদ্ধতি" \
  "দশমিকে রূপান্তর করুন" \
  "গুণ করুন" \
  "কোথায় কাজে লাগে?" \
  "শপিং" \
  "ট্যাক্স/GST" \
  "সুদ" \
  "পরীক্ষা" \
  "সম্পর্কিত গণনা: অন্যান্য মানের {X}%" \
  "গণনা" \
  "ফলাফল" \
  "শতাংশ ক্যালকুলেটর" \
  "English এ দেখুন" \
  "হোম" \
  "শতাংশ ক্যালকুলেটর"

echo ""
echo "All regional pages generated!"
