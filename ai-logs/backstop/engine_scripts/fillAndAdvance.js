'use strict';

/**
 * BackstopJS onReadyScript — Summit Events VF multi-step registration flow.
 *
 * Usage: add to any scenario that STARTS at the Register page but needs a
 * screenshot of a LATER page in the flow.
 *
 *   "onReadyScript": "fillAndAdvance.js",
 *   "targetPage":    "additionalquestions"   ← page key to stop on
 *
 * targetPage keys:
 *   register | additionalquestions | appointments | guests | donation | submit | confirmation
 *
 * How it works:
 *   1. Detects the current page from the URL.
 *   2. If already on the target, stops immediately (screenshot taken by BackstopJS).
 *   3. Overrides checkForm() so client-side validation never blocks navigation.
 *   4. Fills required fields / clicks Next and waits for the server round-trip.
 *   5. Repeats up to 8 times until target is reached (or gets stuck).
 *
 * VF element ID selectors use [id$=":fieldId"] because Salesforce VF prefixes
 * all element IDs with the component hierarchy, e.g. "SummitEventRegisterForm:firstName".
 * The $= (ends-with) selector matches regardless of the prefix.
 */

module.exports = async (page, scenario) => {
  const target = (scenario.targetPage || '').toLowerCase();
  const sleep = ms => new Promise(r => setTimeout(r, ms));

  /** Map URL fragments → page keys */
  const getPage = () => {
    const url = page.url().toLowerCase();
    if (url.includes('additionalquestions'))      return 'additionalquestions';
    if (url.includes('registerappointments'))     return 'appointments';
    if (url.includes('registerguests'))           return 'guests';
    if (url.includes('summiteventsdonation'))     return 'donation';
    if (url.includes('summiteventssubmit'))       return 'submit';
    if (url.includes('summiteventsconfirmation')) return 'confirmation';
    if (url.includes('cancelreview'))             return 'cancelreview';
    return 'register';
  };

  /**
   * 1) Strip all HTML5 required attributes (prevents browser tooltip blocking).
   * 2) Fill every empty text/email/tel/textarea with a placeholder so VF's
   *    server-side required-field validator doesn't re-render the same page.
   * 3) Select the first non-blank option in every empty <select>.
   * 4) Override all known JS validators to always return true.
   */
  const disableValidation = async () => {
    await page.evaluate(() => {
      // --- Remove native required constraints ---
      document.querySelectorAll('[required]').forEach(el => {
        el.removeAttribute('required');
        el.removeAttribute('aria-required');
      });

      // --- Fill empty text-like inputs ---
      document.querySelectorAll(
        'input[type="text"], input[type="email"], input[type="tel"], textarea'
      ).forEach(el => {
        if (!el.value && !el.disabled && !el.readOnly) {
          el.value = el.type === 'email' ? 'backstop@example.com' : 'Backstop Test';
          // Fire change/input so VF view-state picks up the value
          el.dispatchEvent(new Event('input',  { bubbles: true }));
          el.dispatchEvent(new Event('change', { bubbles: true }));
        }
      });

      // --- Select first real option in empty <select> ---
      document.querySelectorAll('select').forEach(sel => {
        if (sel.disabled) return;
        if (!sel.value || sel.selectedIndex <= 0) {
          for (let i = 1; i < sel.options.length; i++) {
            if (sel.options[i].value) {
              sel.selectedIndex = i;
              sel.dispatchEvent(new Event('change', { bubbles: true }));
              break;
            }
          }
        }
      });

      // --- Override custom JS validators ---
      window.checkForm       = () => true;
      window.populateAppJSON = () => true;
      window.saveGuestModal  = () => true;
    });
  };

  /**
   * Click a submit button and wait for the resulting full-page navigation.
   * Promise.all ensures we listen BEFORE clicking so fast navigations are caught.
   */
  const clickAndNavigate = async (selector) => {
    await disableValidation();

    const el = page.locator(selector).first();
    await el.waitFor({ state: 'visible', timeout: 15000 });

    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle', timeout: 45000 }),
      el.click()
    ]);

    // Extra buffer: VF view-state re-renders after the load event
    await sleep(1500);
    console.log(`[fillAndAdvance] URL after nav: ${page.url()}`);
    // Check for delayed JS redirect (VF Experience Site pattern)
    await sleep(3000);
    console.log(`[fillAndAdvance] URL after +3s: ${page.url()}`);
  };

  /** Submit the current page to move to the next one */
  const advance = async () => {
    const cur = getPage();
    console.log(`[fillAndAdvance] Submitting page: ${cur}`);

    if (cur === 'register') {
      // ── Register page ──────────────────────────────────────────────────────
      await page.waitForSelector('[id$=":firstName"]', { timeout: 15000 });

      // Fill minimum required fields
      await page.locator('[id$=":firstName"]').fill('Backstop');
      await page.locator('[id$=":lastName"]').fill('Tester');
      await page.locator('[id$=":email"]').fill('backstop.test@example.com');

      await disableValidation();

      // Try submitReg1 (non-reCAPTCHA); fall back to submitReg2 (reCAPTCHA)
      const reg1 = page.locator('[id$=":submitReg1"]').first();
      const reg2 = page.locator('[id$=":submitReg2"]').first();

      let useSelector;
      try {
        await reg1.waitFor({ state: 'visible', timeout: 5000 });
        useSelector = '[id$=":submitReg1"]';
      } catch (_) {
        useSelector = '[id$=":submitReg2"]';
      }

      await Promise.all([
        page.waitForNavigation({ waitUntil: 'networkidle', timeout: 45000 }),
        page.locator(useSelector).first().click()
      ]);
      await sleep(1500);
      console.log(`[fillAndAdvance] URL after register submit: ${page.url()}`);

    } else if (cur === 'additionalquestions') {
      // ── Additional Questions page ──────────────────────────────────────────
      await page.waitForSelector('[id$=":submitQuestions"]', { timeout: 15000 });

      // Debug: log cookies before submit
      const cookies = await page.context().cookies();
      const seaCookie = cookies.find(c => c.name === 'SummitEvents');
      console.log(`[fillAndAdvance] SummitEvents cookie present: ${!!seaCookie}, value snippet: ${seaCookie ? seaCookie.value.substring(0, 40) : 'none'}`);

      await clickAndNavigate('[id$=":submitQuestions"]');

      // Debug: check page content for errors
      const bodyText = await page.evaluate(() => document.body ? document.body.innerText.substring(0, 300) : 'no body');
      console.log(`[fillAndAdvance] Page body after submit: ${bodyText.replace(/\s+/g, ' ').trim()}`);


    } else if (cur === 'appointments') {
      // ── Appointments page ──────────────────────────────────────────────────
      // populateAppJSON() runs via onClick; pre-set the hidden field so it
      // doesn't block navigation when no appointment slots are selected.
      await page.waitForSelector('[id$=":submitOptions"]', { timeout: 15000 });
      await page.evaluate(() => {
        const hidden = document.querySelector('[id$=":outgoingAppJSon"]');
        if (hidden && !hidden.value) hidden.value = '{}';
      });
      await clickAndNavigate('[id$=":submitOptions"]');

    } else if (cur === 'guests' || cur === 'donation' || cur === 'submit') {
      // ── Guests / Donation / Submit-Review pages ─────────────────────────────
      await page.waitForSelector('[id$=":submitOptions"]', { timeout: 15000 });
      await clickAndNavigate('[id$=":submitOptions"]');
    }
  };

  // ── Main loop ──────────────────────────────────────────────────────────────
  if (!target) {
    console.log('[fillAndAdvance] No targetPage set — doing nothing.');
    return;
  }

  for (let step = 0; step < 8; step++) {
    const cur = getPage();
    console.log(`[fillAndAdvance] Step ${step}: current="${cur}", target="${target}"`);

    if (cur === target) {
      console.log('[fillAndAdvance] Reached target page. Done.');
      break;
    }

    const before = cur;
    try {
      await advance();
    } catch (err) {
      console.error(`[fillAndAdvance] Error on step ${step}:`, err.message);
      break;
    }

    if (getPage() === before) {
      console.warn(`[fillAndAdvance] Page did not advance from "${before}" — stopping.`);
      break;
    }
  }

  console.log(`[fillAndAdvance] Final page: "${getPage()}", target was: "${target}"`);
};
