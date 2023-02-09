import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    _initSpeech();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    _fromLanguage = prefs.getString('fromLanguage');
    _toLanguage = prefs.getString('toLanguage');
    super.didChangeDependencies();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    _locales = await _speechToText.locales();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _fromLanguage,
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    _audioRecorded = (result.recognizedWords);
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
    if (_speechToText.isNotListening) {
      _traslator
          .translate(_audioRecorded,
              to: _toLanguage == null ? 'en' : _toLanguage!.split('_')[0])
          .then((value) {
        _translatedText = value.text;
        setState(() {});
      });
    }
  }

  final SpeechToText _speechToText = SpeechToText();
  final _traslator = GoogleTranslator();
  String _audioRecorded = '';
  String _translatedText = '';
  List<LocaleName> _locales = [];
  String? _fromLanguage;
  String? _toLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            DropdownButton(
                              value: _fromLanguage,
                              hint: const Text('Select Language'),
                              items: _locales
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.localeId,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) async {
                                setState(() {
                                  _fromLanguage = value.toString();
                                });
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString('fromLanguage', value!);
                              },
                            ),
                            const SizedBox(height: 30),
                            Text(
                              _audioRecorded,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            DropdownButton(
                              value: _toLanguage,
                              hint: const Text('Select Language'),
                              items: _locales
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.localeId,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) async {
                                setState(() {
                                  _toLanguage = value.toString();
                                });
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString('toLanguage', value!);
                              },
                            ),
                            const SizedBox(height: 30),
                            Text(
                              _translatedText,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.47,
            left: MediaQuery.of(context).size.width * 0.45,
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border(
                  top: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  left: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  right: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  if (_speechToText.isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
                icon: Icon(
                  _speechToText.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
