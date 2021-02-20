import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class Stampa extends StatefulWidget {
  Stampa({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StampaState createState() => _StampaState();
}

enum Formato { radio_12_14, radio_15, radio_altro }

extension FormatoExtension on Formato {
  String get text {
    switch (this) {
      case Formato.radio_12_14:
        return "12/14 pollici";
      case Formato.radio_15:
        return "15 pollici";
      case Formato.radio_altro:
        return "altro";
      default:
        return "";
    } //switch
  }
}

class _StampaState extends State<Stampa> {
  Formato formato = Formato.radio_12_14;
  int copie = 1;
  final descrizioneController = TextEditingController();
  FocusNode _descrizioneFocus = FocusNode();
  String _descrizioneHelper = "";
  final _formKey = GlobalKey<FormState>();

  int totStampe = 0;
  int totCopie = 0;

  @override
  void initState() {
    super.initState();

    setDescrizioni();

    _descrizioneFocus.addListener(() {
      _descrizioneHelper = _descrizioneFocus.hasFocus ? "La nuova descrizione verrà inserita nell'elenco delle descrizioni." : "";

      setState(() {});
    });
  } //initState

  @override
  void dispose() {
    descrizioneController.dispose();
    super.dispose();
  } //dispose

  void onRadioFormato(newValue) {
    setState(() => formato = newValue);
  } //onRadioFormato

  Future<List<dynamic>> setDescrizioni() => Future.delayed(Duration(seconds: 2), () async {
        final http.Response response = await http.get(FlutterConfig.get('API_BASE_URL') + "models");

        if (response.statusCode > 299) return [];

        return jsonDecode(response.body)["models"];
      });

  void sendPrint() async {
    if (!_formKey.currentState.validate()) return;

    var map = Map<String, dynamic>();
    map["Size"] = formato.text;
    map["Model"] = descrizioneController.text;
    map["Copies"] = copie.toString();

    final http.Response response = await http.post(
      FlutterConfig.get('API_BASE_URL') + "copy",
      body: map,
    );

    print(response.statusCode);
    if (response.statusCode > 299) print("Errore");

    setState(() {});
  } //sendPrint

  void getTodayPrintAPI() async {
    String queryString = Uri(queryParameters: {"from": DateFormat("yyyy-MM-dd").format(DateTime.now())}).query;

    final http.Response response = await http.get(FlutterConfig.get('API_BASE_URL') + "history?$queryString");

    print(response.body);
  } //getTodayPrintAPI

  Future<List<RigaStampa>> getTodayPrintRows() async {
    String queryString = Uri(queryParameters: {"from": DateFormat("yyyy-MM-dd").format(DateTime.now())}).query;

    final http.Response response = await http.get(FlutterConfig.get('API_BASE_URL') + "history?$queryString");

    var json = jsonDecode(response.body);

    var stampe = json["prints"];
    totStampe = int.parse(json["total_prints"]);
    totCopie = int.parse(json["total_copies"]);

    return List<RigaStampa>.from(stampe.map((model) => RigaStampa.fromJson(model)));
  } //getTodayPrintRows

  @override
  Widget build(BuildContext context) {
    // Chip Label Style
    TextStyle chipLabelStyle = TextStyle(
      fontSize: 13,
      color: Colors.white,
    );

    // Row totale
    Row totale = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Totale: ",
          style: TextStyle(fontSize: 18),
        ),
        Chip(
          label: Text("stampe"),
          avatar: CircleAvatar(
            radius: 10,
            child: Text(
              "0",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.red,
          labelStyle: chipLabelStyle,
        ),
        Text(
          "|",
          style: TextStyle(fontSize: 18),
        ),
        Chip(
          label: Text("copie"),
          avatar: CircleAvatar(
            radius: 10,
            child: Text(
              "0",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.red,
          labelStyle: chipLabelStyle,
        )
      ],
    );

    // Circular Progress Indicator
    Column circularProgressIndicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 40.0,
          width: 40.0,
          child: CircularProgressIndicator(),
        ),
      ],
    );

    // Dialog
    SimpleDialog dialog = SimpleDialog(
      title: Text("Scegli la descrizione:"),
      children: <Widget>[
        Container(
          height: 300,
          width: 300,
          child: FutureBuilder<List<dynamic>>(
            initialData: [],
            future: setDescrizioni(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.length > 0)
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data[index]),
                      onTap: () {
                        setState(() => descrizioneController.text = snapshot.data[index]);
                        Navigator.pop(context, snapshot.data[index]);
                      },
                    );
                  },
                );
              else if (snapshot.hasError)
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Errore imprevisto"),
                  ],
                );

              return circularProgressIndicator;
            },
          ),
        ),
      ],
    );

    // Page content
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(52, 58, 64, .7),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(248, 249, 250, 1),
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    "Aggiungi stampa",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                // Formato
                                Text("Formato:", style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Radio(
                                      value: Formato.radio_12_14,
                                      groupValue: formato,
                                      onChanged: onRadioFormato,
                                    ),
                                    Text("12/14 pollici"),
                                    Radio(
                                      value: Formato.radio_15,
                                      groupValue: formato,
                                      onChanged: onRadioFormato,
                                    ),
                                    Text("15 pollici"),
                                    Radio(
                                      value: Formato.radio_altro,
                                      groupValue: formato,
                                      onChanged: onRadioFormato,
                                    ),
                                    Text("altro"),
                                  ],
                                ),
                                // Copie
                                Text("Copie: $copie", style: TextStyle(fontWeight: FontWeight.bold)),
                                Slider(
                                  value: copie.toDouble(),
                                  min: 1,
                                  max: 10,
                                  divisions: 10,
                                  label: copie.round().toString(),
                                  onChanged: (newValue) {
                                    setState(() => copie = newValue.round());
                                  },
                                ),
                                // Descrizione
                                Text("Descrizione:", style: TextStyle(fontWeight: FontWeight.bold)),
                                OutlineButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.search,
                                        color: Colors.green,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Text("Scegli la descrizione"),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) => dialog,
                                    );
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: TextFormField(
                                    controller: descrizioneController,
                                    focusNode: _descrizioneFocus,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Inserisci la descrizione",
                                      helperText: _descrizioneHelper,
                                      isDense: true,
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) return "La descrizione è obbligatoria";
                                      return null;
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () {
                                        _formKey.currentState.reset();
                                        setState(() {
                                          formato = Formato.radio_12_14;
                                          copie = 1;
                                        });
                                        descrizioneController.text = "";
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                      ),
                                      color: Colors.redAccent,
                                      textColor: Colors.white,
                                      child: Text("Annulla"),
                                    ),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                      ),
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                      child: Text("Stampa"),
                                      onPressed: sendPrint,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  RaisedButton(
                    child: Text("Stampe di oggi"),
                    onPressed: () => getTodayPrintAPI(),
                  ),
                ],
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Stampe di oggi",
                              style: TextStyle(fontSize: 25),
                            ),
                            FutureBuilder<List<RigaStampa>>(
                              future: getTodayPrintRows(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data.length > 0)
                                  return Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Totale: ",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Chip(
                                            label: Text("stampe"),
                                            avatar: CircleAvatar(
                                              radius: 10,
                                              child: Text(
                                                totStampe.toString(),
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                            backgroundColor: totStampe > 0 ? Colors.green : Colors.red,
                                            labelStyle: chipLabelStyle,
                                          ),
                                          Text(
                                            "|",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Chip(
                                            label: Text("copie"),
                                            avatar: CircleAvatar(
                                              radius: 10,
                                              child: Text(
                                                totCopie.toString(),
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                            backgroundColor: totCopie > 0 ? Colors.blue : Colors.red,
                                            labelStyle: chipLabelStyle,
                                          )
                                        ],
                                      ),
                                      DataTable(
                                        columns: <DataColumn>[
                                          DataColumn(
                                            label: Text("Descrizione"),
                                          ),
                                          DataColumn(
                                            label: Text("Formato"),
                                          ),
                                          DataColumn(
                                            label: Text("Copie"),
                                            numeric: true,
                                          ),
                                          DataColumn(
                                            label: Text(""),
                                          ),
                                        ],
                                        rows: snapshot.data
                                            .map(
                                              ((stampa) => DataRow(
                                                    cells: <DataCell>[
                                                      DataCell(
                                                        Text(stampa.descrizione),
                                                      ),
                                                      DataCell(
                                                        Text(stampa.formato),
                                                      ),
                                                      DataCell(
                                                        Text(stampa.copie.toString()),
                                                      ),
                                                      DataCell(
                                                        IconButton(
                                                          icon: Icon(Icons.delete),
                                                          color: Colors.red,
                                                          onPressed: () {
                                                            var id = stampa.id.toString();

                                                            http.delete(FlutterConfig.get("API_BASE_URL") + "copy/$id");

                                                            setState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  );
                                else if (snapshot.connectionState == ConnectionState.waiting)
                                  return circularProgressIndicator;
                                else if (snapshot.hasError) {
                                  print(snapshot.error);
                                }

                                return Column(
                                  children: <Widget>[
                                    totale,
                                    Text("Nessuna stampa"),
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  } //build

} //_StampaState

class RigaStampa {
  final int id;
  final String descrizione;
  final String formato;
  final int copie;
  final String timestamp;

  RigaStampa.fromJson(Map<String, dynamic> json)
      : id = int.parse(json["ID"]),
        descrizione = json["Model"],
        formato = json["Size"],
        copie = int.parse(json["Copies"]),
        timestamp = json["Timestamp"];
} //RigaStampa
