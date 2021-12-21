/*// @dart=2.9*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dentapp/result.dart';
import 'package:dentapp/helpers/data.dart';

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

void main() async {
  //удалось ли получить данные с сервера
  bool _connection = true;
  try {
    //получение данных для выпадающих списков (до построения формы)
    await _getParameters();
  } catch (e) {
    //данные получить не удалось
    _connection = false;
    debugPrint(e.toString());
  }

  runApp(MaterialApp(
    home: Scaffold(
      // поменялся цвет фона, шрифт, добавлена картинка
      appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: Image.asset("assets/icons/icons8.webp"),
          title: const Text("Стоматология",
              style: TextStyle(
                  fontFamily: 'RocknRollOne-Regular', color: Colors.black87)),
          centerTitle: true),
      //если данные для построения формы не были получены, показывается пустой экран
      //а если были - строится форма MyForm()
      body: _connection == false ? Container() : MyForm(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // поменялся цвет фона, шрифт
      //если данные для построения формы не были получены
      //кнопка "Рассчитать" не показывается
      floatingActionButton: _connection == false
          ? Container()
          : ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.amber)),
              child: const Text("Рассчитать",
                  style: TextStyle(
                      fontFamily: 'RocknRollOne-Regular',
                      color: Colors.black87)),
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
      /*bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),*/
    ),
  ));
}

class MyForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyFormState();
}

class MyFormState extends State {
  final _formKey = GlobalKey<FormState>();

  void _getForceParameter(int isq) {
  //значения для тестирования
  //  forceMin = 100 - isq;
  //  forceMax = 100 + isq;
  //  force = forceMin;
  }

  String typeProt = typeProtListRu[0]; //Тип протезирования / Prosthetics type
  int isq =
      65; //Коэффициент стабильности имплантанта (ISQ) / Implant Stability Quotient(ISQ)
  int force = 25; //Динамометрическое усилие, н/см2 / Torque force, N/cm2
  String typeFix = typeFixListRu[0]; // Тип фиксации / Fixation type
  String typeBone = typeBoneListRu[0]; // Тип кости / Bone type
  String classResorp =
      classResorpListRu[0]; //Класс резорбции / Resorption class
  String angle = angleListRu[0]; //Угол вкручивания / Screw angle

  //минимальное и максимальное значения для слайдеров с параметрами isq и force
  int isqMin = 0;
  int isqMax = 100;
  int forceMin = 0;
  int forceMax = 100;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              //прокрутка колонки
              child: Column(children: [
              const Text("Тип протезирования",
                  style:
                      TextStyle(fontSize: 12, fontFamily: 'RocknRollOne-Regular'
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: typeProt,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'RocknRollOne-Regular',
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
                items: typeProtListRu.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
              const Text("Коэффициент стабильности имплантанта (ISQ)",
                textAlign: TextAlign.center,
                style:
                  TextStyle(fontSize: 12, fontFamily: 'RocknRollOne-Regular'
                          // поменялся шрифт
              )),
              Text("$isq",
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'RocknRollOne-Regular',
                  color: Colors.cyan),
              ),
              Row(
                children: [
                  Text("$isqMin",
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'RocknRollOne-Regular',
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
                      fontSize: 11,
                      fontFamily: 'RocknRollOne-Regular',
                      color: Colors.amberAccent),
                  ),
                ],
              ),
              const Text("Динамометрическое усилие, н/см2",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                    fontFamily: 'RocknRollOne-Regular')),
              Text("$force",
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'RocknRollOne-Regular',
                  color: Colors.cyan),
              ),
              Row(
                children: [
                  Text("$forceMin",
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'RocknRollOne-Regular',
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
                      fontSize: 11,
                      fontFamily: 'RocknRollOne-Regular',
                      color: Colors.amberAccent),
                  ),],
              ),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
              const Text("Тип фиксации",
                  style:
                      TextStyle(fontSize: 12, fontFamily: 'RocknRollOne-Regular'
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: typeFix,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'RocknRollOne-Regular',
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
                items: typeFixListRu.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
              const Text("Тип кости",
                  style:
                      TextStyle(fontSize: 12, fontFamily: 'RocknRollOne-Regular'
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: typeBone,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'RocknRollOne-Regular',
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
                items: typeBoneListRu.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
              const Text("Класс резорбции",
                  style:
                      TextStyle(fontSize: 12, fontFamily: 'RocknRollOne-Regular'
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: classResorp,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'RocknRollOne-Regular',
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
                items: classResorpListRu.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
              const Text("Угол вкручивания",
                  style:
                      TextStyle(fontSize: 12, fontFamily: 'RocknRollOne-Regular'
                          // поменялся шрифт
                          )),
              DropdownButton<String>(
                value: angle,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'RocknRollOne-Regular',
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
