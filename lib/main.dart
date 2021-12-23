/*// @dart=2.9*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dentapp/result.dart';
import 'package:dentapp/helpers/data.dart';
import 'package:dentapp/helpers/app_properties_bloc.dart';

//массивы терминов для выпадающих списков на русском
var typeProtListRu = <String>[];
var typeFixListRu = <String>[];
var typeBoneListRu = <String>[];
var classResorpListRu = <String>[];
var angleListRu = <String>[];

//массивы терминов для выпадающих списков на английском
var typeProtListEng = <String>[];
var typeFixListEng = <String>[];
var typeBoneListEng = <String>[];
var classResorpListEng = <String>[];
var angleListEng = <String>[];

//данные, полученные от API
DataFetch _dataFetch = DataFetch();

//массив параметров формы с выпадающими списками
var parameters = [
  "type_prot",
  "type_fix",
  "type_bone",
  "class_resorp",
  "angle"
];

//получение данных от API по определённому параметру name из массива parameters
_getData(name) async {
  //try {
  var dataDecoded = await _dataFetch.getData(name);
  updateData(dataDecoded, name);
  //} catch (e) {
  //  debugPrint(e.toString());
  //}
}

//заполнение массивов терминов данными из API для определённого параметра name
void updateData(data, name) {
  if (data != null) {
    debugPrint(jsonEncode(data));

    int length = data["values"].length;

    //для каждого параметра name заполняется соответствующая пара массивов
    //с русскими и английскими терминами;
    //для правильного отображения кириллицы дополнительно применяется декодирование
    for (int i = 0; i < length; i++) {
      if (name == parameters[0]) {
        //"type_prot"
        typeProtListRu.add(utf8.decode(data["values"][i]["ru"].runes.toList()));
        typeProtListEng.add(data["values"][i]["eng"].toString());
      } else if (name == parameters[1]) {
        //"type_fix"
        typeFixListRu.add(utf8.decode(data["values"][i]["ru"].runes.toList()));
        typeFixListEng.add(data["values"][i]["eng"].toString());
      } else if (name == parameters[2]) {
        //"type_bone"
        typeBoneListRu.add(utf8.decode(data["values"][i]["ru"].runes.toList()));
        typeBoneListEng.add(data["values"][i]["eng"].toString());
      } else if (name == parameters[3]) {
        //"class_resorp"
        classResorpListRu
            .add(utf8.decode(data["values"][i]["ru"].runes.toList()));
        classResorpListEng.add(data["values"][i]["eng"].toString());
      } else if (name == parameters[4]) {
        //"angle"
        angleListRu.add(utf8.decode(data["values"][i]["ru"].runes.toList()));
        angleListEng.add(data["values"][i]["eng"].toString());
      }
    }
  }
}

//получение данных и заполнение ими массивов терминов для всех параметров parameters
Future _getParameters() async {
  for (var p in parameters) {
    await _getData(p);
  }
}

String defaultLocale = Platform.localeName;
bool ruLocale = true;

String titleApp = "";//ruLocale == true ? "Стоматология" : "Stomatology";
String titleButton = "";//ruLocale == true ? "Рассчитать" : "Calculate";

changeLocaleTitle() {
  appBloc.updateTitle(ruLocale == true ? "Стоматология" : "Stomatology");
  appBloc.updateTitleButton(ruLocale == true ? "Рассчитать" : "Calculate");
}

//удалось ли получить данные с сервера
bool connection = true;

void main() async {

  try {
    //получение данных для выпадающих списков (до построения формы)
    await _getParameters();
  } catch (e) {
    //данные получить не удалось
    connection = false;
    debugPrint(e.toString());
  }

  if (defaultLocale == "ru_RU")
    ruLocale = true;
  else
    ruLocale = false;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: Scaffold(
      // поменялся цвет фона, шрифт, добавлена картинка
      appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: Image.asset("assets/icons/icons8.webp"),
          title:StreamBuilder<Object>(
            stream: appBloc.titleStream,
            initialData: ruLocale == true ? "Стоматология" : "Stomatology",
            builder: (context, snapshot) {
              return Text(snapshot.data.toString(),
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.black87));
            }
          ),
        centerTitle: true,
      ),
      //если данные для построения формы не были получены, показывается пустой экран
      //а если были - строится форма MyForm()
      body: connection == false ? Container() : MyForm(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // поменялся цвет фона, шрифт
      //если данные для построения формы не были получены
      //кнопка "Рассчитать" не показывается
      floatingActionButton: connection == false
          ? Container()
          : ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.amber)),
              child: StreamBuilder<Object>(
                stream: appBloc.titleButtonStream,
                initialData: ruLocale == true ? "Рассчитать" : "Calculate",
                builder: (context, snapshot) {
                  return Text(snapshot.data.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87));
                },
              ),
              onPressed: () {
              },
            ),
    ),
  );
}}

class MyForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyFormState();
}

class MyFormState extends State {
  final _formKey = GlobalKey<FormState>();

  void _getForceParameter(int isq) async {
  //значения для тестирования
  //  forceMin = 100 - isq;
  //  forceMax = 100 + isq;
  //  force = forceMin;
    try {
      var dataDecoded = await _dataFetch.getData("isq");
      if (dataDecoded != null) debugPrint(jsonEncode(dataDecoded));
      else debugPrint("dataDecoded is null!");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //минимальное и максимальное значения для слайдеров с параметрами isq и force
  int isqMin = 50;
  int isqMax = 100;
  int forceMin = 15;
  int forceMax = 100;

  String typeProt = (ruLocale == true ? typeProtListRu : typeProtListEng)[0]; //Тип протезирования / Prosthetics type
  int isq =
      50; //Коэффициент стабильности имплантанта (ISQ) / Implant Stability Quotient(ISQ)
  int force = 15; //Динамометрическое усилие, н/см2 / Torque force, N/cm2
  String typeFix = (ruLocale == true ? typeFixListRu : typeFixListEng)[0]; // Тип фиксации / Fixation type
  String typeBone = (ruLocale == true ? typeBoneListRu : typeBoneListEng)[0]; // Тип кости / Bone type
  String classResorp =
    (ruLocale == true ? classResorpListRu : classResorpListEng)[0]; //Класс резорбции / Resorption class
  String angle = (ruLocale == true ? angleListRu : angleListEng)[0]; //Угол вкручивания / Screw angle

  void changeLocaleParameters() {
    typeProt = (ruLocale == true ? typeProtListRu : typeProtListEng)[0];
    typeFix = (ruLocale == true ? typeFixListRu : typeFixListEng)[0];
    typeBone = (ruLocale == true ? typeBoneListRu : typeBoneListEng)[0];
    classResorp = (ruLocale == true ? classResorpListRu : classResorpListEng)[0];
    angle = (ruLocale == true ? angleListRu : angleListEng)[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left : 10.0, right : 10.0, top : 10.0, bottom: 50.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              //прокрутка колонки
              child: Column(children: [
              Row(
                children: [
                  Text("eng"),
                  SizedBox(width: 5),
                  SizedBox(width: 20,
                    child:
                      SwitchListTile(
                      value: ruLocale,
                      onChanged: (bool value) {
                      setState(() {
                        ruLocale = value;
                        changeLocaleParameters();
                        changeLocaleTitle();
                      });
                    },
                    activeColor: Colors.grey,
                  )),
                  SizedBox(width: 20),
                  Text("ru"),
              ]),
              Text(ruLocale == true ? "Тип протезирования" : "Prosthetics type",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                      )),
              DropdownButton<String>(
                value: typeProt,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan),
                // поменялся цвет фона, шрифт
                underline: Container(
                  height: 2,
                  color: Colors.cyan,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    typeProt = newValue!;
                  });
                },
                items: (ruLocale == true ? typeProtListRu : typeProtListEng).map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(1),
                ),
              Text(ruLocale == true ? "Коэффициент стабильности имплантанта (ISQ)" : "Implant Stability Quotient (ISQ)",
                textAlign: TextAlign.center,
                style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          // поменялся шрифт
              )),
              Text("$isq",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan),
              ),
              Row(
                children: [
                  Text("$isqMin",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent),
                  ),
                  Expanded(
                    child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.amber,
                      inactiveTrackColor: Colors.amberAccent,
                      thumbColor: Colors.amber,
                      // добавилась SliderTheme, чтобы поменялся цвет
                    ),
                    child: Slider(
                      value: isq.toDouble(),
                      min: isqMin.toDouble(),
                      max: isqMax.toDouble(),
                      divisions: 100,
                      label: isq.round().toString(),
                      //изменять isq пока пользователь двигает слайдер
                      onChanged: (value) {
                        setState(() => isq = value.toInt());
                      },
                      //изменять зависимый параметр force только когда
                      //пользователь прекратил двигать слайдер
                      onChangeEnd: (value) {
                        setState(() {
                          isq = value.toInt();
                          _getForceParameter(isq);
                        });
                      },
                    ),
                  )),
                  Text("$isqMax",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent),
                  ),
                ],
              ),
              Text(ruLocale == true ? "Динамометрическое усилие, н/см2" : "Torque force, N / cm2",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                    fontWeight: FontWeight.bold)),
              Text("$force",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan),
              ),
              Row(
                children: [
                  Text("$forceMin",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent),
                   ),
                  Expanded(child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.amber,
                      inactiveTrackColor: Colors.amberAccent,
                      thumbColor: Colors.amber,
                      ),
                    child: Slider(
                      value: force.toDouble(),
                      min: forceMin.toDouble(),
                      max: forceMax.toDouble(),
                      divisions: forceMax - forceMin,
                      label: force.round().toString(),
                      onChanged: (value) {
                        //setState(() => force = value.toInt());
                      }
                    ),
                  ),),
                  Text("$forceMax",
                    style: TextStyle(
                        fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent),
                  ),],
              ),
                Padding(
                  padding: EdgeInsets.all(1),
                ),
              Text(ruLocale == true ? "Тип фиксации" : "Fixation type",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: typeFix,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan),
                // поменялся цвет фона, шрифт
                underline: Container(
                  height: 2,
                  color: Colors.cyan,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    typeFix = newValue!;
                  });
                },
                items: (ruLocale == true ? typeFixListRu : typeFixListEng).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(1),
                ),
              Text(ruLocale == true ? "Тип кости" : "Bone type",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: typeBone,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan),
                // поменялся цвет фона, шрифт
                underline: Container(
                  height: 2,
                  color: Colors.cyan,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    typeBone = newValue!;
                  });
                },
                items: (ruLocale == true ? typeBoneListRu : typeBoneListEng).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(1),
                ),
              Text(ruLocale == true ? "Класс резорбции" : "Resorption class",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: classResorp,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan),
                // поменялся цвет фона, шрифт
                underline: Container(
                  height: 2,
                  color: Colors.cyan,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    classResorp = newValue!;
                  });
                },
                items: (ruLocale == true ? classResorpListRu : classResorpListEng).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(1),
                ),
              Text(ruLocale == true ? "Угол вкручивания" : "Screw angle",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: angle,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan),
                // поменялся цвет фона, шрифт
                underline: Container(
                  height: 2,
                  color: Colors.cyan,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    angle = newValue!;
                  });
                },
                items: (ruLocale == true ? angleListRu : angleListEng).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                SizedBox(height: 10),

            ]))));
  }
}
