import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultingRoute extends StatelessWidget {
  final String result;

  const ResultingRoute({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     AppLocalizations.of(context)!
        //         .completedSuccessfully, //"Форма успешно заполнена"
        //   ),
        //   centerTitle: true,
        // ),
        body: Padding(
            padding: EdgeInsets.all(30.0),
            child: Center(
                child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .durationOfOrthopedicLoad, // "Срок ортопедической нагрузки (в сутках)",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  result,
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                // SizedBox(
                //   height: 20.0,
                // ),
                // ElevatedButton(
                //     onPressed: () {
                //       //выход из приложения
                //       SystemNavigator.pop();
                //     },
                //     child: Text(
                //       AppLocalizations.of(context)!.close, // "Закрыть"
                //     ))
              ],
            ))));
  }
}
