import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OneUmmahApp());
}

class OneUmmahApp extends StatefulWidget {
  const OneUmmahApp({super.key});

  @override
  State<OneUmmahApp> createState() => _OneUmmahAppState();
}

class _OneUmmahAppState extends State<OneUmmahApp> {
  late final WebViewController _controller;

  static const String homeUrl =
      'https://one-ummah-yahyeabdirahman1526404989.adaptive.ai/';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(homeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
