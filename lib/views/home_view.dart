//import 'dart:html';
//import 'package:app_settings/app_settings.dart';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:draw/draw.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//var red = Reddit.createInstalledFlowInstance(
Reddit red = Reddit.createInstalledFlowInstance(
    clientId: "3bRKD5NDBjeqXx6Ar-n3Vw",
    userAgent: "redd_tech_one",
    redirectUri: Uri.parse("redditech://success"));

/// _MyHomePageState we get the information from the Reddit API with Reddit.createInstalledFlowInstance.
/// Then, in the asynchronous function_launchReddit() function we use,
/// FlutterWebAuth.authenticate which retrieves the redirection URL and
/// user authentication and allows the navigation in the application thanks to the
/// "routes". The user's information are stored in currentUser.data.

class _MyHomePageState extends State<MyHomePage> {
  late String title, text;

  void _launchReddit() async {
    final authUrl = red.auth.url(["*"], "redditech", compactLogin: true);
    final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(), callbackUrlScheme: "redditech");
    String? code = Uri.parse(result).queryParameters['code'];
    await red.auth.authorize(code.toString());
    final currentUser = (await red.user.me()) as Redditor;
    final Stream<Subreddit> userSubReddits =
        red.user.subreddits(limit: 10).asBroadcastStream();

    ///Waiting information from API Reddit

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SecondRoute(
                currentUser: currentUser,
                userSubReddit: userSubReddits,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.orange[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Welcome to Redditech !",
                style:
                    new TextStyle(color: Colors.orangeAccent, fontSize: 30.0)),
            Image.network(
                'https://cdn.icon-icons.com/icons2/2221/PNG/512/logo_orange_reddit_icon_134370.png'),
            Card(
              color: Colors.orangeAccent,
              margin: EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  _launchReddit();
                },
                splashColor: Colors.orange[200],
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.account_circle_rounded,
                          size: 50.0, color: Colors.white),
                      Text("Login",
                          style: new TextStyle(
                              color: Colors.white, fontSize: 17.0))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// The information is then sent in the SecondRoute class, in order to be
/// be displayed to the user of the application. user of the application.
/// This class will allow the provision of user information and features of Reddit.
/// features of Reddit.

class SecondRoute extends StatefulWidget {
  late String title, text;
  final Redditor currentUser;
  final Stream<Subreddit> userSubReddit;

  SecondRoute(
      {Key? key, required this.currentUser, required this.userSubReddit})
      : super(key: key);

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

  @override
  State<SecondRoute> createState() {
    return _SecondRouteState();
  }
}

enum SubmissionType { top, hot, newest }

class _SecondRouteState extends State<SecondRoute> {
  late Future<List<Subreddit>> subredditsStream;
  late Future<List<Post>> _posts;
  //late String valueInput;

  List<Subreddit> subreddits = [];

  Future<List<Post>> _getPosts(
      SubmissionType type, Future<List<Subreddit>> subredditsStream) async {
    HashMap hashMap = HashMap<SubmissionType, List<Submission>>();
    List<Post> posts = [];

    for (Subreddit subreddit in await subredditsStream) {
      subreddits.add(subreddit);
      final Future<List<UserContent>> subRedditUserContent;
      //print("-------------------for");

      switch (type) {
        case SubmissionType.top:
          subRedditUserContent = subreddit.top(limit: 5).toList();
          break;
        case SubmissionType.hot:
          subRedditUserContent = subreddit.hot(limit: 5).toList();
          break;
        case SubmissionType.newest:
          subRedditUserContent = subreddit.newest(limit: 5).toList();
          break;
      }

      for (UserContent submission in await subRedditUserContent) {
        if (submission is SubmissionRef) {
          posts.add(Post(subreddit, await (submission.populate())));
          //print("-------------------if");
        }
      }
    }
    print("-------------------av Ret");
    return posts;
  }

  String dropdownvalue = "Newest";
  late Future<Subreddit> searchSubreddit;

  @override
  initState() {
    super.initState();
    subredditsStream = widget.userSubReddit.toList();
    print("------------------------------------------------" + dropdownvalue);
    _posts = _getPosts(SubmissionType.newest, subredditsStream);
    searchSubreddit = red.subreddit("Subreddit").populate();
  }

  // List of items in our dropdown menu
  var items = [
    'Top',
    'Newest',
    'Hot',
  ];

  @override
  Widget build(BuildContext context) {
    final String userName =
        widget.currentUser.data!['subreddit']['display_name'];
    final String iconImg = widget.currentUser.data!['snoovatar_img'].toString();
    final String description =
        widget.currentUser.data!['subreddit']['public_description'] == null
            ? ''
            : widget.currentUser.data!['subreddit']['public_description'];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.account_box_outlined)),
                Tab(icon: Icon(Icons.post_add)),
                Tab(icon: Icon(Icons.search)),
                Tab(icon: Icon(Icons.dynamic_feed_outlined)),
                Tab(icon: Icon(Icons.dynamic_feed_outlined)),
                Tab(icon: Icon(Icons.logout)),
              ],
            ),
            title: Text('Welcome $userName'),
            backgroundColor: Colors.orangeAccent,
            actions: [
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: DataSearch());
                  }),
              PopupMenuButton<int>(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Change Icon'),
                  ),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: Text('Language'),
                  ),
                  const PopupMenuItem<int>(
                    value: 4,
                    child: Text('Dark Mode'),
                  ),
                  const PopupMenuItem<int>(
                    value: 5,
                    child: Text('App Setting'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<int>(
                      value: 6,
                      child: Row(children: [
                        Icon(Icons.logout, color: Colors.black),
                        const SizedBox(width: 8),
                        Text('Logout'),
                      ])),
                ],
              )
            ],
          ),
          body: TabBarView(
            children: [
              Center(
                child: /*iconImg != ''
                      ? Image.network(
                          widget.currentUser.data!['snoovatar_img'].toString(),
                          width: 200,
                          height: 200,
                        )
                      : Image.network(
                          widget.currentUser.data!['icon_img'].toString(),
                        )*/
                    Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("PROFILE of $userName",
                        style: const TextStyle(
                            fontSize: 17.0, fontWeight: FontWeight.bold)),
                    iconImg != ''
                        ? Image.network(
                            widget.currentUser.data!['snoovatar_img']
                                .toString(),
                            width: 200,
                            height: 200,
                          )
                        : Image.network(
                            widget.currentUser.data!['icon_img'].toString(),
                          ),
                    Text(description.toString()),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                        'https://www.pngitem.com/pimgs/m/474-4746380_reddit-logo-art-hd-png-download.png'),
                    Text(
                      "Post a Subreddit",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a title'),
                      onChanged: (String val) {
                        widget.title = val;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a text'),
                      onChanged: (String val) {
                        widget.text = val;
                      },
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await widget.post(widget.title, widget.text);
                        },
                        child: const Text("Post")),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Find a subreddit to suscribe to",
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          setState(() {
                            searchSubreddit = red.subreddit(value).populate();
                          });
                        },
                        //controller: editingController,
                        decoration: InputDecoration(
                            labelText: "Search",
                            hintText: "Search",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)))),
                      ),
                    ),
                    Expanded(
                      child: searchSubreddit == null
                          ? const Text('-')
                          : FutureBuilder<Subreddit>(
                              future: searchSubreddit,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  Subreddit subreddit = snapshot.data!;
                                  return Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Card(
                                                color: Colors.orange[100],
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          LiteRollingSwitch(
                                                            iconOn: Icons
                                                                .unpublished,
                                                            iconOff:
                                                                Icons.check,
                                                            colorOn: Colors
                                                                .redAccent,
                                                            colorOff: Colors
                                                                .greenAccent,
                                                            textOn:
                                                                'Unsubscribe',
                                                            textOff:
                                                                'Subscribed',
                                                            textSize: 10.0,
                                                            value: false,
                                                            animationDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        700),
                                                            onChanged:
                                                                (bool state) {
                                                              if (state) {
                                                                subreddit
                                                                    .subscribe();
                                                              } else {
                                                                subreddit
                                                                    .unsubscribe();
                                                              }

                                                              print(
                                                                  'selected ${(state) ? 'subscribe' : 'unsubscribe'}');
                                                            },
                                                          ),
                                                          Text(
                                                              "name (/r) :" +
                                                                  subreddit
                                                                      .displayName,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                          Text(
                                                              "title  : " +
                                                                  subreddit.data![
                                                                      "title"],
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                          Text(
                                                              "nb sub : " +
                                                                  subreddit
                                                                      .data![
                                                                          "subscribers"]
                                                                      .toString(),
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                          Text(
                                                              "description : " +
                                                                  subreddit.data![
                                                                      "public_description"],
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                        ])))
                                          ]));
                                } else if (snapshot.hasError) {
                                  return Text(
                                      'Delivery error: ${snapshot.error.toString()}');
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }),
                    ),
                  ],
                ),
              ),
              Center(
                  //Container(child: Column(children: [],))
                  child: FutureBuilder<List<Post>>(
                future: _posts,
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Text('Loading...');
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final Post post = snapshot.data![index];
                          // final SubredditTraffic subredditTraffic = snapshot.data![index];
                          late Subreddit subreddit;
                          //print(post.subreddit);

                          for (var i = 0; i < subreddits.length; i++) {
                            if (post.subreddit.displayName ==
                                subreddits[i].displayName) {
                              subreddit = subreddits[i];
                            }
                          }

                          return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Card(
                                        color: Colors.orange[100],
                                        child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  LiteRollingSwitch(
                                                    iconOn: Icons.unpublished,
                                                    iconOff: Icons.check,
                                                    colorOn: Colors.redAccent,
                                                    colorOff:
                                                        Colors.greenAccent,
                                                    textOn: 'Unsubscribe',
                                                    textOff: 'Subscribed',
                                                    textSize: 10.0,
                                                    value: false,
                                                    animationDuration: Duration(
                                                        milliseconds: 700),
                                                    onChanged: (bool state) {
                                                      //submission.subreddit
                                                      //    .unsubscribe();
                                                      print(
                                                          'selected ${(state) ? 'subscribe' : 'unsubscribe'}');
                                                    },
                                                  ),
                                                  Text(
                                                      "name (/r) :" +
                                                          post.subreddit
                                                              .displayName,
                                                      style: const TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  Text(
                                                      "title  : " +
                                                          post.subreddit
                                                              .data!["title"],
                                                      style: const TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  Text(
                                                      "nb sub : " +
                                                          post
                                                              .subreddit
                                                              .data![
                                                                  "subscribers"]
                                                              .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  Text(
                                                      "description : " +
                                                          post.subreddit.data![
                                                              "public_description"],
                                                      style: const TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  //Padding between these please
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      subreddit.headerImage
                                                          .toString(),
                                                      width: 100.0,
                                                      height: 100.0,
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object exception,
                                                              StackTrace?
                                                                  stackTrace) {
                                                        return Image.network(
                                                          /* subreddit.iconImage
                                                              .toString(),
                                                          width: 100.0,
                                                          height: 100.0,*/

                                                          'https://i.redd.it/iz7o4kvirrm41.png',
                                                          width: 80.0,
                                                          height: 80.0,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Text(
                                                      "r/" +
                                                          post.subreddit
                                                              .displayName,
                                                      style: const TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight: FontWeight
                                                              .normal)),

                                                  Text(
                                                      ' publié par ' +
                                                          post.submission
                                                              .author +
                                                          '\n\n',
                                                      style: const TextStyle(
                                                          fontSize: 17.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  Text(
                                                      post.submission.title +
                                                          '\n\n',
                                                      style: const TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      post.submission
                                                              .selftext ??
                                                          ' - ' + '\n\n',
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  Image.network(
                                                    post.submission.thumbnail
                                                        .toString(),
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object exception,
                                                            StackTrace?
                                                                stackTrace) {
                                                      return Image.network(
                                                        'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101028/112815904-no-image-available-icon-flat-vector-illustration.jpg?ver=6',
                                                        width: 100.0,
                                                        height: 100.0,
                                                      );
                                                    },
                                                  ),
                                                  Text(
                                                      "upvotes :" +
                                                          post.submission
                                                              .upvotes
                                                              .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  Text(
                                                      "downvotes :" +
                                                          post.submission
                                                              .downvotes
                                                              .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                  Text(
                                                      "comments :" +
                                                          post.submission
                                                              .numComments
                                                              .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                ])))
                                  ]));
                        },
                        itemCount: snapshot.data!.length);
                  } else {
                    return const Text('Loading...');
                  }
                },
              )),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton(
                      // Initial Value
                      value: dropdownvalue,

                      // Down Arrow Icon
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                          if (dropdownvalue == "Top") {
                            _posts =
                                _getPosts(SubmissionType.top, subredditsStream);
                          }
                          if (dropdownvalue == "Hot") {
                            _posts =
                                _getPosts(SubmissionType.hot, subredditsStream);
                          }
                          if (dropdownvalue == "Newest") {
                            _posts = _getPosts(
                                SubmissionType.newest, subredditsStream);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    Image.network('https://i.imgur.com/LqlY8Rw.png'),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate back to first route when tapped.
                        },
                        child: const Text('Logout'))
                  ]))
            ],
          ),
        ),
      ),
    );
  }

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
      case 4:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => build(context)));
        break;
      case 5:
        //AppSettings.openAppSettings();
        break;
      case 6:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MyHomePage(title: "Redditech")));
        break;
    }
  }
}

class DataSearch extends SearchDelegate<String> {
  final cities = ["nasa", "Melbourne", "OnePieceTC", "OnePiece"];

  final recentCities = [
    "nasa",
    "Melbourne",
    "OnePieceTc",
    "OnePiece",
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    // action for app bar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on the selection
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionList = query.isEmpty ? recentCities : cities;

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.location_city),
        title: Text(suggestionList[index]),
      ),
      itemCount: suggestionList.length,
    );
    throw UnimplementedError();
  }
}

class Post {
  Subreddit subreddit;
  Submission submission;

  Post(this.subreddit, this.submission);
}
