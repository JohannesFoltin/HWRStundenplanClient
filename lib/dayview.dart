import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stundenplan/Struct/vorlesung.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DayView extends StatelessWidget {
  const DayView(
      {super.key, required this.vorlesungen, required this.screenheight});

  final List<Vorlesung> vorlesungen;
  final double screenheight;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _parseVorlesungen(),
    );
  }

  List<Widget> _parseVorlesungen() {
    if (vorlesungen.isEmpty) {
      List<Widget> tmp = [Container(height:screenheight,child: Center(child: Text("Keine Vorlesungen!")))];
      return tmp;
    }
    List<Widget> retWidgets = [];

    double ratio;
    ratio = screenheight / 600;

    DateTime ersteVorlesungStart = vorlesungen.first.startZeit();
    DateTime achtUhrTagesZeit = DateTime(ersteVorlesungStart.year,
        ersteVorlesungStart.month, ersteVorlesungStart.day, 8, 0);
    int minBisErsteVorlesung =
        ersteVorlesungStart.difference(achtUhrTagesZeit).inMinutes;
    if (minBisErsteVorlesung > 0) {
    var height2 = minBisErsteVorlesung * ratio;
    Container vorherBlock = Container(
      height: height2,
    );
    retWidgets.add(vorherBlock);
      
    }
    Vorlesung v = vorlesungen.first;
    var h = v.endZeit().difference(v.startZeit()).inMinutes*ratio;
    retWidgets.add(_veranstaltungsWidget(v,h));


    for (var i = 0; i < vorlesungen.length - 1; i++) {
      DateTime ersteVorlesungEnde = vorlesungen[i].endZeit();
      DateTime zweiteVorlesungStart = vorlesungen[i + 1].startZeit();

      int minZwischenVorlesungen =
          zweiteVorlesungStart.difference(ersteVorlesungEnde).inMinutes;
      if (minZwischenVorlesungen>0) {
      Container block = Container(
        height: minZwischenVorlesungen * ratio,
        child:  Center(child: Text(
          "Pause: ${_minToHHMM(minZwischenVorlesungen)}"
        )),
      );

      retWidgets.add(block);
        
      }
      double heightVonVeranstaltung = vorlesungen[i+1].endZeit().difference(vorlesungen[i+1].startZeit()).inMinutes*ratio;
      retWidgets.add(_veranstaltungsWidget(vorlesungen[i + 1],heightVonVeranstaltung));
    }

    DateTime letzteVorlesungEnde = vorlesungen.last.endZeit();
    int minBisAchtzehnUhr;

    if (letzteVorlesungEnde.hour <= 18) {
      DateTime achtzehnUhrTagesZeit = DateTime(letzteVorlesungEnde.year,
          letzteVorlesungEnde.month, letzteVorlesungEnde.day, 18, 0);

      minBisAchtzehnUhr =
          letzteVorlesungEnde.difference(achtzehnUhrTagesZeit).inMinutes;
    }else{
      minBisAchtzehnUhr = 0;
    }
    if (minBisAchtzehnUhr>0) {
      Container nachher = Container(
        height: minBisAchtzehnUhr * ratio,
      );
      retWidgets.add(nachher);
      
    }
    return retWidgets;
  }

  String _minToHHMM(int min){
    if (min <60) {
      return "${min}min";
    }else{
      var d = Duration(minutes:min);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }

  }

  Widget _veranstaltungsWidget(Vorlesung v,double h) {
    return Container(
      height: h,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Card(
        elevation: 10,
        child: SingleChildScrollView(
          child: Container(
            height: h+1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                    "Zeit: ${DateFormat("HH:mm").format(v.startZeit())} - ${DateFormat("HH:mm").format(v.endZeit())}"),
                const Divider(),
                Text("Dauer: ${_minToHHMM(v.endZeit().difference(v.startZeit()).inMinutes)}"),
                const Divider(),
                Text(v.Raum),
                const Divider(),
                Text(v.Beschreibung, textAlign: TextAlign.center),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
