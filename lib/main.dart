/*// @dart=2.9*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dentapp/helpers/data.dart';
import 'package:dentapp/helpers/data_post.dart';
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

//map, в которую собираются все выбранные пользователем параметры с формы
var resultMap = Map<String, dynamic>();

//результат запроса post на сервер со всеми параметрами формы
//число - Срок ортопедической нагрузки (в сутках)
String result = "";

//статус результата запроса post с сервера, error или ok
String resultStatus = "";

//сообщение с сервера после post, пришедшее вместе с результатом
//с описанием некорректности присланных данных
//или "Срок ортопедической нагрузки" если данные корректны
String resultMessage = "";

//экземпляр класса для взяимодействия с API get запросом
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

//получение данных от API в ответ на запрос со всеми параметрами формы,
//записанными в resultMap
_getDataPost(resultMap) async {
  //debugPrint("_getDataPost 1)");
  //экземпляр класса для взяимодействия с API post запросом
  DataPost _dataPost = DataPost(resultMap);
  //debugPrint("_getDataPost 2)");
  try {
    //данные, полученные от API в ответ на post запрос
    var dataDecoded = await _dataPost.getData();
    if (dataDecoded != null) {
      //debugPrint(jsonEncode(dataDecoded));
      //разбор присланных данных
      resultStatus = dataDecoded["status"].toString();
      result = dataDecoded["result"].toString();
      //resultMessage присылается на русском, поэтому нужно декодирование
      resultMessage = utf8.decode(dataDecoded["message"].runes.toList());

      //debugPrint(resultStatus);
      //debugPrint(result);
      //debugPrint(resultMessage);
    } //else
      //если данные == null , не делать ничего
      //debugPrint("dataDecoded from post is null!");
  } catch (e) {
    //если запрос был неудачный, не делать ничего
    debugPrint(e.toString());
  }
}

//заполнение массивов терминов данными из API для определённого параметра name
void updateData(data, name) {
  if (data != null) {
    //debugPrint(jsonEncode(data));

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

//получение языка системы
String defaultLocale = Platform.localeName;
//переменная для хранения языка приложения
bool ruLocale = true;

//изменение title у AppBar приложения
changeLocaleTitle() {
  appBloc.updateTitle(ruLocale == true ? "Стоматология" : "Stomatology");
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

  //какой язык будет в приложении после запуска:
  //русский, если язык системы русский, и английский в остальных случаях
  if (defaultLocale == "ru_RU")
    ruLocale = true;
  else
    ruLocale = false;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // поменялся цвет фона, шрифт, добавлена картинка
        appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: Image.asset("assets/icons/icons8.webp"),
          title: StreamBuilder<Object>(
              stream: appBloc.titleStream,
              initialData: ruLocale == true ? "Стоматология" : "Stomatology",
              //необходимо для изменения title при изменении языка приложения
              //по нажатию на switch, находящемуся в MyForm
              builder: (context, snapshot) {
                return Text(snapshot.data.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87));
              }),
          centerTitle: true,
        ),
        //если данные для построения формы не были получены, показывается пустой экран
        //а если были - строится форма MyForm()
        body: connection == false ? Container() : MyForm(),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyFormState();
}

class MyFormState extends State {
  final _formKey = GlobalKey<FormState>();

  //для автоматического прокручивания страницы к результату расчета
  //посленажатия кнопки Рассчитать
  ScrollController _scrollController = ScrollController();

  //изменение прараметра force при изменении параметра isq
  void _getForceParameter(int isq) async {
    //====значения для тестирования====
    forceMin = 100 - isq;
    if (forceMin < 15) forceMin = 15;
    forceMax = 100;
    force = forceMin;
    if (isq == 50) {
      forceMin = 15;
      force = 15;
    }
    //==================================

    //обращение к серверу за значениями параметра
    /*  try {
      var dataDecoded = await _dataFetch.getData("isq");
      if (dataDecoded != null) debugPrint(jsonEncode(dataDecoded));
      else debugPrint("dataDecoded is null!");
    } catch (e) {
      debugPrint(e.toString());
    }*/
  }

  //минимальное и максимальное значения для слайдеров с параметрами isq и force
  //цифры взяты из http://157.245.254.251:8000/docs#/ Schemas ModelInputParams
  int isqMin = 50;
  int isqMax = 100;
  int forceMin = 15;
  int forceMax = 100;

  //начальные значения параметров формы - первые элементы соответствующих массивов
  //массив с русскими или англ терминами выбирается в зависимости от
  //текущего языка приложения
  String typeProt = (ruLocale == true
      ? typeProtListRu
      : typeProtListEng)[0]; //Тип протезирования / Prosthetics type
  //начальные значения isq & force - минимальные возможные значения
  int isq =
      50; //Коэффициент стабильности имплантанта (ISQ) / Implant Stability Quotient(ISQ)
  int force = 15; //Динамометрическое усилие, н/см2 / Torque force, N/cm2
  String typeFix = (ruLocale == true
      ? typeFixListRu
      : typeFixListEng)[0]; // Тип фиксации / Fixation type
  String typeBone = (ruLocale == true
      ? typeBoneListRu
      : typeBoneListEng)[0]; // Тип кости / Bone type
  String classResorp = (ruLocale == true
      ? classResorpListRu
      : classResorpListEng)[0]; //Класс резорбции / Resorption class
  String angle = (ruLocale == true
      ? angleListRu
      : angleListEng)[0]; //Угол вкручивания / Screw angle

  //строки для вывода результата запроса post на сервер со всеми
  //выбранными параметрами
  String resultTxt = "";
  String resultMsgTxt = "";

  //начальные значения параметров формы - первые элементы соответствующих массивов
  //меняются при смене языка приложения
  void changeLocaleParameters() {
    typeProt = (ruLocale == true ? typeProtListRu : typeProtListEng)[0];
    typeFix = (ruLocale == true ? typeFixListRu : typeFixListEng)[0];
    typeBone = (ruLocale == true ? typeBoneListRu : typeBoneListEng)[0];
    classResorp =
        (ruLocale == true ? classResorpListRu : classResorpListEng)[0];
    angle = (ruLocale == true ? angleListRu : angleListEng)[0];
  }

  @override
  void initState() {
    //при первом открытии формы все параметры формы выставлены
    //первым элементом соответствующего массива
    //а для параметров isq&force выставлены минимальные значения
    resultMap = {
      "type_prot": 1.toString(),
      "force": 15.toString(),
      "isq": 50.toString(),
      "type_fix": 1.toString(),
      "type_bone": 1.toString(),
      "class_resorb": "A",
      "angle": 1.toString()
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 10,
              ),
            ],
          ),
          //снизу, под Container находится кнопка Рассчитать и переключение языка
          height: MediaQuery.of(context).size.height - 130,
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          //, bottom: 50.0),
          child: Form(
              key: _formKey,
              //прокрутка колонки
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(children: [
                Text(
                    ruLocale == true
                        ? "Тип протезирования"
                        : "Prosthetics type",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
                      //запись в map выбранного значения для отправки на сервер:
                      //отправляется id элемента, т.е. его порядковый номер
                      resultMap[parameters[0]] = 1 +
                          (ruLocale == true ? typeProtListRu : typeProtListEng)
                              .indexOf(typeProt);
                    });
                  },
                  items: (ruLocale == true ? typeProtListRu : typeProtListEng)
                      .map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Text(
                    ruLocale == true
                        ? "Коэффициент стабильности имплантанта (ISQ)"
                        : "Implant Stability Quotient (ISQ)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      // поменялся шрифт
                    )),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                //вывод на форму выбранного значения
                Text(
                  "$isq",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan),
                ),
                Row(
                  children: [
                    Text(
                      "$isqMin",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent),
                    ),
                    Expanded(
                        child: SliderTheme(
                      data: SliderThemeData(
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
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
                            //запись в map выбранного значения для отправки на сервер:
                            //отправляется значение
                            resultMap["isq"] = isq;
                            resultMap["force"] = force;
                          });
                        },
                      ),
                    )),
                    Text(
                      "$isqMax",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Text(
                    ruLocale == true
                        ? "Динамометрическое усилие, н/см2"
                        : "Torque force, N / cm2",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                //вывод на форму значения параметра
                Text(
                  "$force",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan),
                ),
                Row(
                  children: [
                    Text(
                      "$forceMin",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
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
                            //значение этого параметра отправляются на сервер
                            //при измении параметра isq, в предыдущем слайдере
                            onChanged: (value) {
                              //setState(() => force = value.toInt());
                            }),
                      ),
                    ),
                    Text(
                      "$forceMax",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Text(ruLocale == true ? "Тип фиксации" : "Fixation type",
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
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
                      //запись в map выбранного значения для отправки на сервер:
                      //отправляется id элемента, т.е. его порядковый номер
                      //"type_fix"
                      resultMap[parameters[1]] = 1 +
                          (ruLocale == true ? typeFixListRu : typeFixListEng)
                              .indexOf(typeFix);
                    });
                  },
                  items: (ruLocale == true ? typeFixListRu : typeFixListEng)
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Text(ruLocale == true ? "Тип кости" : "Bone type",
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
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
                      //запись в map выбранного значения для отправки на сервер:
                      //отправляется id элемента, т.е. его порядковый номер
                      //"type_bone"
                      resultMap[parameters[2]] = 1 +
                          (ruLocale == true ? typeBoneListRu : typeBoneListEng)
                              .indexOf(typeBone);
                    });
                  },
                  items: (ruLocale == true ? typeBoneListRu : typeBoneListEng)
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Text(ruLocale == true ? "Класс резорбции" : "Resorption class",
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
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
                      //запись в map выбранного значения для отправки на сервер:
                      //отправляется значение элемента
                      //"class_resorb" - отличается от parameters[3], не опечатка
                      //такой ключ у map ожидает сервер
                      resultMap["class_resorb"] = classResorp;
                    });
                  },
                  items: (ruLocale == true
                          ? classResorpListRu
                          : classResorpListEng)
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: EdgeInsets.all(3),
                ),
                Text(ruLocale == true ? "Угол вкручивания" : "Screw angle",
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
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
                      //запись в map выбранного значения для отправки на сервер:
                      //отправляется id элемента, т.е. его порядковый номер
                      //"angle"
                      resultMap[parameters[4]] = 1 +
                          (ruLocale == true ? angleListRu : angleListEng)
                              .indexOf(angle);
                    });
                  },
                  items: (ruLocale == true ? angleListRu : angleListEng)
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 5),
                //вывод результата запроса на сервер со всеми выбранными параметрами
                _showResult()
              ]))),
        ),
        Expanded(
          child: Row(
            children: [
              //кнопка Рассчитать
              _buttonCalculate(),
              //switch для переключения языка приложения
              _langSwitch()
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
        )
      ],
    );
  }

  Widget _showResult() {
    return Container(
      child: Column(children: [
        Container(
          height: 38.0,
          width: 300.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 2.0)
          ),
          child: Column(
            children :[
              Text(
                ruLocale == true
                  ? "Срок ортопедической нагрузки (в сутках)"
                  : "Duration of orthopedic load (days)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
              Text("$resultTxt",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold))
            ])
        ),
        SizedBox(height: 2),
        resultStatus == "error" ?
            Container(
                height: 38.0,
                width: 300.0,

                /*decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.deepOrangeAccent,
                    width: 2.0)
                ),*/
                child: Text("$resultMsgTxt", style: TextStyle(fontSize: 14)))
            : Container()
      ],)
    );
  }

  Widget _buttonCalculate() {
    return ElevatedButton(
      onPressed: (() {
        //debugPrint("onPressed");
        //debugPrint(resultMap.toString());
        _getDataPost(resultMap).then((_) {
          setState(() {
            resultTxt = result;
            resultMsgTxt = resultMessage;
          });
          //автоматическое прокручивание формы до конца, к результату
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.ease);
        });
      }),
      child: Text(ruLocale == true ? "Рассчитать" : "Calculate",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87)),
      style: ElevatedButton.styleFrom(
          primary: Colors.amber, fixedSize: Size(120.0, 28.0)
      ),
    );
  }

  Widget _langSwitch() {
    return Row(children: [
      Text("eng"),
      SizedBox(width: 5),
      SizedBox(
          width: 20,
          child: SwitchListTile(
            value: ruLocale,
            onChanged: (bool value) {
              setState(() {
                ruLocale = value;
                //смена значений параметров на первые элементы соответствующих массивов
                changeLocaleParameters();
                //смена title у appbar
                changeLocaleTitle();
              });
            },
            activeColor: Colors.grey,
          )),
      SizedBox(width: 20),
      Text("ru"),
    ]);
  }
}
