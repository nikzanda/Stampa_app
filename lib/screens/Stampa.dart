import 'package:flutter/material.dart';
// import 'package:http/http.dart';

class Stampa extends StatefulWidget {
  Stampa({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StampaState createState() => _StampaState();
}

enum Formato { radio_12_14, radio_15, radio_altro }

class _StampaState extends State<Stampa> {
  Formato formato = Formato.radio_12_14;
  int copie = 1;

  void onRadioFormato(newValue) {
    setState(() => formato = newValue);
  } //onRadioFormato

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Formato
                Text("Formato", style: TextStyle(fontWeight: FontWeight.bold)),
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
                Text("Copie: $copie",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: copie.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 20,
                  label: copie.round().toString(),
                  onChanged: (newValue) {
                    setState(() => copie = newValue.round());
                  },
                ),
                // Descrizione
                Text("Descrizione",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      color: Colors.green,
                      tooltip: "Cerca",
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                color: Colors.redAccent,
                textColor: Colors.white,
                child: Text("Annulla"),
              ),
              RaisedButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                color: Colors.blue,
                textColor: Colors.white,
                child: Text("Stampa"),
              )
            ],
          )
        ],
      ),
    );
  } //build

} //_StampaState
