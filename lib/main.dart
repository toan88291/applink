import 'dart:io';

import 'package:facebook_deeplinks/facebook_deeplinks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_social/new_screen.dart';
import 'package:flutter_app_social/screenshot/screenshot.dart';
import 'package:social_share_plugin/social_share_plugin.dart';

void main() {
  runApp(MaterialApp(home: MyApp(),));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScreenshotController screenshotController = ScreenshotController();

  String _platformVersion = 'Unknown';

  String _deeplinkUrl = 'Unknown';

  String pathImage;

  Future<void> initPlatformState() async {
    String deeplinkUrl;

    var facebookDeeplinks = FacebookDeeplinks();
    facebookDeeplinks.onDeeplinkReceived.listen(_onRedirected);
    _deeplinkUrl = await facebookDeeplinks.getInitialUrl();

    if (!mounted) return;

    _onRedirected(_deeplinkUrl);
  }

  @override
  BuildContext get context => super.context;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initPlatformState();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Screenshot(
        controller: screenshotController,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Center(
                  child: Text('Running on: $_deeplinkUrl\n'),
                ),
                RaisedButton(
                  child: Text('Share to Facebook'),
                  onPressed: () async {
                    screenshotController
                        .capture()
                        .then((File image) async {
                      await SocialSharePlugin.shareToFeedFacebook(
                          path: image.path,
                          caption: "abc",
                          onSuccess: (_) {
                            print('FACEBOOK SUCCESS');
                            return;
                          },
                          onCancel: () {
                            print('FACEBOOK CANCELLED');
                            return;
                          },
                          onError: (error) {
                            print('FACEBOOK ERROR $error');
                            return;
                          });

                    }).catchError((onError) {
                      print(onError);
                    });
                  },
                ),
                RaisedButton(
                  child: Text('Share to Facebook Link'),
                  onPressed: () async {
                    String url = 'https://ielts-fighters.appspot.com/deeplink?shareId=902341603-1592409848518-104214183_1110271419373384_8933698465474698038_n';
                    final quote =
                        'https://ielts-fighters.appspot.com/deeplink?shareId=902341603-1592409848518-104214183_1110271419373384_8933698465474698038_n';
                    final result =
                    await SocialSharePlugin.shareToFeedFacebookLink(
                      quote: quote,
                      url: url,
                      onSuccess: (_) {
                        print('FACEBOOK SUCCESS');
                        return;
                      },
                      onCancel: () {
                        print('FACEBOOK CANCELLED');
                        return;
                      },    
                      onError: (error) {
                        print('FACEBOOK ERROR $error');
                        return;
                      },
                    );

                    print(result);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRedirected(String uri) {
   if (uri != null) {
     setState(() {
       _deeplinkUrl = uri;
     });
     debugPrint('link: $_deeplinkUrl');
     if (_deeplinkUrl.contains("view%3Dhome")) {
       Navigator.push(context, MaterialPageRoute(
           builder: (BuildContext context) => NewScreen()
       ));
     }
   }
  }
}