import 'package:json_annotation/json_annotation.dart';

part 'vorlesung.g.dart';

@JsonSerializable()
class Vorlesung {
  int Startzeit;
  int Endzeit;
  String Raum;
  String Beschreibung;
  Vorlesung(this.Startzeit, this.Endzeit, this.Raum, this.Beschreibung);
  factory Vorlesung.fromJson(Map<String, dynamic> json) =>
      _$VorlesungFromJson(json);

  Map<String, dynamic> toJson() => _$VorlesungToJson(this);
  DateTime startZeit() {
    return DateTime.fromMillisecondsSinceEpoch(Startzeit);
  }
   DateTime endZeit() {
    return DateTime.fromMillisecondsSinceEpoch(Endzeit);
  }
}
