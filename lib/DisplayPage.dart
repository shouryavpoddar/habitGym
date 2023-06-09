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
  // stores the id of the user to negate re-Login
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Controls the Webview
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  // stores the Home Url, will be null when there is no saved id
  late Future<String?> _homeUrl;

  // visibilty indicator for the pop up menu
  bool _visible = false;

  /**
   * run only once by the program to see if there exits a home url
   */
  @override
  void initState() {
    super.initState();
    _homeUrl = _prefs.then((SharedPreferences prefs) {
      String url = prefs.getString("homeUrl") ?? "https://www.thehabitgym.com/reflections/activate";
      setState(() {
        _visible = !(url == "https://www.thehabitgym.com/reflections/activate");
      });
      return url;
    });
  }

  /**
   * visual the class is building
   */
  @override
  Widget build(BuildContext context) {
    return getScaffold();
  }

  /**
   * Saves the Home url
   */
  void homePageSaver(String url) async {
    final SharedPreferences pref = await this._prefs;
    pref.setString("homeUrl", url);
  }

  /**
   * deletes teh Home url
   */
  void homePageDelete() async {
    final SharedPreferences pref = await this._prefs;
    pref.remove("homeUrl");
  }

  /**
   * getter for the PopupMenu and the Logout button in it
   */
  Widget getPopupMenu() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext build, AsyncSnapshot<WebViewController> controller){
          return PopupMenuButton(
              itemBuilder: (BuildContext context){
                return [
                  PopupMenuItem(
                    child: TextButton(
                      child: const Text("Log out"),
                      onPressed: () {
                        setState(() {
                          controller.data?.loadUrl("https://www.thehabitgym.com/reflections/activate");
                          _visible = false;
                          homePageDelete();
                        });
                      },
                    ),
                  )
                ];
              }
          );
        }
    );
  }

  /**
   * getter for the Scaffold for the app
   */
  Widget getScaffold() {
    if(_visible){
      return Scaffold(
        body: getWebView(),
        appBar: AppBar(
          title: const Text("Habit Gym"),
          backgroundColor: const Color(0xFFfa8221),
          actions: [
            getPopupMenu(),
          ],
        ),
      );
    }
    else{
      return Scaffold(
        body: getWebView(),
        appBar: AppBar(
          title: const Text("Habit Gym"),
          backgroundColor: const Color(0xFFfa8221),
        ),
      );
    }
  }

  /**
   * getter for the WebView for the user
   */
  Widget getWebView(){
    return FutureBuilder<String?>(
      future: _homeUrl,
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
                  if (request.url.startsWith("https://www.thehabitgym.com/reflections/home/")) {
                    homePageSaver(request.url);
                  }
                  if (!request.url.startsWith("https://www.thehabitgym.com/reflections/activate")) {
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
    );
  }
}
