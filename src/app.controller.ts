import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import puppeteer, { Browser } from 'puppeteer';

let browser: Browser;

async function getBrowser() {
  if (!browser) {
    browser = await puppeteer.launch({
      headless: true,
    });
  }
  return browser;
}

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('ws/endpoint')
  async getWsEndpoint() {
    const browser = await getBrowser();
    const browserWSEndpoint = browser.wsEndpoint();
    await browser.disconnect();
    return browserWSEndpoint;
  }
}
