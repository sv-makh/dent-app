import 'dart:convert';
import 'package:http/http.dart';


class PostHelper {
  final Map<dynamic,dynamic> body;

  PostHelper(this.body);

  Future<dynamic> getData() async {
    Response response = await post(
      Uri.parse("http://157.245.254.251:8000/docs#/"),
      body: body
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else {
      print("statusCode");
      print(response.statusCode);
      return jsonDecode(response.body);
    }
  }
}

class PostHelper2 {
  final String url;

  PostHelper2(this.url);

  Future<dynamic> getData() async {
    Response response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else {
      print(response.statusCode);
      return jsonDecode(response.body);
    }
  }
}