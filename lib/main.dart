import 'dart:convert';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stundenplan/Struct/plan.dart';
import 'package:stundenplan/Struct/vorlesung.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HWRSP',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'HWR Studenplan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Plan> futurePlan;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    futurePlan = fetchPlan();
  }

  Future<Plan> fetchPlan() async {
    final response =
        await http.get(Uri.parse('http://192.168.178.33:4545/plan'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Plan.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('de');
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () => {
                      setState(() {
                        // requestUpdate();
                        futurePlan = fetchPlan();
                      })
                    },
                icon: Icon(Icons.refresh))
          ],
        ),
        body: FutureBuilder<Plan>(
            future: futurePlan,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data!.Vorlesungen.length);
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              _selectedDate =
                                  _selectedDate.subtract(Duration(days: 1));
                              setState(() {});
                            },
                            icon: Icon(Icons.arrow_left)),
                        TextButton(
                            onPressed: () {},
                            child:
                                Text(DateFormat.EEEE('de').format(_selectedDate))),
                        IconButton(
                            onPressed: () {
                              _selectedDate =
                                  _selectedDate.add(Duration(days: 1));
                              setState(() {});
                            },
                            icon: Icon(Icons.arrow_right))
                      ],
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemCount: snapshot.data!
                          .getVorlesungformDate(_selectedDate)
                          .length,
                      itemBuilder: (context, index) {
                        return veranstaltungsWidget(snapshot.data!
                            .getVorlesungformDate(_selectedDate)[index]);
                      },
                    ))
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return Center(child: const CircularProgressIndicator());
            }));
  }

  Widget veranstaltungsWidget(Vorlesung v) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Card(
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
                "Zeit: ${v.startZeit().hour}:${v.startZeit().minute} - ${v.endZeit().hour}:${v.endZeit().minute}"),
            Divider(),
            Text(v.Raum),
            Divider(),
            Text(v.Beschreibung),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
