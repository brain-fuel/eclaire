import assert from 'node:assert/strict';
import { chromium } from 'playwright';

const ports = {
  C: Number(process.env.PORT_C ?? 5092),
  FSharp: Number(process.env.PORT_FSHARP ?? 5093),
  Haskell: Number(process.env.PORT_HASKELL ?? 5094),
};

const browserOptions = { headless: true };
if (process.env.PLAYWRIGHT_EXECUTABLE_PATH) {
  browserOptions.executablePath = process.env.PLAYWRIGHT_EXECUTABLE_PATH;
} else if (process.env.PLAYWRIGHT_CHANNEL) {
  browserOptions.channel = process.env.PLAYWRIGHT_CHANNEL;
} else if (process.platform === 'darwin') {
  browserOptions.channel = 'chrome';
}

const browser = await chromium.launch(browserOptions);
const results = {};

try {
  for (const [name, port] of Object.entries(ports)) {
    const page = await browser.newPage({ viewport: { width: 1100, height: 900 } });
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    page.on('console', message => {
      if (message.type() === 'error') errors.push(message.text());
    });

    await page.goto(`http://127.0.0.1:${port}/`, { waitUntil: 'networkidle' });
    await page.waitForSelector('#counter', { timeout: 30000 });

    const initial = await page.evaluate(() => {
      const text = selector => document.querySelector(selector)?.textContent?.trim();
      const geometry = Object.fromEntries([
        '#app', '.eyebrow', 'h1', '.lede', '.showcase', '#showcase-title',
        '#counter', '.actions', '#show-details', '.details', '.hero-image',
        '.scroll-area', 'footer',
      ].map(selector => {
        const rect = document.querySelector(selector).getBoundingClientRect();
        return [selector, [rect.x, rect.y, rect.width, rect.height].map(v => Math.round(v * 10) / 10)];
      }));
      return {
        title: document.title,
        eyebrow: text('.eyebrow'),
        heading: text('h1'),
        lede: text('.lede'),
        cardTitle: text('#showcase-title'),
        counter: text('#counter'),
        detailsCopy: text('.details > p'),
        imageAlt: document.querySelector('.hero-image').alt,
        imageLoaded: document.querySelector('.hero-image').naturalWidth > 0,
        scrollCopy: text('.scroll-area > p'),
        footer: text('footer'),
        controls: [...document.querySelectorAll('[data-action]')].map(el => [el.dataset.action, el.getAttribute('aria-label') || el.labels?.[0]?.textContent.trim() || el.textContent.trim()]),
        checkboxChecked: document.querySelector('#show-details').checked,
        detailsHidden: document.querySelector('.details').hidden,
        liveRegion: document.querySelector('#counter').getAttribute('aria-live'),
        cardGap: getComputedStyle(document.querySelector('.showcase')).gap,
        geometry,
      };
    });

    assert.equal(initial.counter, 'Count: 0', `${name}: initial count`);
    assert.equal(initial.checkboxChecked, true, `${name}: checkbox starts checked`);
    assert.equal(initial.detailsHidden, false, `${name}: details start visible`);
    assert.equal(initial.imageLoaded, true, `${name}: image loads`);
    assert.equal(initial.liveRegion, 'polite', `${name}: counter is a polite live region`);
    assert.equal(initial.cardGap, '18px', `${name}: shared card spacing is loaded`);
    assert.deepEqual(initial.controls.map(([id]) => id), ['100', '101', '102'], `${name}: action IDs`);

    await page.locator('#increase').click();
    await page.waitForFunction(() => document.querySelector('#counter')?.textContent?.trim() === 'Count: 1');
    await page.locator('#decrease').click();
    await page.waitForFunction(() => document.querySelector('#counter')?.textContent?.trim() === 'Count: 0');
    await page.locator('#show-details').uncheck();
    await page.waitForFunction(() => !document.querySelector('#show-details')?.checked && document.querySelector('.details')?.hidden);
    await page.locator('#show-details').check();
    await page.waitForFunction(() => document.querySelector('#show-details')?.checked && !document.querySelector('.details')?.hidden);

    await page.setViewportSize({ width: 375, height: 812 });
    const mobileGeometry = await page.evaluate(() => Object.fromEntries([
      '#app', '.showcase', '#counter', '#show-details', '.details', '.hero-image', '.scroll-area', 'footer',
    ].map(selector => {
      const rect = document.querySelector(selector).getBoundingClientRect();
      return [selector, [rect.x, rect.y, rect.width, rect.height].map(v => Math.round(v * 10) / 10)];
    })));

    assert.deepEqual(errors, [], `${name}: browser console and runtime errors`);
    results[name] = { initial, mobileGeometry, interactions: 'counter +/- and checkbox hide/show passed' };
    await page.close();
  }

  const reference = results.C;
  for (const name of ['FSharp', 'Haskell']) {
    assert.deepEqual(results[name].initial, reference.initial, `${name}: desktop content, controls, and geometry match C`);
    assert.deepEqual(results[name].mobileGeometry, reference.mobileGeometry, `${name}: responsive geometry matches C`);
  }
  console.log('PASS browser parity: C, F#, and Haskell match in content, controls, and all 13 desktop / 8 mobile element bounds; increment, decrement, checkbox hide/show, image load, and browser error checks passed.');
} finally {
  await browser.close();
}
