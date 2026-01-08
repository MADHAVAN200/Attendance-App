import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReCaptchaV2 extends StatefulWidget {
  final String siteKey;
  final Function(String) onVerified;

  const ReCaptchaV2({
    super.key,
    required this.siteKey,
    required this.onVerified,
  });

  @override
  State<ReCaptchaV2> createState() => _ReCaptchaV2State();
}

class _ReCaptchaV2State extends State<ReCaptchaV2>
    with TickerProviderStateMixin {
  late WebViewController _controller;
  double _height = 80;

  @override
  void initState() {
    super.initState();

    final html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<style>
html, body {
  margin: 0;
  padding: 0;
  background: transparent;
  width: 100%;
  display: flex;
  justify-content: center;
}
</style>
</head>
<body>
<div class="g-recaptcha"
     data-sitekey="${widget.siteKey}"
     data-size="normal"
     data-theme="light"
     data-callback="onSuccess"
     data-expired-callback="onExpired"></div>

<script>
function onSuccess(token) {
  Captcha.postMessage("TOKEN:" + token);
}
function onExpired() {
  Captcha.postMessage("EXPIRED");
}
setInterval(() => {
  Captcha.postMessage("HEIGHT:" + document.body.scrollHeight);
}, 300);
</script>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'Captcha',
        onMessageReceived: (msg) {
          if (msg.message.startsWith('TOKEN:')) {
            widget.onVerified(msg.message.substring(6));
          } else if (msg.message.startsWith('HEIGHT:')) {
            final h = double.tryParse(msg.message.substring(7));
            if (h != null && (h - _height).abs() > 2) {
              setState(() => _height = h < 80 ? 80 : h);
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(),
      )
      ..loadHtmlString(html, baseUrl: 'https://attendance.mano.co.in');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: WebViewWidget(controller: _controller),
    );
  }
}
