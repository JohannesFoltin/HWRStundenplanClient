// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';
import 'package:stundenplan/Struct/vorlesung.dart';

part 'plan.g.dart';

@JsonSerializable()
class Plan {
  List<Vorlesung> Vorlesungen;
  Plan(this.Vorlesungen);
  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);

  Map<String, dynamic> toJson() => _$PlanToJson(this);

  List<Vorlesung> getVorlesungformDate(DateTime d) {
    List<Vorlesung> ret = [];
    for (var i = 0; i < Vorlesungen.length; i++) {
      var tmp = DateTime.fromMillisecondsSinceEpoch(Vorlesungen[i].Startzeit);
      if (tmp.year == d.year && tmp.month == d.month && tmp.day == d.day) {
        ret.add(Vorlesungen[i]);
      }
    }
    return ret;
  }
}
