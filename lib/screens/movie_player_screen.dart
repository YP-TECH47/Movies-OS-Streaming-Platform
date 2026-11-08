import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; // Note: Webview implementation on Flutter Web might not fully support all NavigationDelegate hooks...

class MoviePlayerScreen extends StatefulWidget {
  final String movieUrl;
  final String movieTitle;

  const MoviePlayerScreen({Key? key, required this.movieUrl, required this.movieTitle}) : super(key: key);

  @override
  State<MoviePlayerScreen> createState() => _MoviePlayerScreenState();
}

class _MoviePlayerScreenState extends State<MoviePlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = !kIsWeb;
  bool _pageLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController();
    
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {
               if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _pageLoaded = true;
                });
              }
              
              
              _controller.runJavaScript('''
              
                window.open = function() { return null; };
                
                
                document.addEventListener('click', function(e) {
                  var target = e.target;
                  while (target != null) {
                    if (target.tagName === 'A' && target.target === '_blank') {
                      target.removeAttribute('target'); 
                    }
                    target = target.parentElement;
                  }
                }, true);
                
              
                setInterval(function() {
                   var links = document.querySelectorAll('a[target="_blank"]');
                   for(var i=0; i<links.length; i++) {
                     links[i].removeAttribute('target');
                   }
                }, 1000);
              ''');
            },
            onNavigationRequest: (NavigationRequest request) {
              final requestUri = Uri.parse(request.url);
              final initialUri = Uri.parse(widget.movieUrl);
              
            v
              if (!request.url.startsWith('http')) {
                return NavigationDecision.prevent;
              }
v
              final blockedHosts = [
                'adsterra', 'popads', 'popcash', 'propellerads', 'onclick', 'adcash', 
                'exoclick', 'doubleclick', 'syndication', 'voluum', 'tracking'
              ];
              
              for (var host in blockedHosts) {
                if (requestUri.host.contains(host)) {
                  return NavigationDecision.prevent;
                }
              }

           
              if (_pageLoaded && request.isMainFrame) {
                  final reqHost = requestUri.host.replaceAll('www.', '');
                  final initHost = initialUri.host.replaceAll('www.', '');
                 
                  if (!reqHost.contains(initHost) && !initHost.contains(reqHost)) {
                      return NavigationDecision.prevent;
                  }
              }
              
           
              return NavigationDecision.navigate;
            },
          ),
        );
    }
    
    _controller.loadRequest(Uri.parse(widget.movieUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.movieTitle),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            ),
        ],
      ),
    );
  }
}
