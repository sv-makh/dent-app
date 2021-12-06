/*// @dart=2.9*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dentapp/result.dart';
import 'package:dentapp/helpers/data.dart';

var typeProtListRu = <String>[];
var typeFixListRu = <String>[];
var typeBoneListRu = <String>[];
var classResorpListRu = <String>[];
var angleListRu = <String>[];

var typeProtListEng = <String>[];
var typeFixListEng = <String>[];
var typeBoneListEng = <String>[];
var classResorpListEng = <String>[];
var angleListEng = <String>[];

DataFetch _dataFetch = DataFetch();

var parameters = [
  "type_prot",
  "type_fix",
  "type_bone",
  "class_resorp",
  "angle"
];

_getData(name) async {
  try {
    var dataDecoded = await _dataFetch.getData(name);
    updateData(dataDecoded, name);
  } catch (e) {
    debugPrint(e.toString());
  }
}

void updateData(data, name) {
  if (data != null) {
    debugPrint(jsonEncode(data));

    switch (name) {
      case "type_prot":
        {
          for (int i = 0; i < 2; i++) {
            typeProtListRu.add(data["values"][i]["ru"].toString());
            typeProtListEng.add(data["values"][i]["eng"].toString());
          }
        }
        break;

      case "type_fix":
        {
          for (int i = 0; i < 2; i++) {
            typeFixListRu.add(data["values"][i]["ru"].toString());
            typeFixListEng.add(data["values"][i]["eng"].toString());
          }
        }
        break;

      case "type_bone":
        {
          for (int i = 0; i < 4; i++) {
            typeBoneListRu.add(data["values"][i]["ru"].toString());
            typeBoneListEng.add(data["values"][i]["eng"].toString());
          }
        }
        break;

      case "class_resorp":
        {
          for (int i = 0; i < 4; i++) {
            classResorpListRu.add(data["values"][i]["ru"].toString());
            classResorpListEng.add(data["values"][i]["eng"].toString());
          }
        }
        break;

      case "angle":
        {
          for (int i = 0; i < 2; i++) {
            angleListRu.add(data["values"][i]["ru"].toString());
            angleListEng.add(data["values"][i]["eng"].toString());
          }
        }
        break;
    }
  }
}

Future _getParameters() async {
  for (var p in parameters) {
    await _getData(p);
  }
}

void main() async {
  await _getParameters();

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text("Стоматология 🦷"), centerTitle: true),
      body: MyForm(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton(
        child: const Text("Рассчитать"),
        onPressed: () {
          String message = "Данные успешно сохранены";
          Color messageColor = Colors.green;

          /*if (!_formKey.currentState!.validate() ||
                      !_feedDry && !_feedWet && !_feedNatural) {
                    message = "Данные неполны";
                    messageColor = Colors.red;

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 3),
                      backgroundColor: messageColor,
                      action: SnackBarAction(
                        label: "Ok",
                        textColor: Colors.black,
                        onPressed: () {},
                      ),
                    ));
                  } else */
          {
            /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultingRoute()),
              );*/
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    ),
  ));
}

class MyForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyFormState();
}

class MyFormState extends State {
  final _formKey = GlobalKey<FormState>();

  String typeProt = typeProtListRu[0]; //Тип протезирования / Prosthetics type
  int isq =
  65; //Коэффициент стабильности имплантанта (ISQ) / Implant Stability Quotient(ISQ)
  int force = 25; //Динамометрическое усилие, н/см2 / Torque force, N/cm2
  String typeFix = typeFixListRu[0]; // Тип фиксации / Fixation type
  String typeBone = typeBoneListRu[0]; // Тип кости / Bone type
  String classResorp = classResorpListRu[0]; //Класс резорбции / Resorption class
  String angle = angleListRu[0]; //Угол вкручивания / Screw angle

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              //прокрутка колонки
                child: Column(children: [
                  const Text("Тип протезирования"),
                  DropdownButton<String>(
                    value: typeProt,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        typeProt = newValue!;
                      });
                    },
                    items: typeProtListRu.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const Text("Коэффициент стабильности имплантанта (ISQ)"),
                  Slider(
                    value: isq.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 5,
                    label: isq.round().toString(),
                    onChanged: (double value) {
                      // setState(() {
                      //   _currentSliderValue = value;
                      // });
                    },
                  ),
                  const Text("Динамометрическое усилие, н/см2"),
                  Slider(
                    value: force.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 5,
                    label: force.round().toString(),
                    onChanged: (double value) {
                      // setState(() {
                      //   _currentSliderValue = value;
                      // });
                    },
                  ),
                  const Text("Тип фиксации"),
                  DropdownButton<String>(
                    value: typeFix,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        typeFix = newValue!;
                      });
                    },
                    items: typeFixListRu.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const Text("Тип кости"),
                  DropdownButton<String>(
                    value: typeBone,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        typeBone = newValue!;
                      });
                    },
                    items: typeBoneListRu.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const Text("Класс резорбции"),
                  DropdownButton<String>(
                    value: classResorp,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        classResorp = newValue!;
                      });
                    },
                    items: classResorpListRu.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const Text("Угол вкручивания"),
                  DropdownButton<String>(
                    value: angle,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        angle = newValue!;
                      });
                    },
                    items: angleListRu.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ]))));
  }
}
