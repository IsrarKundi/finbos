import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controllers/webview_controller.dart' as controllers;
import '../controllers/bottom_nav_controller.dart';
import '../widgets/fancy_bottom_nav_bar.dart';
import '../widgets/no_internet_widget.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final controllers.WebViewController _webViewController =
      controllers.WebViewController();
  final BottomNavController _navController = BottomNavController();
  late PullToRefreshController _pullToRefreshController;
  bool _showSplash = true;
  bool _hasInternet = true;
  bool _isOnAuthPage = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Ensure splash is visible at start
    setState(() {
      _showSplash = true;
    });

    // Set status bar for splash screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF4DDAFA), // Match splash cyan color
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _checkInternetConnection();
    _setupConnectivityListener();

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.deepPurple),
      onRefresh: () async {
        await _webViewController.reload();
      },
    );

    // Hide splash after minimum time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
        // Reset status bar after splash
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = !connectivityResult.contains(ConnectivityResult.none);
    });
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      setState(() {
        _hasInternet = !result.contains(ConnectivityResult.none);
      });
    });
  }

  void _handleRetry() {
    _checkInternetConnection();
    if (_hasInternet) {
      _webViewController.reload();
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _navController.updateIndex(index);
    });

    // Navigate to the selected URL
    final url = _navController.getUrlByIndex(index);
    _webViewController.webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  void _updateSelectedTabFromUrl(String url) {
    String normalizedUrl = url.toLowerCase();

    // Check which tab matches the current URL
    int matchedIndex = 0; // Default to Dashboard

    if (normalizedUrl.contains('/transactions')) {
      matchedIndex = 1;
    } else if (normalizedUrl.contains('/decisionmaking') ||
        normalizedUrl.contains('/ai')) {
      matchedIndex = 2;
    } else if (normalizedUrl.contains('/settings')) {
      matchedIndex = 3;
    } else if (normalizedUrl.contains('/dashboard')) {
      matchedIndex = 0;
    }

    if (_navController.selectedIndex != matchedIndex) {
      setState(() {
        _navController.updateIndex(matchedIndex);
      });
    }
  }

  // Future<void> _hideSocialLoginOptions(
  //   InAppWebViewController controller,
  // ) async {
  //   try {
  //     await controller.evaluateJavascript(
  //       source: """
  //       (function() {
  //         if (window.socialHiderAdded) return;
  //         window.socialHiderAdded = true;

  //         function hideElements() {
  //           const currentUrl = window.location.href.toLowerCase();
  //           const isAuthPage = currentUrl.includes('login') || 
  //                              currentUrl.includes('signin') || 
  //                              currentUrl.includes('signup') ||
  //                              currentUrl.includes('register') ||
  //                              currentUrl.includes('auth');
  //           
  //           if (!isAuthPage) return;

  //           const keywords = ['google', 'facebook', 'microsoft'];
  //           const elements = document.querySelectorAll('button, a, div[role="button"]');
  //           
  //           elements.forEach(el => {
  //             const text = (el.innerText || '').toLowerCase();
  //             const hasKeyword = keywords.some(keyword => text.includes(keyword));
  //             
  //             if (hasKeyword) {
  //               if (text.includes('continue') || text.includes('sign') || text.includes('log') || text.includes('with')) {
  //                  el.style.display = 'none';
  //               }
  //             }
  //           });

  //           // Hide OR separator
  //           const separators = document.querySelectorAll('div, span, p');
  //           separators.forEach(el => {
  //             const text = (el.innerText || '').toLowerCase().trim();
  //             // Check for "or" with dashes or just "or"
  //             if (text === 'or' || text.includes('---or---') || (text.includes('or') && text.includes('---'))) {
  //                // Ensure we are targeting the leaf node or a specific separator container
  //                if (el.children.length === 0) {
  //                   el.style.display = 'none';
  //                }
  //             }
  //           });
  //         }

  //         hideElements();

  //         const observer = new MutationObserver((mutations) => {
  //           hideElements();
  //         });
  //         
  //         observer.observe(document.body, {
  //           childList: true,
  //           subtree: true
  //         });
  //       })();
  //     """,
  //     );
  //   } catch (e) {
  //     // Ignore errors
  //   }
  // }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _webViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          await _webViewController.goBack();
          return false;
        }
        return true;
      },
      child: Stack(
        children: [
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              // appBar: AppBar(
              //   title: const Text('Finbos'),
              //   backgroundColor: Colors.deepPurple,
              //   foregroundColor: Colors.white,
              //   elevation: 0,
              //   actions: [
              //     IconButton(
              //       icon: const Icon(Icons.refresh),
              //       onPressed: () => _webViewController.reload(),
              //     ),
              //   ],
              // ),
              body: _hasInternet
                  ? Column(
                      children: [
                        // _webViewController.progress < 1.0
                        //     ? LinearProgressIndicator(
                        //         value: _webViewController.progress,
                        //         backgroundColor: Colors.grey[200],
                        //         valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        //       )
                        //     : const SizedBox.shrink(),
                        Expanded(
                          child: InAppWebView(
                            initialUrlRequest: URLRequest(
                              url: WebUri(_navController.getCurrentUrl()),
                            ),
                            pullToRefreshController: _pullToRefreshController,
                            initialSettings: InAppWebViewSettings(
                              useShouldOverrideUrlLoading: true,
                              mediaPlaybackRequiresUserGesture: false,
                              javaScriptEnabled: true,
                              javaScriptCanOpenWindowsAutomatically: true,
                              useHybridComposition: true,
                              clearCache: false,
                              cacheEnabled: true,
                              thirdPartyCookiesEnabled: true,
                              allowFileAccess: true,
                              supportZoom: false,
                            ),
                            onWebViewCreated: (controller) async {
                              _webViewController.setWebViewController(
                                controller,
                              );

                              // Add JavaScript handler to detect logout/login events
                              controller.addJavaScriptHandler(
                                handlerName: 'authEventHandler',
                                callback: (args) {
                                  // Handle auth events
                                  if (mounted) {
                                    controller.reload();
                                  }
                                },
                              );
                            },
                            shouldOverrideUrlLoading:
                                (controller, navigationAction) async {
                                  var uri = navigationAction.request.url;

                                  if (uri != null) {
                                    String urlString = uri
                                        .toString()
                                        .toLowerCase();

                                    // Allow navigation but check if coming from login with from_url
                                    if (urlString.contains('from_url=') &&
                                        !urlString.contains('/login')) {
                                      // User successfully logged in, extract the from_url and navigate there
                                      var fromUrl = Uri.parse(
                                        uri.toString(),
                                      ).queryParameters['from_url'];
                                      if (fromUrl != null) {
                                        Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                            controller.loadUrl(
                                              urlRequest: URLRequest(
                                                url: WebUri(fromUrl),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }
                                  }

                                  return NavigationActionPolicy.ALLOW;
                                },
                            onLoadStart: (controller, url) {
                              setState(() {
                                _webViewController.updateProgress(0);
                              });
                              // Check if user is being redirected to login/signup pages
                              if (url != null) {
                                String urlString = url.toString().toLowerCase();
                                if (urlString.contains('/login') ||
                                    urlString.contains('/signin') ||
                                    urlString.contains('/signup') ||
                                    urlString.contains('/register')) {
                                  // On auth page - hide navbar
                                  setState(() {
                                    _isOnAuthPage = true;
                                  });
                                } else {
                                  setState(() {
                                    _isOnAuthPage = false;
                                  });
                                  _updateSelectedTabFromUrl(url.toString());
                                }
                              }
                            },
                            onProgressChanged: (controller, progress) {
                              if (progress == 100) {
                                _pullToRefreshController.endRefreshing();
                              }
                              setState(() {
                                _webViewController.updateProgress(
                                  progress.toDouble(),
                                );
                              });
                            },
                            onLoadStop: (controller, url) async {
                              _pullToRefreshController.endRefreshing();
                              setState(() {
                                _webViewController.updateProgress(100);
                              });
                              // Hide splash if it's still showing
                              if (_showSplash) {
                                setState(() {
                                  _showSplash = false;
                                });
                              }

                              // Inject JavaScript to monitor logout button clicks only
                              try {
                                await controller.evaluateJavascript(
                                  source: """
                        (function() {
                          if (window.authListenerAdded) return;
                          window.authListenerAdded = true;
                          
                          // Monitor button clicks for logout only
                          document.addEventListener('click', function(e) {
                            var element = e.target;
                            
                            // Traverse up to find button/link
                            for (var i = 0; i < 5 && element; i++) {
                              var text = (element.innerText || element.textContent || element.value || '').toLowerCase();
                              var href = (element.href || '').toLowerCase();
                              var classList = element.className || '';
                              
                              // Check for logout button
                              if (text.includes('logout') || text.includes('log out') || 
                                  text.includes('sign out') || classList.includes('logout') ||
                                  href.includes('logout')) {
                                setTimeout(function() {
                                  window.location.href = 'https://finbos.app/Dashboard';
                                }, 1500);
                                break;
                              }
                              
                              element = element.parentElement;
                            }
                          }, true);
                        })();
                      """,
                                );
                              } catch (e) {
                                // Ignore JavaScript injection errors
                              }

                              // Inject JavaScript to hide social login options
                              // await _hideSocialLoginOptions(controller);

                              // Check if on login/auth pages after logout
                              if (url != null) {
                                String urlString = url.toString().toLowerCase();
                                // If user lands on login/signup page, they likely logged out
                                if (urlString.contains('/login') ||
                                    urlString.contains('/signin') ||
                                    urlString.contains('/signup') ||
                                    urlString.contains('/register') ||
                                    urlString.contains('/auth')) {
                                  // On auth page - hide navbar and reset to dashboard tab
                                  setState(() {
                                    _isOnAuthPage = true;
                                    _navController.updateIndex(0);
                                  });
                                } else {
                                  // Not on auth page - show navbar
                                  setState(() {
                                    _isOnAuthPage = false;
                                  });
                                  // Update selected tab based on current URL
                                  _updateSelectedTabFromUrl(url.toString());
                                }
                              }
                            },
                            onReceivedError: (controller, request, error) {
                              _pullToRefreshController.endRefreshing();
                            },
                            onUpdateVisitedHistory: (controller, url, androidIsReload) {
                              // This fires when URL changes (including back/forward navigation)
                              if (url != null) {
                                String urlString = url.toString().toLowerCase();

                                // Check if on auth page
                                if (urlString.contains('/login') ||
                                    urlString.contains('/signin') ||
                                    urlString.contains('/signup') ||
                                    urlString.contains('/register') ||
                                    urlString.contains('/auth')) {
                                  // On auth page - hide navbar
                                  setState(() {
                                    _isOnAuthPage = true;
                                  });
                                } else {
                                  // Not on auth page - show navbar and update tab
                                  setState(() {
                                    _isOnAuthPage = false;
                                  });
                                  _updateSelectedTabFromUrl(url.toString());
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : NoInternetWidget(onRetry: _handleRetry),
              extendBody: true,
              bottomNavigationBar: (_hasInternet && !_showSplash)
                  ? FancyBottomNavBar(
                      selectedIndex: _navController.selectedIndex,
                      onTabChange: _onTabChange,
                    )
                  : null,
            ),
          ),
          // Splash overlay - MUST BE LAST to be on top
          if (_showSplash)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  // Top 70% with cyan color
                  Expanded(
                    flex: 70,
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF4DDAFA),
                      child: const Center(
                        child: Text(
                          'Finbos',
                          style: TextStyle(
                            fontSize: 48,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom 30% with black color
                  Expanded(
                    flex: 30,
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          'Finance with AI',

                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
