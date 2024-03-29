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
      children: _parseVorlesungen(),
    );
  }

  List<Widget> _parseVorlesungen() {
    if (vorlesungen.isEmpty) {
      List<Widget> tmp = [
        SizedBox(
            height: screenheight,
            child: const Center(child: Text("Hey du hast Frei! Cool oder?")))
      ];
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
    var h = v.endZeit().difference(v.startZeit()).inMinutes * ratio;
    retWidgets.add(_veranstaltungsWidget(v, h));

    for (var i = 0; i < vorlesungen.length - 1; i++) {
      DateTime ersteVorlesungEnde = vorlesungen[i].endZeit();
      DateTime zweiteVorlesungStart = vorlesungen[i + 1].startZeit();

      int minZwischenVorlesungen =
          zweiteVorlesungStart.difference(ersteVorlesungEnde).inMinutes;
      if (minZwischenVorlesungen > 0) {
        Container block = Container(
          height: minZwischenVorlesungen * ratio,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Card(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: const Text("Pause",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Text(
                    "$minZwischenVorlesungen min",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),
        );

        retWidgets.add(block);
      }
      double heightVonVeranstaltung = vorlesungen[i + 1]
              .endZeit()
              .difference(vorlesungen[i + 1].startZeit())
              .inMinutes *
          ratio;
      retWidgets.add(
          _veranstaltungsWidget(vorlesungen[i + 1], heightVonVeranstaltung));
    }

    DateTime letzteVorlesungEnde = vorlesungen.last.endZeit();
    int minBisAchtzehnUhr;

    if (letzteVorlesungEnde.hour <= 18) {
      DateTime achtzehnUhrTagesZeit = DateTime(letzteVorlesungEnde.year,
          letzteVorlesungEnde.month, letzteVorlesungEnde.day, 18, 0);

      minBisAchtzehnUhr =
          letzteVorlesungEnde.difference(achtzehnUhrTagesZeit).inMinutes;
    } else {
      minBisAchtzehnUhr = 0;
    }
    if (minBisAchtzehnUhr > 0) {
      SizedBox nachher = SizedBox(
        height: minBisAchtzehnUhr * ratio,
      );
      retWidgets.add(nachher);
    }
    return retWidgets;
  }

  bool isActivenow(DateTime start, DateTime end) {
    return DateTime.now().isAfter(start) && DateTime.now().isBefore(end);
  }

  Widget _veranstaltungsWidget(Vorlesung v, double h) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: h,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Card(
            color: isActivenow(v.startZeit(), v.endZeit())
                ? Colors.grey.shade200
                : Colors.white,
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Text(v.Beschreibung,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.Raum,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Von ${DateFormat("HH:mm").format(v.startZeit())} bis ${DateFormat("HH:mm").format(v.endZeit())}",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/*
  Text(
              "Zeit: ${DateFormat("HH:mm").format(v.startZeit())} - ${DateFormat("HH:mm").format(v.endZeit())}",
            ),
            const Divider(),
            Text(
              "Dauer: ${_minToHHMM(v.endZeit().difference(v.startZeit()).inMinutes)} \\ Raum: ${v.Raum}",
            ),
            const Divider(),
            Text(v.Beschreibung, textAlign: TextAlign.center),
            const SizedBox(
              height: 5,
            )
*/ 