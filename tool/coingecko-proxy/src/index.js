/**
 * CoinGecko 反向代理（Cloudflare Worker）。
 *
 * 部署后用法：
 *   https://<你的worker域名>/coins/markets?vs_currency=usd  ->  api.coingecko.com/api/v3/coins/markets?vs_currency=usd
 *
 * App 侧只需要：
 *   flutter run --dart-define=COINGECKO_BASE_URL=https://<你的worker域名>
 */

const UPSTREAM_HOST = 'api.coingecko.com';
const UPSTREAM_PATH_PREFIX = '/api/v3';

const CORS_HEADERS = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET,OPTIONS',
  'access-control-allow-headers': '*',
};

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // 浏览器跨域预检（带自定义请求头时才需要，留着更保险）
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    // 根路径给个说明，方便浏览器里直接打开域名自检
    if (url.pathname === '/' || url.pathname === '') {
      return new Response(
        JSON.stringify({
          ok: true,
          service: 'coingecko-proxy',
          try: `${url.origin}/coins/markets?vs_currency=usd&per_page=2`,
        }),
        {
          headers: { 'content-type': 'application/json; charset=utf-8', ...CORS_HEADERS },
        },
      );
    }

    // 自动补上 /api/v3 前缀，这样 App 那边只要填域名就行
    if (!url.pathname.startsWith(UPSTREAM_PATH_PREFIX)) {
      url.pathname = `${UPSTREAM_PATH_PREFIX}${url.pathname}`;
    }
    url.hostname = UPSTREAM_HOST;
    url.protocol = 'https:';
    url.port = '';

    const upstream = await fetch(new Request(url.toString(), request));
    const headers = new Headers(upstream.headers);
    for (const [key, value] of Object.entries(CORS_HEADERS)) {
      headers.set(key, value);
    }

    return new Response(upstream.body, {
      status: upstream.status,
      statusText: upstream.statusText,
      headers,
    });
  },
};
