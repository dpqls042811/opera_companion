import 'dart:async';
import 'dart:html' as html;

Future<String> downloadOfflineAssets() async {
  final sw = html.window.navigator.serviceWorker;
  final controller = sw?.controller;

  print('serviceWorker: $sw');
  print('controller: $controller');

  if (sw == null) {
    return 'service worker 지원 안 됨';
  }

  if (controller == null) {
    return 'controller 없음';
  }

  controller.postMessage('downloadOffline');
  return '요청 전송 완료';
}
