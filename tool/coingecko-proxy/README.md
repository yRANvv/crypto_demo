# CoinGecko 反代（Cloudflare Worker）

给 `crypto_demo` 用的中转站。部署在 Cloudflare 上，由它去拉 `api.coingecko.com`，
App 只跟这个 Worker 通信，所以本机不需要挂代理。

## 前置条件

1. 有一个 Cloudflare 账号，且**邮箱已验证**（注册后 Cloudflare 会发验证邮件，必须点完）。
2. 已安装 Node.js（本机已有 v24）。

## 部署（命令行，3 条命令）

```bash
cd tool/coingecko-proxy
npm install
npx wrangler login     # 会打开浏览器，点一下 Allow
npx wrangler deploy
```

部署成功后会打印一行地址，形如：

```
https://coingecko-proxy.你的账号子域.workers.dev
```

### 如果 npm 很慢

```bash
npm config set registry https://registry.npmmirror.com
```

### 如果 wrangler 连不上 Cloudflare

命令行工具默认不走系统代理，可以在命令前临时指定（端口换成你代理软件的 HTTP 端口）：

```bash
HTTPS_PROXY=http://127.0.0.1:7890 npx wrangler deploy
```

## 部署（网页版，不想用命令行就走这个）

1. Cloudflare 控制台 → **Workers & Pages** → **Create** → **Worker** → 起名 → **Deploy**。
2. 点 **Edit code**，把 `src/index.js` 的内容整段粘进去（覆盖默认内容）→ **Deploy**。
3. 页面右侧就能看到你的 `*.workers.dev` 地址。

## 验证

浏览器直接打开（把域名换成你的）：

```
https://coingecko-proxy.你的账号子域.workers.dev/coins/markets?vs_currency=usd&per_page=2
```

返回币种 JSON 就成功了。

## 接入 App

```bash
flutter run --dart-define=COINGECKO_BASE_URL=https://coingecko-proxy.你的账号子域.workers.dev
```

域名后面**不要**再加 `/api/v3`，Worker 会自动补。

## 备注

* 免费版每天 10 万次请求，个人 demo 完全够用。
* Worker 的出站 IP 是共享的，CoinGecko 偶尔会返回 429；配上免费的
  Demo API Key（`--dart-define=COINGECKO_API_KEY=CG-xxx`）会稳很多。
* 数据是实时的，因为 Worker 每次请求都实时回源 CoinGecko，不做缓存。
