// 原生端直接给 HttpClient 设代理；Web 端由浏览器接管网络，是空实现。
export 'proxy_configurator_io.dart'
    if (dart.library.js_interop) 'proxy_configurator_web.dart';
