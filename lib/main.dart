import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=e6cad844";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber))),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final reaisController = TextEditingController();
  final dolaresController = TextEditingController();
  final eurosController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolaresController.text = (real / dolar).toStringAsFixed(2);
    eurosController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolarr = double.parse(text);
    reaisController.text = (dolarr * dolar).toStringAsFixed(2);
    eurosController.text = (dolarr * dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euroo = double.parse(text);
    dolaresController.text = (euroo * euro / dolar).toStringAsFixed(2);
    reaisController.text = (euroo * euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.amber,
          title: Text(
            "Conversor de moedas",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.refresh, color: Colors.white,),
                onPressed: () {
                    reaisController.clear();
                    dolaresController.clear();
                    eurosController.clear();
                })
          ],
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar Dados",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                          child: Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber)),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: BuildTextField(
                              "Reais", "R\$ ", reaisController, _realChanged)),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: BuildTextField("Dólares", "US\$ ",
                              dolaresController, _dolarChanged)),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: BuildTextField(
                              "Euros", "€ ", eurosController, _euroChanged)),
                    ],
                  ));
                }
            }
          },
        ));
  }
}

Widget BuildTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
