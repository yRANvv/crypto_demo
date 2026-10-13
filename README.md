# 加密货币 Demo（crypto_demo）

一个按需求文档实现的加密货币行情 Demo：

* **用户鉴权**：Firebase Auth（邮箱 / 密码注册登录）
* **行情数据**：CoinGecko [`/coins/markets`](https://docs.coingecko.com/v3.0.1/reference/coins-markets)
* **技术要求**：`flutter_bloc` + `get_it` + `dio` + `go_router`

界面完全对齐设计稿：黑色底、`🔥 XXX 当前热搜` 搜索框、市场 / 动态 / 牛人榜 三个一级 Tab、
自选 / 现货 / 合约 / 期权 / 总览 二级筛选、名称 / 成交额 / 最新价 / 今日涨跌 四列表格，
底部「添加币对 | 编辑自选」。

## 需求对照

| 需求 | 实现位置 |
| --- | --- |
| 构建一个简单加密货币的 App | `features/market`：市场 / 动态 / 牛人榜、自选管理、排序搜索、下拉刷新 |
| 通过 Firebase Auth 实现用户鉴权 | `features/auth`：注册 / 登录 / 退出 / 登录态持久化 / 路由守卫；未配置时降级为本地演示鉴权 |
| 数据使用 CoinGecko API | `data/datasources/coin_gecko_market_data_source.dart`（官方 `/coins/markets`，支持 Demo / Pro Key 与自建反代） |
| flutter_bloc | `AuthBloc`、`MarketBloc`：事件用 `sealed class`，状态用 `Equatable` |
| get_it | `core/di/injection.dart`：数据源 → 仓库 → Bloc 全量注入 |
| dio | `core/network/dio_client.dart`：统一超时、请求头、代理；两个数据源共用 |
| go_router | `core/router/app_router.dart`：路由表 + 登录守卫 + `refreshListenable` |

架构分层、数据流与设计决策见 [docs/architecture.md](docs/architecture.md)。

## 目录结构

```
lib/
├── main.dart                     # 入口：初始化 Firebase → 注册依赖 → runApp
├── app.dart                      # MaterialApp.router + AuthBloc 注入
├── core/
│   ├── config/                   # 环境信息、dart-define 密钥
│   ├── di/injection.dart         # get_it 依赖注册
│   ├── firebase/                 # Firebase 初始化与可用性探测
│   ├── network/dio_client.dart   # Dio + CoinGecko 请求头 / 域名
│   ├── router/app_router.dart    # go_router 路由 + 登录守卫
│   ├── theme/                    # 深色主题与配色
│   └── utils/market_formatter.dart
└── features/
    ├── auth/                     # data / domain / presentation(bloc, pages)
    └── market/                   # 行情数据 + 市场 / 动态 / 牛人榜 页面
```

分层约定：`presentation → domain ← data`，`presentation` 只依赖 `domain` 抽象，
具体实现（Firebase / CoinGecko / 本地演示）由 `get_it` 注入。

## 运行

```bash
flutter pub get
flutter run                 # 连接真机 / 模拟器
flutter run -d chrome       # 或用浏览器跑
flutter test                # 单元测试
```

## 拿到梯子后的完整流程（照抄即可）

```bash
# 0. 挂上梯子（TUN / 全局模式），先确认确实通了：
curl -I https://api.coingecko.com/api/v3/ping

# 1. 配置 Firebase（见下面第 1 节，两种方式任选其一）
flutterfire configure

# 2. 直接跑，什么参数都不用加 —— CoinGecko 实时行情 + 真实 Firebase Auth
flutter run -d chrome

# 3. 想强制只用 CoinGecko（按需求验收）
flutter run --dart-define=DATA_SOURCE=coingecko

# 4. 梯子关了也不影响开发（切币安行情 + 本地演示登录）
flutter run --dart-define=DATA_SOURCE=binance --dart-define=AUTH_MODE=demo
```

VS Code 用户可以直接用仓库里配好的 [.vscode/launch.json](.vscode/launch.json)，
里面预置了上面三种场景，按 F5 选一个就行。

### 1. 接入真实 Firebase Auth

代码侧已经全部接好（`main.dart` → `FirebaseBootstrap.initialize()` → `firebase_options.dart`），
**你只需要提供 Firebase 项目配置**。没配置时 App 会自动降级为本地演示鉴权
（内置账号 `demo@crypto.app / 123456`），所以现在也能跑通整条流程。

**方式 A：FlutterFire CLI（推荐）**

1. 打开 <https://console.firebase.google.com> 新建项目（Analytics 可以关）。
2. 左侧 **Authentication → Get started → Sign-in method**，启用 **Email/Password**。
3. 回到项目根目录执行：

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure     # 选择刚建的项目，平台勾 android / ios / web
   ```

   如果它问是否覆盖已有的 `lib/firebase_options.dart`（仓库里放了一个模板），**选覆盖**。
   之后它会生成真实配置，并写入
   `android/app/google-services.json`、`ios/Runner/GoogleService-Info.plist`。

**方式 B：不想装 CLI，用启动参数传配置**

在控制台「项目设置 → 你的应用」里复制参数（web 与移动端通用）：

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=xxx \
  --dart-define=FIREBASE_APP_ID=xxx \
  --dart-define=FIREBASE_PROJECT_ID=xxx \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=xxx
```

**怎么确认生效**：登录页底部那条「未检测到 Firebase 配置…」的提示会消失；
注册账号后刷新页面仍是登录状态，就说明走的是真实 Firebase。

> ⚠️ Firebase Auth 走的是 Google 域名（`identitytoolkit.googleapis.com`），
> 国内直连同样不通，**运行 App 时也要挂着梯子**，否则登录会提示「网络异常，请检查网络连接」。

**鉴权模式开关**

| `--dart-define=AUTH_MODE=` | 行为 |
| --- | --- |
| 不传 / `auto` | 有 Firebase 配置就用 Firebase，否则用本地演示鉴权 |
| `firebase` | 强制使用 Firebase Auth |
| `demo` | 强制使用本地演示鉴权（已配好 Firebase 但临时没网时用） |

### 2. 连接 CoinGecko 接口

接口：`GET https://api.coingecko.com/api/v3/coins/markets`

本项目已按官方要求带上请求头，并支持三种接入方式：

| 方案 | 域名 | 请求头 | 启动参数 |
| --- | --- | --- | --- |
| 公共（免 Key，限流最紧） | `api.coingecko.com` | — | 直接运行 |
| Demo（免费 Key） | `api.coingecko.com` | `x-cg-demo-api-key` | `--dart-define=COINGECKO_API_KEY=CG-xxxxxxxx` |
| Pro（付费） | `pro-api.coingecko.com` | `x-cg-pro-api-key` | `--dart-define=COINGECKO_PRO_API_KEY=xxxxxxxx` |
| 自建反代 | 你的域名 | 同上 | `--dart-define=COINGECKO_BASE_URL=https://xxx/api/v3` |

```bash
# 免费 Demo Key（推荐，最稳定）
flutter run --dart-define=COINGECKO_API_KEY=CG-你的Key
```

请求参数：

```
vs_currency=usd&order=market_cap_desc&per_page=100&page=1
&sparkline=false&price_change_percentage=24h
```

字段映射：`current_price → 最新价`、`total_volume → 成交额`、
`price_change_percentage_24h → 今日涨跌`、`image → 币种图标`。

如果接口超时 / 被限流（429）/ 鉴权失败，界面会提示原因并自动切换到内置演示行情，
保证 Demo 始终有内容可展示。

### 3. 网络直连不了 CoinGecko 时

国内网络无法直连 `coingecko.com` / `api.coingecko.com`（网站打不开、接口超时都是这个原因），
此时**申请 Key 也没用，必须让请求先通出去**。两种做法：

1. **走代理**：本地代理 / 公司出口 / Cloudflare Worker 反代都行。

   Worker 反代我已经写成现成的子项目放在 [`tool/coingecko-proxy`](tool/coingecko-proxy/README.md)，
   部署只要三条命令。核心代码：

   ```js
   // Cloudflare Worker：把 https://你的域名/coins/markets 转发到
   // https://api.coingecko.com/api/v3/coins/markets
   export default {
     async fetch(request) {
       const url = new URL(request.url);
       // 自动补上 /api/v3 前缀，这样 App 侧只要填域名即可
       if (!url.pathname.startsWith('/api/v3')) {
         url.pathname = `/api/v3${url.pathname}`;
       }
       url.hostname = 'api.coingecko.com';
       url.protocol = 'https:';
       url.port = '';
       return fetch(new Request(url.toString(), request));
     },
   };
   ```

   拿到 Worker 域名后运行（域名后面不用带 `/api/v3`）：

   ```bash
   flutter run \
     --dart-define=COINGECKO_BASE_URL=https://你的worker域名 \
     --dart-define=COINGECKO_API_KEY=CG-你的Key
   ```

   验证反代是否可用：浏览器直接打开
   `https://你的worker域名/coins/markets?vs_currency=usd&per_page=2`，
   能返回 JSON 就说明通了。

   注意：Worker 的出站 IP 是共享的，CoinGecko 对这类 IP 容易返回 429，
   建议同时配一个免费的 Demo Key（见上文）。

   如果你本地有 Clash / Surge 这类代理但**没开 TUN（增强）模式**，
   注意 Flutter 原生请求默认不走系统代理，要用项目内置的代理开关显式指定：

   ```bash
   flutter run --dart-define=HTTP_PROXY=127.0.0.1:7890
   ```

   （端口换成你代理软件的 HTTP 端口；Web 端由浏览器接管网络，
   这个参数不生效，请设置系统 / 浏览器代理。）

2. **换数据源**：项目已内置币安公开行情作为降级来源，见下一节，无需额外配置。

### 4. 数据源切换与自动降级

国内实测（2026-10）：`api.coingecko.com` / `assets.coingecko.com` 均连接超时，
`workers.dev`（Cloudflare 免费反代域名）同样不可达；
`data-api.binance.vision` 可直连（约 0.6s），因此项目内置了第二个数据源。

通过 `DATA_SOURCE` 切换：

| 值 | 行为 |
| --- | --- |
| `auto`（默认） | CoinGecko 与币安**并发**请求，CoinGecko 有 2.5 秒优先窗口；窗口内没返回就先用币安，并记住可用来源，后续刷新不再重复探测 |
| `coingecko` | 只用 CoinGecko（需求文档指定的接口） |
| `binance` | 只用币安公开行情（`data-api.binance.vision`，无需 Key、无需代理） |

```bash
# 没有代理 / 梯子时（推荐）
flutter run --dart-define=DATA_SOURCE=binance

# 有梯子后什么都不用加，auto 会自动用 CoinGecko
flutter run
```

两个来源的原始字段在 data 层统一映射成同一套 `CoinModel`，因此 Bloc / UI 完全无感知；
界面顶部会明确提示当前实际使用的来源（例如「CoinGecko 直连失败（网络受限），
当前显示 币安实时行情」），并提供「重试」。

币种图标：图标 CDN 同样不可达，所以 49 个常用币种的彩色图标直接内置在
`assets/coins/`（来自开源包 [`cryptocurrency-icons`](https://www.npmjs.com/package/cryptocurrency-icons)），
其余币种回退为字母色块。

## 已实现的功能

**鉴权（Firebase Auth）**

* 邮箱密码注册、登录、退出；`authStateChanges` 驱动登录态
* `go_router` 重定向守卫：未登录跳 `/login`，已登录跳首页；启动页 `/splash` 等待鉴权状态
* 表单校验、加载态、错误提示（含 Firebase 错误码中文映射）

**行情（CoinGecko + flutter_bloc）**

* 一级 Tab：市场 / 动态 / 牛人榜
* 二级筛选：自选 / 现货 / 合约 / 期权（占位）/ 总览
* 表头点击排序（名称 / 成交额 / 最新价 / 今日涨跌，升序降序切换）
* 搜索框实时过滤，提示文案取自当前涨幅最高的币种
* 添加币对 / 编辑自选（底部弹窗，可增删自选）、下拉刷新

## 构建 APK

```bash
# 1. 真实 Firebase 鉴权版（交作业用；手机上需要能访问 Google 才能登录）
flutter build apk --release $(cat .dart-defines)

# 2. 离线演示版（手机没有梯子也能登录，行情依然走真实接口）
flutter build apk --release $(cat .dart-defines) --dart-define=AUTH_MODE=demo

# 产物路径
build/app/outputs/flutter-apk/app-release.apk
```

`.dart-defines` 是本地 Firebase 配置（已加入 `.gitignore`，不会进仓库），内容是六个
`--dart-define=FIREBASE_*` 参数；不配它也能构建，App 会自动降级为本地演示鉴权。

国内构建的两个坑：

* Gradle 官方发行包（`services.gradle.org`）经常卡在 0 速度，本项目
  `android/gradle/wrapper/gradle-wrapper.properties` 的 `distributionUrl` 已指向腾讯镜像，
  需要换回官方源直接改回该地址即可。
* 首次构建要下载 Gradle、AGP、Kotlin 与 SDK 平台，约 2 GB、耗时十几分钟；
  之后增量构建只要 30 秒左右。

## 单元测试

`test/market_formatter_test.dart` 覆盖数字格式化（`$2.28亿`、`1,276.5`、`0.20748`、`+0.16%`）
与 CoinGecko 响应解析（含字段缺失兜底）。
