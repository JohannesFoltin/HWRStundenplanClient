// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundenplan/Struct/plan.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stundenplan/dayview.dart';

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
    futurePlan = _loadPlanFromLocal();
  }

  void _showSnackBar(String text) {
    var snackBar = SnackBar(
        duration: Duration(seconds: 1),
        content: Row(
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
      return Future<Plan>.error(
          "Keine Daten lokal vorhanden. Versuche eine Verbindung zum Server herzustellen und dann zu aktualisieren");
    }
  }

  Future<Plan> _loadPlanFormOnline() async {
    http.Response response;
    try {
      response = await http.get(Uri.parse('http://192.168.178.33:4545/plan'));
    } catch (_) {
      _showSnackBar("Server nicht erreicht. Lade offline");
      return Future<Plan>.error("Server nicht erreicht");
    }
    if (response.statusCode == 200) {
      _showSnackBar("Online");
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(key, response.body);
      return Plan.fromJson(jsonDecode(response.body));
    } else {
      return Future<Plan>.error("Server antwortet komisch");
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
      futurePlan = _loadPlanFormOnline()
          .onError((error, stackTrace) => _loadPlanFromLocal());
    });
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('de');
    var appBaar = AppBar(
      backgroundColor: Colors.grey.shade100,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            setState(() {
              _selectedDate = DateTime.now();
            });
          },
          icon: Icon(
            Icons.today,
            color: Colors.black,
          )),
      title: TextButton(
        child: Text(
          "${DateFormat.EEEE("de").format(_selectedDate)} ${DateFormat("dd.MM.yyyy").format(_selectedDate)}",
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        onPressed: () => _selectDate(context),
      ),
    );

    double heightBar = appBaar.preferredSize.height;
    final double height = MediaQuery.of(context).size.height -
        heightBar -
        MediaQuery.of(context).padding.top;

    return Scaffold(
        appBar: appBaar,
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
                        child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                DayView(
                                        vorlesungen: snapshot.data!
                                            .getVorlesungformDate(
                                                _selectedDate),
                                        screenheight: height)
                                    .build(context),
                              ],
                            )),
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
}
