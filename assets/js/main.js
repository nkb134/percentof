/**
 * Percentof Calculator - Main JavaScript
 * Handles all calculator logic with localized strings via data attributes
 */

(function() {
  'use strict';

  // Helper: Get element by ID
  const $ = id => document.getElementById(id);

  // Helper: Format number (remove trailing .00)
  const fmt = v => Number(v).toFixed(2).replace(/\.00$/, '');

  // Helper: Format currency with commas
  const fmtCurrency = v => {
    const num = Number(v).toFixed(2).replace(/\.00$/, '');
    return num.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  };

  // Calculator definitions
  const calculators = [
    // Basic percentage calculators (percentage-calculator page)
    { inputs: ['p1', 'a1'], result: 'r1', calc: (a, b) => a / 100 * b },
    { inputs: ['x2', 'y2'], result: 'r2', calc: (a, b) => a / b * 100 },
    { inputs: ['p3', 'a3'], result: 'r3', calc: (a, b) => b * (1 - a / 100) },
    { inputs: ['p4', 'a4'], result: 'r4', calc: (a, b) => b * (1 + a / 100) },
    { inputs: ['o5', 'n5'], result: 'r5', calc: (a, b) => Math.abs((b - a) / a * 100) },

    // GST Calculator (shows GST amount)
    { inputs: ['gstRate', 'gstBase'], result: 'gstResult', calc: (rate, base) => rate / 100 * base },

    // Discount Calculator
    { inputs: ['discPct', 'discPrice'], result: 'discResult', calc: (pct, price) => price * (1 - pct / 100) },

    // Percentage Increase Calculator
    { inputs: ['incPct', 'incVal'], result: 'incResult', calc: (pct, val) => val * (1 + pct / 100) },

    // Percentage Decrease Calculator
    { inputs: ['decPct', 'decVal'], result: 'decResult', calc: (pct, val) => val * (1 - pct / 100) },

    // Salary Hike Calculator
    { inputs: ['hikePct', 'hikeSalary'], result: 'hikeResult', calc: (pct, salary) => salary * (1 + pct / 100) },

    // Cashback Calculator
    { inputs: ['cbPct', 'cbAmount'], result: 'cbResult', calc: (pct, amount) => pct / 100 * amount },

    // Profit Margin Calculator: margin % = ((SP - CP) / SP) × 100
    { inputs: ['marginSP', 'marginCP'], result: 'marginResult', calc: (sp, cp) => ((sp - cp) / sp) * 100 },

    // Markup Calculator: markup % = ((SP - CP) / CP) × 100
    { inputs: ['markupSP', 'markupCP'], result: 'markupResult', calc: (sp, cp) => ((sp - cp) / cp) * 100 },

    // Marks Percentage Calculator: (obtained / total) × 100
    { inputs: ['marksObt', 'marksTotal'], result: 'marksResult', calc: (obt, total) => (obt / total) * 100 },

    // CGPA to Percentage: CGPA × multiplier (default 9.5)
    { inputs: ['cgpaVal', 'cgpaMult'], result: 'cgpaResult', calc: (cgpa, mult) => cgpa * mult }
  ];

  // Initialize calculators
  calculators.forEach(cfg => {
    const input1 = $(cfg.inputs[0]);
    const input2 = $(cfg.inputs[1]);
    const result = $(cfg.result);

    if (!input1 || !input2 || !result) return;

    const example = result.dataset.example || '';
    const template = result.dataset.template || '';
    const isInline = result.classList.contains('inline-result');

    const calculate = () => {
      const v1 = input1.value;
      const v2 = input2.value;

      if (isInline) {
        // Inline calculator mode
        if (!v1 && !v2) {
          // Show greyed-out example hint
          result.textContent = example ? 'e.g. ' + example : '';
          result.classList.add('example-result');
          return;
        }
        if (!v1 || !v2) {
          result.textContent = '?';
          result.classList.add('example-result');
          return;
        }
        const calcResult = fmt(cfg.calc(parseFloat(v1), parseFloat(v2)));
        result.textContent = template.replace('{V1}', v1).replace('{V2}', v2).replace('{R}', calcResult);
        result.classList.remove('example-result');
        return;
      }

      // Card-style calculator mode (specialized pages)
      // Show example when both empty
      if (!v1 && !v2) {
        result.innerHTML = example ? `<div class="example">${example}</div>` : '';
        return;
      }

      // Clear if incomplete
      if (!v1 || !v2) {
        result.innerHTML = '';
        return;
      }

      // Calculate and render
      const calcResult = fmt(cfg.calc(parseFloat(v1), parseFloat(v2)));
      const output = template
        .replace('{V1}', v1)
        .replace('{V2}', v2)
        .replace('{R}', calcResult);

      result.innerHTML = output;
    };

    input1.oninput = calculate;
    input2.oninput = calculate;
    calculate(); // Initial render
  });

  // Three-input calculators (EMI, SIP)
  const threeInputCalcs = [
    {
      inputs: ['emiPrincipal', 'emiRate', 'emiTenure'],
      result: 'emiResult',
      calc: (p, r, n) => {
        const monthlyRate = r / 12 / 100;
        const emi = p * monthlyRate * Math.pow(1 + monthlyRate, n) / (Math.pow(1 + monthlyRate, n) - 1);
        return emi;
      }
    },
    {
      inputs: ['sipAmount', 'sipRate', 'sipYears'],
      result: 'sipResult',
      calc: (amount, rate, years) => {
        const months = years * 12;
        const monthlyRate = rate / 12 / 100;
        const fv = amount * ((Math.pow(1 + monthlyRate, months) - 1) / monthlyRate) * (1 + monthlyRate);
        return fv;
      }
    }
  ];

  threeInputCalcs.forEach(cfg => {
    const input1 = $(cfg.inputs[0]);
    const input2 = $(cfg.inputs[1]);
    const input3 = $(cfg.inputs[2]);
    const result = $(cfg.result);

    if (!input1 || !input2 || !input3 || !result) return;

    const example = result.dataset.example || '';
    const template = result.dataset.template || '';

    const calculate = () => {
      const v1 = input1.value;
      const v2 = input2.value;
      const v3 = input3.value;

      // Show example when all empty
      if (!v1 && !v2 && !v3) {
        result.innerHTML = example ? `<div class="example">${example}</div>` : '';
        return;
      }

      // Clear if incomplete
      if (!v1 || !v2 || !v3) {
        result.innerHTML = '';
        return;
      }

      // Calculate and render
      const calcResult = fmtCurrency(cfg.calc(parseFloat(v1), parseFloat(v2), parseFloat(v3)));
      const output = template
        .replace('{V1}', v1)
        .replace('{V2}', v2)
        .replace('{V3}', v3)
        .replace('{R}', calcResult);

      result.innerHTML = output;
    };

    input1.oninput = calculate;
    input2.oninput = calculate;
    input3.oninput = calculate;
    calculate(); // Initial render
  });

  // FAQ Accordion
  document.querySelectorAll('.faq-q').forEach(btn => {
    btn.onclick = () => btn.parentElement.classList.toggle('open');
  });

  // --- UX Essentials: Copy, Clear, WhatsApp Share ---

  // Inject Clear buttons below each .inputs div
  document.querySelectorAll('.card .inputs').forEach(inputsDiv => {
    const card = inputsDiv.closest('.card');
    if (!card) return;
    const resultDiv = card.querySelector('.result');
    if (!resultDiv) return;

    const clearBtn = document.createElement('button');
    clearBtn.className = 'clear-btn';
    clearBtn.textContent = 'Clear';
    clearBtn.type = 'button';
    clearBtn.onclick = () => {
      inputsDiv.querySelectorAll('input').forEach(inp => {
        inp.value = '';
        inp.dispatchEvent(new Event('input'));
      });
    };
    inputsDiv.after(clearBtn);
  });

  // Helper: extract plain text result from a result div
  function getResultText(resultDiv) {
    const nlEl = resultDiv.querySelector('.nl');
    if (!nlEl) return '';
    return nlEl.textContent.trim();
  }

  // Inject Copy + WhatsApp Share buttons inside result divs
  // We use a MutationObserver with a guard flag to prevent infinite loops
  document.querySelectorAll('.result').forEach(resultDiv => {
    let updating = false;
    const observer = new MutationObserver(() => {
      if (updating) return;
      updating = true;

      // Remove old action buttons
      const oldActions = resultDiv.querySelector('.result-actions');
      if (oldActions) oldActions.remove();

      const nlEl = resultDiv.querySelector('.nl');
      if (!nlEl) { updating = false; return; } // No result yet

      const actions = document.createElement('div');
      actions.className = 'result-actions';

      // Copy button
      const copyBtn = document.createElement('button');
      copyBtn.className = 'copy-btn';
      copyBtn.type = 'button';
      copyBtn.innerHTML = '📋 Copy';
      copyBtn.onclick = () => {
        const text = getResultText(resultDiv);
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text).then(() => {
            copyBtn.innerHTML = '✓ Copied!';
            copyBtn.classList.add('copied');
            setTimeout(() => {
              copyBtn.innerHTML = '📋 Copy';
              copyBtn.classList.remove('copied');
            }, 1500);
          });
        } else {
          const ta = document.createElement('textarea');
          ta.value = text;
          ta.style.position = 'fixed';
          ta.style.opacity = '0';
          document.body.appendChild(ta);
          ta.select();
          document.execCommand('copy');
          document.body.removeChild(ta);
          copyBtn.innerHTML = '✓ Copied!';
          copyBtn.classList.add('copied');
          setTimeout(() => {
            copyBtn.innerHTML = '📋 Copy';
            copyBtn.classList.remove('copied');
          }, 1500);
        }
      };
      actions.appendChild(copyBtn);

      // WhatsApp Share button
      const shareBtn = document.createElement('button');
      shareBtn.className = 'share-btn';
      shareBtn.type = 'button';
      shareBtn.innerHTML = '💬 WhatsApp';
      shareBtn.onclick = () => {
        const text = getResultText(resultDiv);
        const url = 'https://wa.me/?text=' + encodeURIComponent(text + ' — calculated on percentof.in');
        window.open(url, '_blank');
      };
      actions.appendChild(shareBtn);

      resultDiv.appendChild(actions);
      updating = false;
    });

    observer.observe(resultDiv, { childList: true, subtree: true });
  });

  // --- Auto-focus first input ---
  const firstInline = document.querySelector('.inline-calcs input');
  const firstCard = document.querySelector('.card .inputs input');
  const focusTarget = firstInline || firstCard;
  if (focusTarget && !new URLSearchParams(window.location.search).get('q')) {
    focusTarget.focus();
  }

  // --- Lazy-load AdSense ---
  // Load AdSense script only after user scrolls/interacts (improves initial page speed)
  const adsLoaded = { done: false };
  function loadAds() {
    if (adsLoaded.done) return;
    adsLoaded.done = true;
    // Inject AdSense script dynamically
    const adScript = document.createElement('script');
    adScript.src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-5874718379352488';
    adScript.async = true;
    adScript.crossOrigin = 'anonymous';
    adScript.onload = () => {
      document.querySelectorAll('.adsbygoogle').forEach(() => {
        try { (window.adsbygoogle = window.adsbygoogle || []).push({}); } catch(e) {}
      });
    };
    document.head.appendChild(adScript);
  }
  window.addEventListener('scroll', loadAds, { once: true, passive: true });
  window.addEventListener('touchstart', loadAds, { once: true, passive: true });
  setTimeout(loadAds, 4000);

  // --- Number formatting with commas in inputs ---
  document.querySelectorAll('input[inputmode="decimal"]').forEach(input => {
    input.addEventListener('focus', () => {
      // Strip commas on focus so user can edit raw number
      input.value = input.value.replace(/,/g, '');
    });
    input.addEventListener('blur', () => {
      const raw = input.value.replace(/,/g, '');
      if (raw && !isNaN(raw)) {
        const parts = raw.split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        input.value = parts.join('.');
      }
    });
  });

  // --- Query Parameter Auto-Fill ---
  // Handles ?q=25+percent+of+400 or ?q=25%25+of+400
  // Pre-fills calculator inputs on homepage/calculator pages
  const params = new URLSearchParams(window.location.search);
  const q = params.get('q');
  if (q) {
    // Match patterns: "X% of Y", "X percent of Y", "what is X% of Y"
    const match = q.match(/(?:what\s+is\s+)?(\d+(?:\.\d+)?)\s*(?:%|percent)\s*(?:of)\s*(\d+(?:\.\d+)?)/i);
    if (match) {
      const pInput = $('p1');
      const aInput = $('a1');
      if (pInput && aInput) {
        pInput.value = match[1];
        aInput.value = match[2];
        pInput.dispatchEvent(new Event('input'));
      }
    }
  }

  // --- Recent Calculations History (localStorage) ---
  const HISTORY_KEY = 'percentof_history';
  const MAX_HISTORY = 10;

  function getHistory() {
    try { return JSON.parse(localStorage.getItem(HISTORY_KEY)) || []; } catch(e) { return []; }
  }

  function saveToHistory(text) {
    if (!text || text === '?') return;
    const history = getHistory();
    // Avoid duplicates at top
    if (history[0] === text) return;
    // Remove if exists elsewhere
    const idx = history.indexOf(text);
    if (idx > 0) history.splice(idx, 1);
    history.unshift(text);
    if (history.length > MAX_HISTORY) history.pop();
    try { localStorage.setItem(HISTORY_KEY, JSON.stringify(history)); } catch(e) {}
    renderHistory();
  }

  function renderHistory() {
    const container = document.querySelector('.recent-history');
    if (!container) return;
    const history = getHistory();
    if (history.length === 0) {
      container.style.display = 'none';
      return;
    }
    container.style.display = '';
    const list = container.querySelector('.history-list');
    if (!list) return;
    list.innerHTML = history.map(h => `<span class="history-item">${h}</span>`).join('');
  }

  // Hook into inline calculators to save results
  document.querySelectorAll('.inline-result').forEach(result => {
    const obs = new MutationObserver(() => {
      if (!result.classList.contains('example-result') && result.textContent && result.textContent !== '?') {
        saveToHistory(result.textContent.trim());
      }
    });
    obs.observe(result, { childList: true, characterData: true, subtree: true });
  });

  // Inject history section on homepage/calculator pages
  const inlineSection = document.querySelector('.inline-calcs');
  if (inlineSection) {
    const historyDiv = document.createElement('div');
    historyDiv.className = 'recent-history';
    historyDiv.innerHTML = '<div class="history-label">Recent:</div><div class="history-list"></div>';
    inlineSection.after(historyDiv);
    renderHistory();
  }

})();
