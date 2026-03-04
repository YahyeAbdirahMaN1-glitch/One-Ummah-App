import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OneUmmahApp());
}

class OneUmmahApp extends StatelessWidget {
  const OneUmmahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Ummah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const WebShell(),
    );
  }
}

class WebShell extends StatefulWidget {
  const WebShell({super.key});

  @override
  State<WebShell> createState() => _WebShellState();
}

class _WebShellState extends State<WebShell> {
  static const String siteUrl =
      'https://one-ummah-yahyeabdirahman1526404989.adaptive.ai';

  late final WebViewController controller;

  bool isLoading = true;
  String? currentUrl;

  @override
  void initState() {
    super.initState();

    final Uri siteUri = Uri.parse(siteUrl);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              currentUrl = url;
            });
            debugPrint('PAGE START -> $url');
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
              currentUrl = url;
            });
            debugPrint('PAGE FINISH -> $url');
          },
          onNavigationRequest: (request) async {
            debugPrint('NAV -> ${request.url}');

            final Uri? uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            final bool isSameHost = uri.host == siteUri.host;

            if (!isSameHost) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint(
              'Web error: ${error.errorCode} ${error.description} ${error.errorType}',
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Web error: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(siteUri);
  }

  Future<bool> _handleBack() async {
    final canGoBack = await controller.canGoBack();
    if (canGoBack) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('One Ummah'),
          actions: [
            IconButton(
              tooltip: 'Back',
              onPressed: () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => controller.reload(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(child: WebViewWidget(controller: controller)),
            if (isLoading)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}