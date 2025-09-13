import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

Future<void> downloadFileFromUrl(String fileUrl, String fileName) async {
  if (!kIsWeb) {
    // For non-web, you might handle differently or just open URL
    return;
  }

  // Create an anchor element
  final anchor = web.HTMLAnchorElement()
    ..href = fileUrl
    ..download = fileName;

  // Append to document
  web.document.body?.append(anchor);

  // Trigger click
  anchor.click();

  // Remove anchor
  anchor.remove();
}



// ✅ URL Launcher Functions
Future<void> launchInstagram() async {
  final Uri instagramUrl = Uri.parse('https://www.instagram.com/netprimex_app?igsh=dHoxbHpsMjFtMDNs');
  final Uri instagramApp = Uri.parse('https://www.instagram.com/netprimex_app?igsh=dHoxbHpsMjFtMDNs');

  try {
    // Try to open Instagram app first
    if (await canLaunchUrl(instagramApp)) {
      await launchUrl(instagramApp, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web browser
      await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    print('Could not launch Instagram: $e');
  }
}

Future<void> launchTelegram() async {
  final Uri telegramUrl = Uri.parse('https://t.me/netprimexapp');
  final Uri telegramApp = Uri.parse('https://t.me/netprimexapp');

  try {
    // Try to open Telegram app first
    if (await canLaunchUrl(telegramApp)) {
      await launchUrl(telegramApp, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web browser
      await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    print('Could not launch Telegram: $e');
  }
}
