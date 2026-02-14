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
    { inputs: ['cbPct', 'cbAmount'], result: 'cbResult', calc: (pct, amount) => pct / 100 * amount }
  ];

  // Initialize calculators
  calculators.forEach(cfg => {
    const input1 = $(cfg.inputs[0]);
    const input2 = $(cfg.inputs[1]);
    const result = $(cfg.result);

    if (!input1 || !input2 || !result) return;

    const example = result.dataset.example || '';
    const template = result.dataset.template || '';

    const calculate = () => {
      const v1 = input1.value;
      const v2 = input2.value;

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

})();
