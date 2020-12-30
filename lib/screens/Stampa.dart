import 'package:flutter/material.dart';

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
  final List<DropdownMenuItem> items = [];
  String selectedValue;

  final String loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

  @override
  void initState() {
    String wordPair = "";
    loremIpsum
        .toLowerCase()
        .replaceAll(",", "")
        .replaceAll(".", "")
        .split(" ")
        .forEach((word) {
      if (wordPair.isNotEmpty) {
        wordPair += word;
        if (items.indexWhere((item) {
              return (item.value == wordPair);
            }) ==
            -1)
          items.add(DropdownMenuItem(
            child: Text(wordPair),
            value: wordPair,
          ));
        wordPair = "";
      } else
        wordPair = word + " ";
    });
    super.initState();
  } //initState

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
          )
        ],
      ),
    );
  } //build

} //_StampaState
