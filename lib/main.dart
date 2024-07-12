import 'package:aqary/bloc/repositery_bloc.dart';
import 'package:aqary/bloc/repositery_event.dart';

import 'package:aqary/home.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('repositories'); // Open a box for storing repositories
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RepositoryBloc()..add(FetchRepositories()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: RepositoryListScreen(),
      ),
    );
  }
}
