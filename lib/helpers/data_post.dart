import 'dart:convert';
import 'package:http/http.dart';

class DataPost {
  final Map<dynamic,dynamic> body;

  DataPost(this.body);

  Future<dynamic> getData() async {
    Response response = await post(
        Uri.parse("http://157.245.254.251:8000/drstudent/api/predict"),
        headers: <String, String>{
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      //образец map для запроса
      /*body: jsonEncode(<String, String>{
        "type_prot": 2.toString(),
        "force": 15.toString(),
        "isq": 50.toString(),
        "type_fix": 2.toString(),
        "type_bone": 4.toString(),
        "class_resorb": "A",
        "angle": 2.toString()
      })*/
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else {
      //print("statusCode");
      print(response.statusCode);
      return jsonDecode(response.body);
    }
  }
}