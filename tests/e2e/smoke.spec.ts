import { expect, test } from '@playwright/test';

test('placeholder page renders with no console errors and no horizontal scroll', async ({
  page,
}) => {
  const problems: string[] = [];
  page.on('console', (message) => {
    if (message.type() === 'error') problems.push(`console: ${message.text()}`);
  });
  page.on('response', (response) => {
    if (response.status() >= 400) problems.push(`http ${response.status()}: ${response.url()}`);
  });
  page.on('pageerror', (error) => problems.push(`pageerror: ${error.message}`));

  const response = await page.goto('/');
  await expect(page.locator('link[rel="icon"]')).toHaveAttribute('href', /.+/);
  expect(response?.status()).toBe(200);

  await expect(page.getByRole('heading', { level: 1, name: 'personal-website' })).toBeVisible();

  const { scrollWidth, clientWidth } = await page.evaluate(() => ({
    scrollWidth: document.documentElement.scrollWidth,
    clientWidth: document.documentElement.clientWidth,
  }));
  expect(scrollWidth).toBeLessThanOrEqual(clientWidth);

  expect(problems).toEqual([]);
});
