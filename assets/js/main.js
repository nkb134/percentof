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

  // Calculator definitions: [input1, input2, result, calcFn, type]
  const calculators = [
    { inputs: ['p1', 'a1'], result: 'r1', calc: (a, b) => a / 100 * b },
    { inputs: ['x2', 'y2'], result: 'r2', calc: (a, b) => a / b * 100, suffix: '%' },
    { inputs: ['p3', 'a3'], result: 'r3', calc: (a, b) => b * (1 - a / 100) },
    { inputs: ['p4', 'a4'], result: 'r4', calc: (a, b) => b * (1 + a / 100) },
    { inputs: ['o5', 'n5'], result: 'r5', calc: (a, b) => Math.abs((b - a) / a * 100), suffix: '%' }
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

  // FAQ Accordion
  document.querySelectorAll('.faq-q').forEach(btn => {
    btn.onclick = () => btn.parentElement.classList.toggle('open');
  });

})();
