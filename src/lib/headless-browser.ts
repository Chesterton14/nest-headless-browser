import { Logger } from '@nestjs/common';
import puppeteer, { Browser } from 'puppeteer';
import HttpProxy = require('http-proxy');

let browser: Browser;

async function getBrowser() {
  if (!browser) {
    browser = await puppeteer.launch({
      headless: 'shell',
    });
  }
  return browser;
}

async function getBrowserLessWsEndpoint() {
  const browser = await getBrowser();
  const browserWSEndpoint = browser.wsEndpoint();
  await browser.disconnect();
  return browserWSEndpoint;
}

const HOST = '0.0.0.0';
const PORT = 8081;

export async function bootBrowserLessWsEndpointProxyServer() {
  const browserWSEndpoint = await getBrowserLessWsEndpoint();

  const proxy = HttpProxy.createServer({
    target: browserWSEndpoint,
    ws: true,
    localAddress: HOST,
  });

  proxy.listen(PORT);

  proxy.on('error', (err) => {
    Logger.log('bootBrowserLessWsEndpointProxyServer Error', err);
  });

  proxy.on('start', (req, res, targe) => {
    Logger.log('bootBrowserLessWsEndpointProxyServer Start', targe);
  });

  return `ws://${HOST}:${PORT}`;
}
