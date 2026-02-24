#!/bin/bash
# Generate Hindi long-tail "X% of Y" pages
# Targets: "1000 ka 10 percent kitna hota hai" type queries
# Usage: bash generate-longtail-hi.sh

cd "$(dirname "$0")"

# Top Hindi search pairs (high volume, zero competition)
PAIRS=(
  # Common percentages with round numbers
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

for pair in "${PAIRS[@]}"; do
  IFS=',' read -r X Y <<< "$pair"

  RESULT=$(echo "scale=2; $X * $Y / 100" | bc)
  RESULT=$(echo "$RESULT" | sed 's/\.00$//')

  DIRNAME="hi/what-is-${X}-percent-of-${Y}"
  mkdir -p "$DIRNAME"

  # Format with Indian commas using printf
  Y_FORMATTED=$(printf "%'d" "$Y")
  if echo "$RESULT" | grep -q '\.'; then
    RESULT_FORMATTED="$RESULT"
  else
    RESULT_FORMATTED=$(printf "%'d" "$RESULT")
  fi

  # English dirname for linking
  EN_DIRNAME="what-is-${X}-percent-of-${Y}"

  # Related values
  RELATED_YS=()
  if [ "$Y" -le 500 ]; then
    for offset in -200 -100 100 200 500; do
      RY=$((Y + offset))
      [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
    done
  elif [ "$Y" -le 2000 ]; then
    for offset in -500 -200 200 500 1000; do
      RY=$((Y + offset))
      [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
    done
  elif [ "$Y" -le 10000 ]; then
    for offset in -2000 -1000 1000 2000 5000; do
      RY=$((Y + offset))
      [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
    done
  else
    for offset in -10000 -5000 5000 10000 50000; do
      RY=$((Y + offset))
      [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ] && RELATED_YS+=("$RY")
    done
  fi

  RELATED_ROWS=""
  for RY in "${RELATED_YS[@]}"; do
    RRESULT=$(echo "scale=2; $X * $RY / 100" | bc)
    RRESULT=$(echo "$RRESULT" | sed 's/\.00$//')
    if echo "$RRESULT" | grep -q '\.'; then
      RRESULT_F="$RRESULT"
    else
      RRESULT_F=$(printf "%'d" "$RRESULT")
    fi
    RY_F=$(printf "%'d" "$RY")
    RDIR="hi/what-is-${X}-percent-of-${RY}"
    FOUND=0
    for p2 in "${PAIRS[@]}"; do
      IFS=',' read -r PX PY <<< "$p2"
      [ "$PX" = "$X" ] && [ "$PY" = "$RY" ] && FOUND=1 && break
    done
    if [ "$FOUND" -eq 1 ]; then
      RELATED_ROWS="${RELATED_ROWS}<tr><td><a href=\"/${RDIR}/\">${RY_F} का ${X}%</a></td><td>${RRESULT_F}</td></tr>"
    else
      RELATED_ROWS="${RELATED_ROWS}<tr><td>${RY_F} का ${X}%</td><td>${RRESULT_F}</td></tr>"
    fi
  done

  cat > "$DIRNAME/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="hi">
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

  <title>${Y_FORMATTED} का ${X} प्रतिशत कितना होता है? उत्तर: ${RESULT_FORMATTED} | Percentof</title>
  <meta name="description" content="${Y_FORMATTED} का ${X}% = ${RESULT_FORMATTED} होता है। ${Y_FORMATTED} का ${X} प्रतिशत निकालना सीखें — फॉर्मूला और स्टेप बाय स्टेप हल।">

  <link rel="canonical" href="https://percentof.in/${DIRNAME}/">

  <link rel="alternate" hreflang="hi" href="https://percentof.in/${DIRNAME}/" />
  <link rel="alternate" hreflang="en" href="https://percentof.in/${EN_DIRNAME}/" />
  <link rel="alternate" hreflang="x-default" href="https://percentof.in/${EN_DIRNAME}/" />

  <meta property="og:title" content="${Y_FORMATTED} का ${X}% कितना होता है? उत्तर: ${RESULT_FORMATTED}">
  <meta property="og:description" content="${Y_FORMATTED} का ${X} प्रतिशत ${RESULT_FORMATTED} होता है। फॉर्मूला और स्टेप बाय स्टेप हल।">
  <meta property="og:image" content="https://percentof.in/og-image.jpg">
  <meta property="og:url" content="https://percentof.in/${DIRNAME}/">
  <meta property="og:type" content="website">
  <meta property="og:locale" content="hi_IN">

  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${Y_FORMATTED} का ${X}% कितना होता है? उत्तर: ${RESULT_FORMATTED}">
  <meta name="twitter:description" content="${Y_FORMATTED} का ${X} प्रतिशत ${RESULT_FORMATTED} होता है।">
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
      "name": "${Y_FORMATTED} का ${X} प्रतिशत कितना होता है?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "${Y_FORMATTED} का ${X}% = ${RESULT_FORMATTED} होता है। फॉर्मूला: (${X} × ${Y_FORMATTED}) ÷ 100 = ${RESULT_FORMATTED}"
      }
    },
    {
      "@type": "Question",
      "name": "${Y_FORMATTED} ka ${X} percent kitna hota hai?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "${Y_FORMATTED} ka ${X} percent ${RESULT_FORMATTED} hota hai. Formula: (${X} × ${Y_FORMATTED}) ÷ 100 = ${RESULT_FORMATTED}"
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
    {
      "@type": "ListItem",
      "position": 1,
      "name": "होम",
      "item": "https://percentof.in/"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "प्रतिशत कैलकुलेटर",
      "item": "https://percentof.in/hi/percentage-calculator/"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "${Y_FORMATTED} का ${X}%",
      "item": "https://percentof.in/${DIRNAME}/"
    }
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
<a href="/hi/percentage-calculator/">हिन्दी</a>
<a href="/${EN_DIRNAME}/">English</a>
</div>
</div>
</header>

<div class="layout">
<main>
<div class="breadcrumb">
<a href="/">होम</a> &rsaquo; <a href="/hi/percentage-calculator/">प्रतिशत कैलकुलेटर</a> &rsaquo; ${Y_FORMATTED} का ${X}%
</div>

<h1>${Y_FORMATTED} का ${X} प्रतिशत कितना होता है?</h1>

<div class="answer-hero">
<div class="answer-label">${Y_FORMATTED} का ${X}% =</div>
<div class="answer-value">${RESULT_FORMATTED}</div>
</div>

<section class="card">
<h2>${Y_FORMATTED} का ${X}% निकालें</h2>
<div class="inputs">
<div><label>प्रतिशत (%)</label><input id="p1" inputmode="decimal" placeholder="जैसे 25" value="${X}"></div>
<div><label>राशि</label><input id="a1" inputmode="decimal" placeholder="जैसे 400" value="${Y}"></div>
</div>
<div class="result" id="r1" data-example="${X}% of ${Y} is ${RESULT}" data-template="<div class='nl'><span class='pill'>{V1}%</span> of <span class='pill'>{V2}</span> = <b>{R}</b></div>"></div>
</section>

<div class="ad-slot ad-after-calculator">
<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-5874718379352488" data-ad-slot="TODO_AFTER_CALC" data-ad-format="auto" data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>

<section class="content">
<h2>${Y_FORMATTED} का ${X} प्रतिशत कैसे निकालें — स्टेप बाय स्टेप</h2>

<p>${Y_FORMATTED} का ${X} प्रतिशत निकालना बहुत आसान है। चाहे आपको शॉपिंग डिस्काउंट, GST, टैक्स, या परीक्षा के अंक निकालने हों — नीचे पूरा हल दिया गया है।</p>

<h3>फॉर्मूला</h3>
<p>किसी संख्या का प्रतिशत निकालने का फॉर्मूला:</p>
<p><code>परिणाम = (प्रतिशत × संख्या) ÷ 100</code></p>

<div class="step-box">
<div class="step">
<span class="step-num">1</span>
<strong>फॉर्मूला लिखें:</strong> परिणाम = (${X} × ${Y_FORMATTED}) ÷ 100
</div>
<div class="step">
<span class="step-num">2</span>
<strong>गुणा करें:</strong> ${X} × ${Y_FORMATTED} = $(echo "$X * $Y" | bc)
</div>
<div class="step">
<span class="step-num">3</span>
<strong>100 से भाग दें:</strong> $(echo "$X * $Y" | bc) ÷ 100 = <strong>${RESULT_FORMATTED}</strong>
</div>
</div>

<p>इसलिए, <strong>${Y_FORMATTED} का ${X}% = ${RESULT_FORMATTED}</strong> होता है।</p>

<h3>दूसरा तरीका: दशमलव में बदलें</h3>
<ul>
<li>${X}% को दशमलव में बदलें: ${X} ÷ 100 = $(echo "scale=4; $X / 100" | bc | sed 's/0*$//' | sed 's/\.$//')</li>
<li>गुणा करें: $(echo "scale=4; $X / 100" | bc | sed 's/0*$//' | sed 's/\.$//' ) × ${Y_FORMATTED} = ${RESULT_FORMATTED}</li>
</ul>

<h3>कहाँ काम आता है?</h3>
<ul>
<li><strong>शॉपिंग:</strong> ₹${Y_FORMATTED} पर ${X}% छूट = ₹${RESULT_FORMATTED} की बचत</li>
<li><strong>GST/टैक्स:</strong> ₹${Y_FORMATTED} पर ${X}% टैक्स = ₹${RESULT_FORMATTED}</li>
<li><strong>ब्याज:</strong> ₹${Y_FORMATTED} पर ${X}% ब्याज = ₹${RESULT_FORMATTED}</li>
<li><strong>परीक्षा:</strong> ${Y_FORMATTED} में से ${RESULT_FORMATTED} अंक = ${X}%</li>
</ul>

<div class="ad-slot ad-in-content">
<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-5874718379352488" data-ad-slot="TODO_IN_CONTENT" data-ad-format="auto" data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>

<h3>संबंधित गणनाएँ: अन्य राशियों का ${X}%</h3>
<table class="quick-table">
<thead><tr><th>गणना</th><th>परिणाम</th></tr></thead>
<tbody>
<tr><td><strong>${Y_FORMATTED} का ${X}%</strong></td><td><strong>${RESULT_FORMATTED}</strong></td></tr>
${RELATED_ROWS}
</tbody>
</table>

<p>और गणनाओं के लिए हमारा <a href="/hi/percentage-calculator/">प्रतिशत कैलकुलेटर</a> इस्तेमाल करें, या <a href="/${EN_DIRNAME}/">English में देखें</a>।</p>
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

  echo "Generated: $DIRNAME/index.html"
done

echo ""
echo "Done! Generated ${#PAIRS[@]} Hindi long-tail pages."
