import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stundenplan/Struct/vorlesung.dart';

class DayView extends StatelessWidget {
  const DayView(
      {super.key, required this.vorlesungen, required this.screenheight});

  final List<Vorlesung> vorlesungen;
  final double screenheight;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: parseVorlesungen(),
    );
  }

  List<Widget> parseVorlesungen() {
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
    retWidgets.add(veranstaltungsWidget(v,h));


    for (var i = 0; i < vorlesungen.length - 1; i++) {
      DateTime ersteVorlesungEnde = vorlesungen[i].endZeit();
      DateTime zweiteVorlesungStart = vorlesungen[i + 1].startZeit();

      int minZwischenVorlesungen =
          zweiteVorlesungStart.difference(ersteVorlesungEnde).inMinutes;
      if (minZwischenVorlesungen>0) {
      Container block = Container(
        height: minZwischenVorlesungen * ratio,
        child: const Center(child: Text("Pause:")),
      );

      retWidgets.add(block);
        
      }
      double heightVonVeranstaltung = vorlesungen[i+1].endZeit().difference(vorlesungen[i+1].startZeit()).inMinutes*ratio;
      retWidgets.add(veranstaltungsWidget(vorlesungen[i + 1],heightVonVeranstaltung));
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

  Widget veranstaltungsWidget(Vorlesung v,double h) {
    return Container(
      height: h,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Card(
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
                "Zeit: ${DateFormat("HH:mm").format(v.startZeit())} - ${DateFormat("HH:mm").format(v.endZeit())}"),
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
    );
  }

}
