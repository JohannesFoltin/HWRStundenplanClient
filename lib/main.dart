// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


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
    futurePlan = _loadPlanFormOnline();
  }

  void _showSnackBar(String text) {
    var snackBar =
        SnackBar(duration: Duration(seconds: 1), content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
          ],
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var key = "SAVE";

  Future<Plan> _loadPlanFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      _showSnackBar("Erfolgreich Daten lokal geladen");
      return Plan.fromJson(jsonDecode(prefs.getString(key) ?? ""));
    } catch (error) {
      _showSnackBar("Keine Daten lokal vorhanden");
      return Future<Plan>.error("Keine Daten lokal vorhanden");
    }
  }

  Future<Plan> _loadPlanFormOnline() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.178.33:4545/plan'));
      if (response.statusCode == 200) {
        _showSnackBar("Erfolgreich aus dem Internet geladen");
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(key, response.body);
        return Plan.fromJson(jsonDecode(response.body));
      } else {
        return Future<Plan>.error("Server antwortet komisch");
      }
    } catch (error) {
      _showSnackBar("Server nicht erreicht. Versuche es aus dem Speicher");
      return _loadPlanFromLocal();   
      }

  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        currentDate: DateTime.now(),
        helpText: "Wähle einen Tag",
        initialDate: _selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pullRefresh() async {
    setState(() {
      futurePlan = _loadPlanFormOnline();
    });
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('de');
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: TextButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
            child: Text(
              "Heute",
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: TextButton(
            child: Text(
              DateFormat.EEEE('de').format(_selectedDate),
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            onPressed: () => _selectDate(context),
          ),
        ),
        body: FutureBuilder<Plan>(
            future: futurePlan,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RefreshIndicator(
                  onRefresh: () => _pullRefresh(),
                  child: Column(
                    children: [
                      Expanded(
                          child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          int sensitivity = 0;
                          // Swiping in right direction.
                          if (details.primaryVelocity! > sensitivity) {
                            _selectedDate =
                                _selectedDate.subtract(Duration(days: 1));
                            setState(() {});
                          }

                          // Swiping in left direction.
                          if (details.primaryVelocity! < sensitivity) {
                            _selectedDate =
                                _selectedDate.add(Duration(days: 1));
                            setState(() {});
                          }
                        },
                        child: ListView.builder(
                          itemCount: snapshot.data!
                              .getVorlesungformDate(_selectedDate)
                              .length,
                          itemBuilder: (context, index) {
                            return veranstaltungsWidget(snapshot.data!
                                .getVorlesungformDate(_selectedDate)[index]);
                          },
                        ),
                      ))
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return RefreshIndicator(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Center(child: Text('${snapshot.error}'))),
                  ),
                  onRefresh: () => _pullRefresh(),
                );
              }
              return RefreshIndicator(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: const CircularProgressIndicator())),
                ),
                onRefresh: () => _pullRefresh(),
              );
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
