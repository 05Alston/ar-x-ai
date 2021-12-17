import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart' as tts;

class TextToSpeech extends StatefulWidget {
  const TextToSpeech({Key? key}) : super(key: key);

  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TypeScreen(),
    );
  }
}

class TypeScreen extends StatefulWidget {
  const TypeScreen({Key? key}) : super(key: key);

  @override
  _TypeScreenState createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  String _defaultLanguage = 'en-US';
  late tts.TextToSpeech _textToSpeech;
  String _text = '';
  double _volume = 1; // Range: 0-1
  double _rate = 1.0; // Range: 0-2
  double _pitch = 1.0; // Range: 0-2
  String? _language;
  String? _languageCode;
  String? _voice;
  List<String> _languages = <String>[];
  List<String> _languageCodes = <String>[];
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = _text;
    _textToSpeech = tts.TextToSpeech();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initLanguages();
    });
  }

  Future<void> initLanguages() async {
    /// populate lang code (i.e. en-US)
    _languageCodes = await _textToSpeech.getLanguages();

    /// populate displayed language (i.e. English)
    final List<String>? displayLanguages = await _textToSpeech.getDisplayLanguages();
    if (displayLanguages == null) {
      return;
    }

    _languages.clear();
    for (final dynamic lang in displayLanguages) {
      _languages.add(lang as String);  // for each loop
    }

    final String? defaultLangCode = await _textToSpeech.getDefaultLanguage();
    if (defaultLangCode != null && _languageCodes.contains(defaultLangCode)) {
      _languageCode = defaultLangCode;
    } else {
      _languageCode = _defaultLanguage;
    }
    _language = await _textToSpeech.getDisplayLanguageByCode(_languageCode!);//
    // en-us => English

    /// get voice
    _voice = await getVoiceByLang(_languageCode!);

    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getVoiceByLang(String lang) async {
    final List<String>? voices = await _textToSpeech.getVoiceByLang(_languageCode!);
    if (voices != null && voices.isNotEmpty) {
      return voices.first;
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text-To-Speech Screen"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter some text here...'),
              onChanged: (String newText) {
                setState(() {
                  _text = newText;
                });
              },
            ),
            Row(
              children: <Widget>[
                const Text('Volume'),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0,
                    max: 1,
                    label: _volume.round().toString(),
                    onChanged: (double value) {
                      initLanguages();
                      setState(() {
                        _volume = value;
                      });
                    },
                  ),
                ),
                Text('(${(_volume*100).toStringAsFixed(2)})'),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Rate'),
                Expanded(
                  child: Slider(
                    value: _rate,
                    min: 0,
                    max: 2,
                    label: _rate.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _rate = value;
                      });
                    },
                  ),
                ),
                Text('(${_rate.toStringAsFixed(2)})'),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Pitch'),
                Expanded(
                  child: Slider(
                    value: _pitch,
                    min: 0,
                    max: 2,
                    label: _pitch.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _pitch = value;
                      });
                    },
                  ),
                ),
                Text('(${_pitch.toStringAsFixed(2)})'),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Language'),
                const SizedBox(
                  width: 20,
                ),
                DropdownButton<String>(
                  value: _language,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) async {
                    _languageCode =
                    await _textToSpeech.getLanguageCodeByName(newValue!);
                    _voice = await getVoiceByLang(_languageCode!);
                    setState(() {
                      _language = newValue;
                    });
                  },
                  items: _languages
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                const Text('Voice'),
                const SizedBox(
                  width: 47,
                ),
                Text(_voice ?? '-'),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Stop'),
                      onPressed: () {
                        _textToSpeech.stop();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Speak'),
                      onPressed: _speak,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _speak() {
    _textToSpeech.setVolume(_volume);
    _textToSpeech.setRate(_rate);
    if (_languageCode != null) {
      _textToSpeech.setLanguage(_languageCode!);
    }
    _textToSpeech.setPitch(_pitch);
    _textToSpeech.speak(_text);
  }
}
