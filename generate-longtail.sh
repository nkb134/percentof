#!/bin/bash
# Generate long-tail "What is X% of Y" pages
# Usage: bash generate-longtail.sh

cd "$(dirname "$0")"

# Define all X,Y pairs
PAIRS=(
  # 2% - loan/finance
  "2,1000" "2,5000" "2,10000" "2,50000" "2,100000"
  # 3% - commission/fees
  "3,1000" "3,5000" "3,10000" "3,50000" "3,100000"
  # 4% - EPF
  "4,1000" "4,5000" "4,10000" "4,25000" "4,50000"
  # 5% - GST/tax
  "5,500" "5,1000" "5,2000" "5,5000" "5,10000" "5,20000" "5,50000" "5,100000"
  # 6% - interest
  "6,1000" "6,5000" "6,10000" "6,50000" "6,100000"
  # 7% - interest/returns
  "7,1000" "7,5000" "7,10000" "7,50000" "7,100000"
  # 8% - interest/hike
  "8,500" "8,1000" "8,5000" "8,10000" "8,25000" "8,50000" "8,100000"
  # 9% - interest
  "9,1000" "9,5000" "9,10000" "9,50000"
  # 10% - very common
  "10,200" "10,300" "10,400" "10,500" "10,600" "10,800"
  "10,1000" "10,1500" "10,2000" "10,2500" "10,3000" "10,4000" "10,5000"
  "10,6000" "10,8000" "10,10000" "10,15000" "10,20000" "10,25000"
  "10,30000" "10,40000" "10,50000" "10,100000"
  # 12% - GST/EPF
  "12,500" "12,1000" "12,2000" "12,5000" "12,10000" "12,15000" "12,20000"
  "12,25000" "12,30000" "12,50000" "12,100000"
  # 15% - hike/tip
  "15,500" "15,1000" "15,2000" "15,3000" "15,5000" "15,10000" "15,20000"
  "15,25000" "15,30000" "15,50000" "15,100000"
  # 18% - GST
  "18,500" "18,1000" "18,2000" "18,5000" "18,10000" "18,15000" "18,20000"
  "18,25000" "18,30000" "18,50000" "18,100000"
  # 20% - discount/hike
  "20,200" "20,300" "20,400" "20,500" "20,600" "20,800"
  "20,1000" "20,1500" "20,2000" "20,2500" "20,3000" "20,4000" "20,5000"
  "20,8000" "20,10000" "20,15000" "20,20000" "20,25000" "20,50000" "20,100000"
  # 25% - quarter
  "25,200" "25,300" "25,400" "25,500" "25,600" "25,800"
  "25,1000" "25,1200" "25,1500" "25,2000" "25,2500" "25,3000" "25,4000" "25,5000"
  "25,8000" "25,10000" "25,20000" "25,50000" "25,100000"
  # 28% - GST luxury
  "28,500" "28,1000" "28,2000" "28,5000" "28,10000" "28,50000"
  # 30% - discount/tax
  "30,500" "30,1000" "30,1500" "30,2000" "30,3000" "30,5000" "30,10000"
  "30,15000" "30,20000" "30,50000" "30,100000"
  # 33% - one third
  "33,1000" "33,3000" "33,5000" "33,10000" "33,100000"
  # 35% - discount
  "35,1000" "35,2000" "35,5000" "35,10000"
  # 40% - discount
  "40,500" "40,1000" "40,1500" "40,2000" "40,3000" "40,5000" "40,10000" "40,50000"
  # 45% - tax bracket
  "45,1000" "45,5000" "45,10000" "45,50000"
  # 50% - half
  "50,100" "50,200" "50,300" "50,400" "50,500" "50,600" "50,800"
  "50,1000" "50,1500" "50,2000" "50,2500" "50,3000" "50,5000"
  "50,8000" "50,10000" "50,20000" "50,50000" "50,100000"
  # 60% - discount/marks
  "60,500" "60,1000" "60,2000" "60,5000" "60,10000" "60,50000"
  # 65% - marks
  "65,500" "65,1000" "65,5000"
  # 70% - discount/marks
  "70,500" "70,1000" "70,2000" "70,5000" "70,10000" "70,50000"
  # 75% - three quarters
  "75,100" "75,200" "75,300" "75,400" "75,500" "75,1000" "75,2000" "75,5000" "75,10000"
  # 80% - marks/discount
  "80,500" "80,1000" "80,2000" "80,5000" "80,10000"
  # 85% - marks
  "85,500" "85,1000" "85,5000"
  # 90% - marks
  "90,500" "90,1000" "90,5000" "90,10000"
  # 95% - marks
  "95,500" "95,1000"
  # 100% - double
  "100,500" "100,1000" "100,5000"
)

for pair in "${PAIRS[@]}"; do
  IFS=',' read -r X Y <<< "$pair"

  # Calculate result
  RESULT=$(echo "scale=2; $X * $Y / 100" | bc)
  # Remove trailing .00
  RESULT=$(echo "$RESULT" | sed 's/\.00$//')

  DIRNAME="what-is-${X}-percent-of-${Y}"
  mkdir -p "$DIRNAME"

  # Generate related values (nearby Y values)
  # Pick 5 related Y values
  RELATED_YS=()
  if [ "$Y" -le 500 ]; then
    for offset in -200 -100 100 200 500; do
      RY=$((Y + offset))
      if [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ]; then
        RELATED_YS+=("$RY")
      fi
    done
  elif [ "$Y" -le 2000 ]; then
    for offset in -500 -200 200 500 1000; do
      RY=$((Y + offset))
      if [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ]; then
        RELATED_YS+=("$RY")
      fi
    done
  elif [ "$Y" -le 10000 ]; then
    for offset in -2000 -1000 1000 2000 5000; do
      RY=$((Y + offset))
      if [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ]; then
        RELATED_YS+=("$RY")
      fi
    done
  else
    for offset in -10000 -5000 5000 10000 50000; do
      RY=$((Y + offset))
      if [ "$RY" -gt 0 ] && [ "$RY" -ne "$Y" ]; then
        RELATED_YS+=("$RY")
      fi
    done
  fi

  # Build related table rows
  RELATED_ROWS=""
  for RY in "${RELATED_YS[@]}"; do
    RRESULT=$(echo "scale=2; $X * $RY / 100" | bc)
    RRESULT=$(echo "$RRESULT" | sed 's/\.00$//')
    RDIR="what-is-${X}-percent-of-${RY}"
    # Check if we have a page for this
    RLINK="${X}% of ${RY}"
    # Only link if it's one of our target pages
    FOUND=0
    for p2 in "${PAIRS[@]}"; do
      IFS=',' read -r PX PY <<< "$p2"
      if [ "$PX" = "$X" ] && [ "$PY" = "$RY" ]; then
        FOUND=1
        break
      fi
    done
    if [ "$FOUND" -eq 1 ]; then
      RELATED_ROWS="${RELATED_ROWS}<tr><td><a href=\"/${RDIR}/\">${X}% of ${RY}</a></td><td>${RRESULT}</td></tr>"
    else
      RELATED_ROWS="${RELATED_ROWS}<tr><td>${X}% of ${RY}</td><td>${RRESULT}</td></tr>"
    fi
  done

  # Format Y with commas for display
  Y_FORMATTED=$(printf "%'d" "$Y")
  # Format RESULT with commas using printf (handles integers; decimals stay as-is)
  if echo "$RESULT" | grep -q '\.'; then
    RESULT_FORMATTED="$RESULT"
  else
    RESULT_FORMATTED=$(printf "%'d" "$RESULT")
  fi

  cat > "$DIRNAME/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Preconnect for performance -->
  <link rel="preconnect" href="https://www.googletagmanager.com">
  <link rel="preconnect" href="https://pagead2.googlesyndication.com" crossorigin>

  <!-- Google tag (gtag.js) -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-20Y5F7DX7X"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-20Y5F7DX7X');
  </script>

  <!-- Title & Description -->
  <title>What is ${X}% of ${Y_FORMATTED}? Answer: ${RESULT_FORMATTED} | Percentof</title>
  <meta name="description" content="${X}% of ${Y_FORMATTED} is ${RESULT_FORMATTED}. Learn how to calculate ${X} percent of ${Y_FORMATTED} step by step with formula and examples.">

  <!-- Canonical -->
  <link rel="canonical" href="https://percentof.in/${DIRNAME}/">

  <!-- Open Graph -->
  <meta property="og:title" content="What is ${X}% of ${Y_FORMATTED}? Answer: ${RESULT_FORMATTED}">
  <meta property="og:description" content="${X}% of ${Y_FORMATTED} is ${RESULT_FORMATTED}. Step-by-step calculation with formula.">
  <meta property="og:image" content="https://percentof.in/og-image.jpg">
  <meta property="og:url" content="https://percentof.in/${DIRNAME}/">
  <meta property="og:type" content="website">
  <meta property="og:locale" content="en_IN">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="What is ${X}% of ${Y_FORMATTED}? Answer: ${RESULT_FORMATTED}">
  <meta name="twitter:description" content="${X}% of ${Y_FORMATTED} is ${RESULT_FORMATTED}. Step-by-step calculation.">
  <meta name="twitter:image" content="https://percentof.in/og-image.jpg">

  <!-- Favicon -->
  <link rel="icon" href="/favicon.ico">
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">

  <!-- PWA -->
  <link rel="manifest" href="/site.webmanifest">
  <meta name="theme-color" content="#0ea5e9">

  <!-- Styles -->
  <link rel="stylesheet" href="/assets/css/styles.min.css">

  <!-- Calculator Script -->
  <script src="/assets/js/main.min.js" defer></script>

  <!-- Schema: FAQPage -->
  <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is ${X}% of ${Y_FORMATTED}?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "${X}% of ${Y_FORMATTED} is ${RESULT_FORMATTED}. You can calculate this by multiplying ${Y_FORMATTED} by ${X} and dividing by 100: (${X} × ${Y_FORMATTED}) ÷ 100 = ${RESULT_FORMATTED}."
      }
    },
    {
      "@type": "Question",
      "name": "How do you calculate ${X} percent of ${Y_FORMATTED}?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "To calculate ${X}% of ${Y_FORMATTED}, use the formula: Result = (Percentage × Number) ÷ 100. So, (${X} × ${Y_FORMATTED}) ÷ 100 = ${RESULT_FORMATTED}."
      }
    }
  ]
}
</script>

  <!-- Schema: BreadcrumbList -->
  <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://percentof.in/"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Percentage Calculator",
      "item": "https://percentof.in/percentage-calculator/"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "${X}% of ${Y_FORMATTED}",
      "item": "https://percentof.in/${DIRNAME}/"
    }
  ]
}
</script>

  <!-- Google AdSense -->
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-5874718379352488"
     crossorigin="anonymous"></script>
</head>

<body>
<header>
<div class="header">
<div class="logo"><a href="/" style="text-decoration:none;color:inherit;display:flex;gap:10px;align-items:center"><span>%</span>Percentof</a></div>
<div class="tabs">
<a href="/percentage-calculator/">Calculator</a>
</div>
</div>
</header>

<div class="layout">
<main>
<div class="breadcrumb">
<a href="/">Home</a> &rsaquo; <a href="/percentage-calculator/">Percentage Calculator</a> &rsaquo; ${X}% of ${Y_FORMATTED}
</div>

<h1>What is ${X}% of ${Y_FORMATTED}?</h1>

<!-- Answer Hero -->
<div class="answer-hero">
<div class="answer-label">${X}% of ${Y_FORMATTED} =</div>
<div class="answer-value">${RESULT_FORMATTED}</div>
</div>

<!-- Interactive Calculator (pre-filled) -->
<section class="card">
<h2>Calculate ${X}% of ${Y_FORMATTED}</h2>
<div class="inputs">
<div><label>Percentage (%)</label><input id="p1" inputmode="decimal" placeholder="e.g. 25" value="${X}"></div>
<div><label>Amount</label><input id="a1" inputmode="decimal" placeholder="e.g. 400" value="${Y}"></div>
</div>
<div class="result" id="r1" data-example="${X}% of ${Y} is ${RESULT}" data-template="<div class='nl'><span class='pill'>{V1}%</span> of <span class='pill'>{V2}</span> is <b>{R}</b></div>"></div>
</section>

<div class="ad-slot ad-after-calculator">
<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-5874718379352488" data-ad-slot="TODO_AFTER_CALC" data-ad-format="auto" data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>

<!-- Step-by-Step Solution -->
<section class="content">
<h2>How to Calculate ${X}% of ${Y_FORMATTED} — Step by Step</h2>

<p>Calculating ${X} percent of ${Y_FORMATTED} is a common percentage problem. Whether you need this for shopping discounts, tax calculations, exam scores, or financial planning, here is the complete step-by-step solution.</p>

<h3>The Formula</h3>
<p>To find a percentage of a number, use this formula:</p>
<p><code>Result = (Percentage × Number) ÷ 100</code></p>

<div class="step-box">
<div class="step">
<span class="step-num">1</span>
<strong>Write the formula:</strong> Result = (${X} × ${Y_FORMATTED}) ÷ 100
</div>
<div class="step">
<span class="step-num">2</span>
<strong>Multiply:</strong> ${X} × ${Y_FORMATTED} = $(echo "$X * $Y" | bc)
</div>
<div class="step">
<span class="step-num">3</span>
<strong>Divide by 100:</strong> $(echo "$X * $Y" | bc) ÷ 100 = <strong>${RESULT_FORMATTED}</strong>
</div>
</div>

<p>Therefore, <strong>${X}% of ${Y_FORMATTED} is ${RESULT_FORMATTED}</strong>.</p>

<h3>Alternative Method: Decimal Conversion</h3>
<p>You can also convert the percentage to a decimal first:</p>
<ul>
<li>Convert ${X}% to decimal: ${X} ÷ 100 = $(echo "scale=4; $X / 100" | bc | sed 's/0*$//' | sed 's/\.$//')</li>
<li>Multiply: $(echo "scale=4; $X / 100" | bc | sed 's/0*$//' | sed 's/\.$//' ) × ${Y_FORMATTED} = ${RESULT_FORMATTED}</li>
</ul>

<h3>Practical Uses</h3>
<p>Knowing that ${X}% of ${Y_FORMATTED} equals ${RESULT_FORMATTED} is useful in many scenarios:</p>
<ul>
<li><strong>Shopping:</strong> ${X}% discount on an item priced at ₹${Y_FORMATTED} saves you ₹${RESULT_FORMATTED}</li>
<li><strong>Tax:</strong> ${X}% tax on ₹${Y_FORMATTED} amounts to ₹${RESULT_FORMATTED}</li>
<li><strong>Finance:</strong> ${X}% interest on ₹${Y_FORMATTED} earns ₹${RESULT_FORMATTED}</li>
<li><strong>Exams:</strong> Scoring ${RESULT_FORMATTED} out of ${Y_FORMATTED} marks equals ${X}%</li>
</ul>

<div class="ad-slot ad-in-content">
<ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-5874718379352488" data-ad-slot="TODO_IN_CONTENT" data-ad-format="auto" data-full-width-responsive="true"></ins>
<script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
</div>

<h3>Related Calculations: ${X}% of Other Values</h3>
<table class="quick-table">
<thead><tr><th>Calculation</th><th>Result</th></tr></thead>
<tbody>
<tr><td><strong>${X}% of ${Y_FORMATTED}</strong></td><td><strong>${RESULT_FORMATTED}</strong></td></tr>
${RELATED_ROWS}
</tbody>
</table>

<p>Need a different calculation? Use our <a href="/percentage-calculator/">percentage calculator</a> for any percentage computation, or try our specialized calculators for <a href="/gst-calculator/">GST</a>, <a href="/discount-calculator/">discounts</a>, and <a href="/salary-hike-calculator/">salary hikes</a>.</p>
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
echo "Done! Generated ${#PAIRS[@]} long-tail pages."
