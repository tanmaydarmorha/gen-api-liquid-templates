import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gen AI Liquid Templates',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black26),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _inputJson = '';
  String _mappingRules = '';
  String _outputText = '';
  Timer? _typingTimer;
  bool _isLoading = false; // Flag for loading state

  @override
  void dispose() {
    _typingTimer?.cancel(); // Cancel the timer when the widget is disposed
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use a Row to achieve centered title
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the children
          children: [
            Text(
              'Gen AI Liquid Templates',
              textAlign: TextAlign.center, // Optional for consistency
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black26, width: 2.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(_focusNode1);
                            },
                            child: SingleChildScrollView(
                              child: TextField(
                                focusNode: _focusNode1,
                                maxLines: null,
                                onChanged: (value) {
                                  setState(() {
                                    _inputJson = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Input JSON', // Add hint text
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.black26, width: 2.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(_focusNode2);
                            },
                            child: SingleChildScrollView(
                              child: TextField(
                                focusNode: _focusNode2,
                                maxLines: null,
                                onChanged: (value) {
                                  setState(() {
                                    _mappingRules = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Mapping Rules', // Add hint text
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26, width: 2.0),
                  ),
                  child: _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(), // Show loading indicator
                        )
                      : SingleChildScrollView(
                          child: Center(
                            child: SelectableText(
                              _outputText, // Display the output text
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // Set loading state
                });
                _outputText = ''; // Reset output text
                // Simulate a 3-second delay before typing
                String generatedText = await _generateOutputText(_inputJson, _mappingRules);
                setState(() {
                  _isLoading = false; // End loading state
                });
                _typeCharacterByCharacter(generatedText);
              },
              child: Icon(Icons.arrow_right_alt),
            ),
          )
        ],
      ),
    );
  }

  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: "apiKey",
    // safetySettings: Adjust safety settings
    // See https://ai.google.dev/gemini-api/docs/safety-settings
    generationConfig: GenerationConfig(
      temperature: 1,
      topK: 64,
      topP: 0.95,
      maxOutputTokens: 8192,
      responseMimeType: 'text/plain',
    ),
  );

  Future<String> _generateOutputText(String inputJson, String mappingRules) async {
final response = await model.generateContent([
      Content(
          text: 'response should only contain liquid template, no explanation needed'),
      Content(text: 'input: if input is json array'),
      Content(text: 'output: response should be a fhir bundle liquid template'),
      Content(text: 'input: if input is json object'),
      Content(text: 'output: response should be a fhir resource liquid template'),
      Content(
          text: 'input: $inputJson \n\nI have this json, I want a liquid template which converts this to following FHIR json\n\n $mappingRules'),
      Content(text: 'output: '),
    ]);
    // Extract the generated text from the response
    return (response.first as Map<String, dynamic>)['content'] as String; 
  }

  void _typeCharacterByCharacter(String text) {
    int index = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (index < text.length) {
        setState(() {
          _outputText += text[index];
        });
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
}