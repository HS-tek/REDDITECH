import 'package:flutter/material.dart';
import 'package:draw/draw.dart';
//import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redditeck/views/home_view.dart';
//import 'dart:convert';
//import 'package:flutter/services.dart' show rootBundle;
//import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redditech',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Redditech'),
      debugShowCheckedModeBanner: false,
    );
  }
}