import 'package:flutter/material.dart';
import 'package:hasthemall/api.dart';
import 'package:hasthemall/setlist/view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Api api = Api();

  bool initiated = false;

  @override
  Widget build(BuildContext context) {
    if (!initiated) {
      initiated = true;
      api.run();
    }
    return Scaffold(
        body: StreamBuilder<ApiOutput>(
      stream: api.output.stream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const Text("err");
        } else {
          if (data.setLists.isNotEmpty) {
            return ListView(
              children:
                  data.setLists.map((sl) => SetlistWidget(sl: sl)).toList(),
            );
          } else {
            return LinearProgressIndicator(
              value: data.progress,
            );
          }
        }
      },
    ));
  }
}


