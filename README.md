Redditech:
=================================

Application using Reddit API.
Use of DRAW: Dart Reddit API Wrapper to provides simple access to the Reddit API.
 
Package import :  
[flutter_web-auth](https://pub.dev/packages/flutter_web_auth)  
[oauth2_client](https://pub.dev/packages/oauth2_client)  
[draw](https://pub.dev/packages/draw)  

# Installation
- Install Flutter
- Install Android Studio

> flutter add draw  
> flutter packages get  
> flutter pub add web_auth  
> flutter doctor

# Getting Started
Get your [Reddit OAuth credentials](https://github.com/reddit/reddit/wiki/OAuth2) before starting the project.

Starting with connecting the API:

```dart
import 'dart:async';
import 'package:draw/draw.dart';

// Create the `Reddit` instance and authenticated
Reddit red = Reddit.createInstalledFlowInstance(
    clientId: "3bRKD5NDBjeqXx6Ar-n3Vw",
    userAgent: "redd_tech_one",
    redirectUri: Uri.parse("redditech://success"));

  // Retrieve information for the currently authenticated user
  Redditor currentUser = await reddit.user.me();

```
# How run the App

## Environnement :
### - Android studio
### - Visual Studio Code
## Command to run the application :

```
$ flutter run
or
$ flutter run --no-sound-null-safety
```
### Warning :
For a better experience with the application, it is recommended to launch the application on your smartphone. (Don't forget to activate the debug mode by USB)

### Important :
Wait at least 10 seconds for the display of all assets.
When changing the subs (New, Hot, Top), wait at least 10 seconds for the display.


# Web Authentication
To authenticate via the Reddit authentication page, this requires that a web application is registered with a valid Reddit account, which provides a `client-id`. As part of this process, a `redirect URL` is associated with the registered web application. 


```dart
import 'package:draw/draw.dart';

void _launchReddit() async {
    final authUrl = red.auth.url(["*"], "redditech", compactLogin: true);
    final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(), callbackUrlScheme: "redditech");
    String? code = Uri.parse(result).queryParameters['code'];
    await red.auth.authorize(code.toString());

  // Use of FlutterWebAuth to connect with the call back URL, then authorize with red.auth.authorize
}
```
# Subreddits display

Retrieve informations and displays subreddits :

```dart
final String userName =
        widget.currentUser.data!['subreddit']['display_name'];
    final String iconImg = widget.currentUser.data!['icon_img'];
    final String description =
        widget.currentUser.data!['subreddit']['description'];

    Future<List<Submission>> getSubmissions() async {
      List<Submission> posts = [];

      widget.userSubReddit.listen((subReddit) {
        //print("Subreddit : " + subReddit.toString());
        final Stream<UserContent> subRedditUserContent =
            subReddit.top(limit: 10);

        subRedditUserContent.listen((subreddit) async {
          if (subreddit is SubmissionRef) {
            //print("post: " + subreddit.toString());

            posts.add(await (subreddit.populate()));
               }
        });
      });

      return posts;
    }

final Future<List<Submission>> submissions = getSubmissions();
```

# Subreddits Post

Post subreddits with title and text :

```dart
Future<void> post(String title, String text) async {
    var sub = red.subreddit("Subreddit");
    await sub.submit(title, selftext: text).then((value) {
      Fluttertoast.showToast(
          msg: "Done",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
```
# Settings bar

Icon menu for settings user :

```dart
// Afficher le bouton et y entrer les paramètres
actions: [
              PopupMenuButton<int>(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text('Settings'),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('Profile'),
                  ),
    // [...] Code

// Selected actions of differents cases
void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        print('Settings');
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => build(context)));
        break;
      case 2:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => build(context)));
        break;
      case 3:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => build(context)));
        break;
    }
  }
}
```

# Choose What kind of feed you want to display :

The type of user's feed are initialize in this :

```dart
await for (var subreddit in subredditsStream) {
      subreddits.add(subreddit);
      final Stream<UserContent> subRedditUserContent;

      switch (type) {
        case SubmissionType.top:
          subRedditUserContent = subreddit.top(limit: 10);
          break;
        case SubmissionType.hot:
          subRedditUserContent = subreddit.hot(limit: 10);
          break;
        case SubmissionType.newest:
          subRedditUserContent = subreddit.newest(limit: 10);
          break;
      }

```
But for choosing if, you want to display by the top, hot or newest submission, you have to change it there : 
```dart
@override
  initState() {
    super.initState();
    //final Future<List<Submission>> submissions = getSubmissions();
    subredditsStream = widget.userSubReddit;
    _submissions = _getSubmissions(SubmissionType.hot, subredditsStream);
  }
```

# NavBar

Post subreddits with title and text :

```dart
appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.add_box_outlined)),
                Tab(icon: Icon(Icons.account_box_outlined)),
                Tab(icon: Icon(Icons.account_box_outlined)),
                Tab(icon: Icon(Icons.dynamic_feed_outlined)),
                Tab(icon: Icon(Icons.logout)),
              ],
            ),
            ...
            body: TabBarView( ...)
```
# Visual

```dart
Image.network(
                'https://cdn.icon-icons.com/icons2/2221/PNG/512/logo_orange_reddit_icon_134370.png')
    // Implement Image.network at the right widget
```

# Pubspec dependencies

Here's an example of what should like your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter


  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.2
  draw: ^1.0.2
  flutter_web_auth: ^0.3.1
  flutter_appauth: ^1.1.0+2
  http: ^0.13.4
  flutter_svg: ^0.18.0
  fluttertoast: ^8.0.7
  flutter_typeahead: ^3.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
```

Youssra El-Ajli : youssra.el-ajli@epitech.eu  
Hugo Suzanne    : hugo.suzanne@epitech.eu  