import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultingRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Congratulations!"),
          centerTitle: true,
        ),
        body: Padding(
            padding: EdgeInsets.all(30.0),
            child: Center(
                child: Column(
              children: [
                Text(
                  "Результаты расчета:",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                //SizedBox(height: 20.0,),
                //Image.asset('assets/images/cat.jpeg', scale: 8),
                SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                    onPressed: () {
                      //выход из приложения
                      SystemNavigator.pop();
                    },
                    child: Text("Закрыть"))
              ],
            ))));
  }
}
