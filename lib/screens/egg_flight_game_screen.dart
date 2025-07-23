import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class EggFlightGameScreen extends StatefulWidget {
  final VoidCallback onGameComplete;

  const EggFlightGameScreen({super.key, required this.onGameComplete});

  @override
  State<EggFlightGameScreen> createState() => _EggFlightGameScreenState();
}

class _EggFlightGameScreenState extends State<EggFlightGameScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _gameOver = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Egg Flight Game'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _hasError
          ? _buildErrorWidget()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Loading Game...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_gameOver)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Game Complete!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Returning to diary...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Loading Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Return to Diary'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initWebView() async {
    try {
      // Load the CSS and JS content from assets
      final cssContent = await rootBundle.loadString('assets/Egg_flight/Egg_flight/game.css');
      final jsContent = await rootBundle.loadString('assets/Egg_flight/Egg_flight/game.js');

      // Create the HTML with embedded CSS and JS
      final html = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8" />
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <title>Egg Flight</title>
          <style>
            body, html { 
              margin: 0; 
              padding: 0;
              width: 100%; 
              height: 100%; 
              overflow: hidden;
              touch-action: none;
              -ms-touch-action: none;
              background-color: #87CEEB;
            }
            .game-holder {
              width: 100%;
              height: 100%;
              position: relative;
            }
            #world { 
              width: 100%;
              height: 100%;
            }
            #threejs-canvas {
              width: 100% !important;
              height: 100% !important;
            }
            .header {
              position: absolute;
              top: 10px;
              left: 10px;
              z-index: 100;
            }
            .score {
              color: white;
              font-family: Arial, sans-serif;
              font-size: 18px;
              text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
            }
            #intro-screen {
              position: fixed;
              top: 0;
              left: 0;
              width: 100%;
              height: 100%;
              display: flex;
              justify-content: center;
              align-items: center;
              background-color: rgba(0, 0, 0, 0.7);
              z-index: 1000;
            }
            #intro-screen button {
              padding: 15px 30px;
              font-size: 20px;
              border: none;
              border-radius: 5px;
              background-color: #4CAF50;
              color: white;
              cursor: pointer;
            }
            #intro-screen.visible {
              display: flex;
            }
            #intro-screen.hidden {
              display: none;
            }
            .message--replay {
              position: fixed;
              top: 50%;
              left: 50%;
              transform: translate(-50%, -50%);
              color: white;
              font-size: 24px;
              font-weight: bold;
              text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
              z-index: 1000;
              display: none;
            }
          </style>
          <style>$cssContent</style>
        </head>
        <body>
          <div class="game-holder" id="gameHolder">
            <div class="header">
              <div class="score" id="score">
                <div class="score__content score__content--fixed" id="dist">
                  <div class="score__label">distance</div>
                  <div class="score__value score__value--dist" id="distValue">0</div>
                </div>
              </div>
            </div>
            <div class="world" id="world">
              <canvas id="threejs-canvas"></canvas>
            </div>
            <div class="message--replay" id="replayMessage">
              GAME OVER!
            </div>
            <div id="intro-screen" class="visible">
              <button type="button">Start Game</button>
            </div>
          </div>
          <script src="https://cdn.jsdelivr.net/npm/three@0.139.2/build/three.min.js"></script>
          <script src="https://cdn.jsdelivr.net/npm/three@0.139.2/examples/js/loaders/OBJLoader.js"></script>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.10.2/gsap.min.js"></script>
          <script>
            // Error handler
            window.onerror = function(message, source, lineno, colno, error) {
              console.error('Game Error:', message, 'at', source, 'line', lineno);
              if (window.GameChannel) {
                window.GameChannel.postMessage(JSON.stringify({type: 'error', message: message}));
              }
              return true;
            };
            
            // Game completion handler
            window.notifyGameComplete = function() {
              if (window.GameChannel) {
                window.GameChannel.postMessage(JSON.stringify({type: 'gameOver'}));
              }
            };
            
            // Initialize game
            document.addEventListener('DOMContentLoaded', function() {
              try {
                // Inject the game JavaScript
                const gameScript = document.createElement('script');
                gameScript.textContent = `$jsContent`;
                document.head.appendChild(gameScript);
                
                // Send ready signal
                if (window.GameChannel) {
                  window.GameChannel.postMessage(JSON.stringify({type: 'ready'}));
                }
              } catch (e) {
                console.error('Game initialization error:', e);
                if (window.GameChannel) {
                  window.GameChannel.postMessage(JSON.stringify({type: 'error', message: e.toString()}));
                }
              }
            });
          </script>
        </body>
        </html>
      ''';

      // Create platform-specific settings
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
        params = AndroidWebViewControllerCreationParams();
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      // Initialize WebView controller
      _controller = WebViewController.fromPlatformCreationParams(params);

      // Platform specific configurations
      if (_controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (_controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      // Configure the WebView
      await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _controller.setBackgroundColor(const Color(0xFF87CEEB));
      await _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      );
      
      await _controller.addJavaScriptChannel(
        'GameChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            final type = data['type'] as String;
            
            switch (type) {
              case 'gameOver':
                if (mounted) {
                  setState(() {
                    _gameOver = true;
                  });
                  widget.onGameComplete();
                  // Close the game screen after a delay
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }
                break;
              case 'error':
                debugPrint('Game Error: ${data['message']}');
                if (mounted) {
                  setState(() {
                    _hasError = true;
                    _errorMessage = data['message']?.toString() ?? 'Unknown game error';
                    _isLoading = false;
                  });
                }
                break;
              case 'ready':
                debugPrint('Game is ready');
                break;
              default:
                debugPrint('Game Message: $type');
            }
          } catch (e) {
            debugPrint('Error handling message from WebView: $e');
          }
        },
      );

      // Load the HTML content
      await _controller.loadHtmlString(html);
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load game files: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
