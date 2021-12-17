import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToText extends StatefulWidget {
  const SpeechToText({Key? key}) : super(key: key);

  @override
  _SpeechToTextState createState() => _SpeechToTextState();
}

class _SpeechToTextState extends State<SpeechToText> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Confidence: ${{_confidence * 100.0}.toString()}%'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation
            .centerDocked,
        floatingActionButton: AvatarGlow(
            glowColor: Theme.of(context).primaryColor,
            animate: _isListening,
            endRadius: 75.0,
            duration: Duration(milliseconds: 2000),
            repeatPauseDuration: Duration(milliseconds: 100),
            repeat: true,
            child: FloatingActionButton(
              onPressed:!_isListening ? _listen : _stopListen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ),
        body: SingleChildScrollView(
          reverse: true,
          child: Container(
            padding: EdgeInsets.all(30.0),
            child: Text(_text,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                )),
          ),
        ));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print("Status: $val"),
        onError: (val) => print("Error: $val"),
      );
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0)
              _confidence = val.confidence;
          }),
        );
      }
    }
  }
  void _stopListen () async{
    await _speech.stop();
      setState(() => _isListening = false);
  }
}
