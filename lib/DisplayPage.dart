import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DisplayPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return Page();
  }

}

class Page extends State<DisplayPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final Completer<WebViewController> _controller = Completer<
      WebViewController>();

  late Future<String?> _HomeUrl;

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _HomeUrl = _prefs.then((SharedPreferences prefs) {
      String url = prefs.getString("homeUrl") ?? "https://www.thehabitgym.com/reflections/activate";
      setState(() {
        _visible = !(url == "https://www.thehabitgym.com/reflections/activate");
      });
      return url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return getScaffold();
  }

  void homePageSaver(String url) async {
    final SharedPreferences pref = await this._prefs;
    pref.setString("homeUrl", url);
  }

  void homePageDelete() async {
    final SharedPreferences pref = await this._prefs;
    pref.remove("homeUrl");
  }

  Widget getHamburgerMenu() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder: (BuildContext build,
          AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      /*image: const DecorationImage(
                      image: Image.asset("assests/images/Logo.pnd")
                    ),*/
                    ),
                    child: Text('Drawer Header'),
                  ),
                  ListTile(
                    title: const Text('Log Out'),
                    onTap: () {
                      setState(() {
                        controller.data?.loadUrl(
                            "https://www.thehabitgym.com/reflections/activate");
                        _visible = false;
                        homePageDelete();
                      });
                    },
                  ),
                ],
              )
          );
        }
        return Container();
      },
    );
  }
  Widget getScaffold() {
    if(_visible){
      return Scaffold(
        body: FutureBuilder<String?>(
          future: _HomeUrl,
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: snapshot.data,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                    },
                    navigationDelegate: (NavigationRequest request) {
                      if (request.url.startsWith(
                          "https://www.thehabitgym.com/reflections/home/")) {
                        homePageSaver(request.url);
                      }
                      if (request.url.startsWith(
                          "https://www.thehabitgym.com/reflections/activate") ==
                          false) {
                        setState(() {
                          _visible = true;
                        });
                      }
                      return NavigationDecision.navigate;
                    },
                  );
                }
            }
          },
        ),
        appBar: AppBar(
          title: Text("Habit Gym"),
          backgroundColor: Color(0xFFfa8221),
          actions: [
            FutureBuilder<WebViewController>(
                future: _controller.future,
                builder: (BuildContext build, AsyncSnapshot<WebViewController> controller){
                  return PopupMenuButton(
                      itemBuilder: (BuildContext context){
                        return [
                          PopupMenuItem(
                            child: Visibility(
                              visible: _visible,
                              child: TextButton(
                                child: Text("Log out"),
                                onPressed: () {
                                  setState(() {
                                    controller.data?.loadUrl("https://www.thehabitgym.com/reflections/activate");
                                    _visible = false;
                                    homePageDelete();
                                  });
                                },
                              ),
                            ),
                          )
                        ];
                      }
                  );
                }
            )
          ],
        ),
      );
    }
    else{
      return Scaffold(
        body: FutureBuilder<String?>(
          future: _HomeUrl,
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: snapshot.data,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                    },
                    navigationDelegate: (NavigationRequest request) {
                      if (request.url.startsWith(
                          "https://www.thehabitgym.com/reflections/home/")) {
                        homePageSaver(request.url);
                      }
                      if (request.url.startsWith(
                          "https://www.thehabitgym.com/reflections/activate") ==
                          false) {
                        setState(() {
                          _visible = true;
                        });
                      }
                      return NavigationDecision.navigate;
                    },
                  );
                }
            }
          },
        ),
        appBar: AppBar(
          title: Text("Habit Gym"),
          backgroundColor: Color(0xFFfa8221),
        ),
      );
    };
  }

}


/*
 */
