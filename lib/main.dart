import 'package:flutter/material.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Sampah Sekanak Polsri',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<StatefulWidget> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final PlatformWebViewController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller =
        PlatformWebViewController(AndroidWebViewControllerCreationParams())
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setPlatformNavigationDelegate(
            PlatformNavigationDelegate(
                const PlatformNavigationDelegateCreationParams(),
              )
              ..setOnProgress((int progress) {
                debugPrint('Webview is loading (progress : $progress %)');
              })
              ..setOnPageStarted((String url) {
                debugPrint('Page started loading: $url');
              })
              ..setOnPageFinished((String url) {
                debugPrint('Page finieshed loading: $url');
              })
              ..setOnHttpError((HttpResponseError error) {
                debugPrint(
                  'HTTP error occured on page: ${error.response?.statusCode}',
                );
              })
              ..setOnWebResourceError((WebResourceError error) {
                debugPrint('''
                  Page resource error:
                    code: ${error.errorCode}
                    description: ${error.description}
                    errorType: ${error.errorType}
                    isForMainFrame: ${error.isForMainFrame}
                    url: ${error.url}
                ''');
              })
              ..setOnNavigationRequest((NavigationRequest request) {
                if (request.url.contains('pub.dev')) {
                  debugPrint('blocking navigation to ${request.url}');
                  return NavigationDecision.prevent;
                }
                debugPrint('allowing navigation to ${request.url}');
                return NavigationDecision.navigate;
              })
              ..setOnUrlChange((UrlChange change) {
                debugPrint('url change to ${change.url}');
              })
              ..setOnSSlAuthError((PlatformSslAuthError error) {
                debugPrint(
                  'SSL error from ${(error as AndroidSslAuthError).url}',
                );
                error.cancel();
              }),
          )
          ..loadRequest(
            LoadRequestParams(uri: Uri.parse('Fill https website at here')),
          );

    if (_controller is AndroidWebViewController) {
      final androidController = _controller;

      androidController.setOnPlatformPermissionRequest((request) {
        request.grant();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: _controller),
      ).build(context),
    );
  }
}
