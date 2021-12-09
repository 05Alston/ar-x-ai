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
  String defaultLanguage = 'en-US';
  late tts.TextToSpeech _textToSpeech;
  String text = '';
  double volume = 1; // Range: 0-1
  double rate = 1.0; // Range: 0-2
  double pitch = 1.0; // Range: 0-2
  String? language;
  String? languageCode;
  String? voice;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = text;
    _textToSpeech = tts.TextToSpeech();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initLanguages();
    });
  }

  Future<void> initLanguages() async {
    /// populate lang code (i.e. en-US)
    languageCodes = await _textToSpeech.getLanguages();

    /// populate displayed language (i.e. English)
    final List<String>? displayLanguages = await _textToSpeech.getDisplayLanguages();
    if (displayLanguages == null) {
      return;
    }

    languages.clear();
    for (final dynamic lang in displayLanguages) {
      languages.add(lang as String);
    }

    final String? defaultLangCode = await _textToSpeech.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = defaultLanguage;
    }
    language = await _textToSpeech.getDisplayLanguageByCode(languageCode!);

    /// get voice
    voice = await getVoiceByLang(languageCode!);

    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getVoiceByLang(String lang) async {
    final List<String>? voices = await _textToSpeech.getVoiceByLang(languageCode!);
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
                  text = newText;
                });
              },
            ),
            Row(
              children: <Widget>[
                const Text('Volume'),
                Expanded(
                  child: Slider(
                    value: volume,
                    min: 0,
                    max: 1,
                    label: volume.round().toString(),
                    onChanged: (double value) {
                      initLanguages();
                      setState(() {
                        volume = value;
                      });
                    },
                  ),
                ),
                Text('(${(volume * 100).toStringAsFixed(2)})'),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Rate'),
                Expanded(
                  child: Slider(
                    value: rate,
                    min: 0,
                    max: 2,
                    label: rate.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        rate = value;
                      });
                    },
                  ),
                ),
                Text('(${rate.toStringAsFixed(2)})'),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Pitch'),
                Expanded(
                  child: Slider(
                    value: pitch,
                    min: 0,
                    max: 2,
                    label: pitch.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        pitch = value;
                      });
                    },
                  ),
                ),
                Text('(${pitch.toStringAsFixed(2)})'),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Language'),
                const SizedBox(
                  width: 20,
                ),
                DropdownButton<String>(
                  value: language,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) async {
                    languageCode =
                    await _textToSpeech.getLanguageCodeByName(newValue!);
                    voice = await getVoiceByLang(languageCode!);
                    setState(() {
                      language = newValue;
                    });
                  },
                  items: languages
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
                Text(voice ?? '-'),
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
    _textToSpeech.setVolume(volume);
    _textToSpeech.setRate(rate);
    if (languageCode != null) {
      _textToSpeech.setLanguage(languageCode!);
    }
    _textToSpeech.setPitch(pitch);
    _textToSpeech.speak(text);
  }
}
