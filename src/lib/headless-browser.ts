import HttpProxy = require('http-proxy');
import puppeteer, { Browser } from 'puppeteer';

let browser: Browser;

async function getBrowser() {
  if (!browser) {
    const options =
      process.env.NODE_ENV === 'production'
        ? {
            executablePath: '/usr/bin/google-chrome',
            args: [
              '--disable-gpu',
              '--disable-dev-shm-usage',
              '--disable-setuid-sandbox',
              '--no-sandbox',
            ],
          }
        : { headless: true };
    browser = await puppeteer.launch(options);
  }
  return browser;
}

export async function getBrowserLessWsEndpoint() {
  const browser = await getBrowser();
  const browserWSEndpoint = browser.wsEndpoint();
  await browser.disconnect();
  return browserWSEndpoint;
}

export async function bootBrowserLessWsEndpointProxyServer() {
  const browser = await getBrowser();
  const browserWSEndpoint = browser.wsEndpoint();
  const host = '0.0.0.0';
  const port = 8081;

  const proxy = await HttpProxy.createServer({
    target: browserWSEndpoint,
    ws: true,
    localAddress: host,
  });

  proxy.listen(port);

  proxy.on('error', function (err) {
    console.log('bootBrowserLessWsEndpointProxyServer Error', err);
  });

  return `ws://${host}:${port}`;
}
