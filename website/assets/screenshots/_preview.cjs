const { chromium } = require('C:/Users/jason/AppData/Local/Temp/cursor-sandbox-cache/01e7c6355f347db5af2936724b918921/npm/_npx/bbb8a2c4738e2b0c/node_modules/playwright');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.goto('http://127.0.0.1:8765/index.html', { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(1500);
  await page.screenshot({
    path: 'c:/Users/jason/Documents/MadBeauty/website/assets/screenshots/_preview-desktop.png',
    fullPage: false,
  });
  await page.setViewportSize({ width: 390, height: 844 });
  await page.waitForTimeout(600);
  await page.screenshot({
    path: 'c:/Users/jason/Documents/MadBeauty/website/assets/screenshots/_preview-mobile.png',
    fullPage: false,
  });
  await page.mouse.click(40, 40);
  await page.waitForTimeout(400);
  await page.screenshot({
    path: 'c:/Users/jason/Documents/MadBeauty/website/assets/screenshots/_preview-mobile-menu.png',
    fullPage: false,
  });
  await browser.close();
})();
