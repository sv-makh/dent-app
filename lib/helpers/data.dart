import 'dart:convert';
import 'package:http/http.dart';

//классы для подключения к API

class DataFetch {
  //name - из массива parameters в main.dart
  Future<dynamic> getData(String name) async {
    FetchHelper fetchData = FetchHelper("http://157.245.254.251:8000/drstudent/api/$name");

    var decodedData = await fetchData.getData();
    return decodedData;
  }
}

class FetchHelper {
  final String url;

  FetchHelper(this.url);

  Future<dynamic> getData() async {
    Response response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else {
      print(response.statusCode);
    }
  }
}