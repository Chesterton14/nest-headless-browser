import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { bootBrowserLessWsEndpointProxyServer } from './lib/headless-browser';

const port = process.env.PORT || 3000;
console.log(
  `Launching NestJS app on port ${port}, URL: http://0.0.0.0:${port}`,
);

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  await app.listen(port);

  await bootBrowserLessWsEndpointProxyServer();
}
bootstrap();
