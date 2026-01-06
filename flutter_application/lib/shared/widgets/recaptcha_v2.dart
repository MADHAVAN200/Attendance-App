import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReCaptchaV2 extends StatefulWidget {
  final Function(String) onVerified;
  final String? siteKey;

  const ReCaptchaV2({
    super.key,
    required this.onVerified,
    this.siteKey,
  });

  @override
  State<ReCaptchaV2> createState() => _ReCaptchaV2State();
}

class _ReCaptchaV2State extends State<ReCaptchaV2> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // Get Key from env or prop
    final key = widget.siteKey ?? dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';

    // HTML Content
    final html = '''
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <script src="https://www.google.com/recaptcha/api.js" async defer></script>
        <style>
          body { display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: transparent; }
          .g-recaptcha { transform: scale(1.0); transform-origin: 0 0; }
        </style>
      </head>
      <body>
        <div class="g-recaptcha" 
             data-sitekey="$key" 
             data-callback="captchaCallback">
        </div>
        <script type="text/javascript">
          function captchaCallback(token) {
            CaptchaChannel.postMessage(token);
          }
        </script>
      </body>
      </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'CaptchaChannel',
        onMessageReceived: (JavaScriptMessage message) {
          widget.onVerified(message.message);
        },
      )
      ..loadHtmlString(html, baseUrl: 'https://attendance.mano.co.in/');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
       // ReCaptcha standard size is approx 304x78. Adding buffer.
      height: 100, 
      width: 320,
      child: WebViewWidget(controller: _controller),
    );
  }
}
