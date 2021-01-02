import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();

    _descrizioneFocus.addListener(() {
      _descrizioneHelper = _descrizioneFocus.hasFocus
          ? "La nuova descrizione verrà inserita nell'elenco delle descrizioni."
          : "";

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

  void sendPrint() async {
    if (!_formKey.currentState.validate()) return;

    var map = new Map<String, dynamic>();
    map["formato"] = formato.text;
    map["descrizione"] = descrizioneController.text;
    map["copie"] = copie.toString();

    final http.Response response = await http.post(
      FlutterConfig.get('API_BASE_URL') + "inserisci_stampa.php",
      body: map,
    );

    print(response.statusCode);
  } //sendPrint

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
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
                      // Formato
                      Text("Formato:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                      Text("Descrizione:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                              child: Text("Scegli descrizione"),
                            ),
                          ],
                        ),
                        onPressed: () {},
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
                            if (value.isEmpty)
                              return "La descrizione è obbligatoria";
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                            color: Colors.redAccent,
                            textColor: Colors.white,
                            child: Text("Annulla"),
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
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
      ),
    );
  } //build

} //_StampaState
