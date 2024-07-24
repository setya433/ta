import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:io' show Platform;
// // import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
// import 'package:flutter/services.dart' show ByteData, rootBundle;

class VoiceControlScreen extends StatefulWidget {
  @override
  _VoiceControlScreenState createState() => _VoiceControlScreenState();
}

class _VoiceControlScreenState extends State<VoiceControlScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  // late Interpreter interpreter;
  Interpreter? _interpreter;
  String _text = 'Press To Speak';
  String _identifiedSpeaker = '';
  String _identity = '';
  var _model = 'assets/tes1.tflite';
  final Map<int, String> labels = {
    0: 'herlambang',
    1: 'zultan',
  };
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  String _localeId = 'id_ID'; // Default to Indonesian
  String userName = '';


  @override
  void initState() {
    super.initState();
    _initInterpreter(); // Initialize TensorFlow Lite interpreter
    _speech = stt.SpeechToText();
    _initSpeechRecognition();
    _getUserName();
  }

  void _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('ID').doc(user.uid).get();
      setState(() {
        userName = userDoc['name'];
        print('name:$userName');
      });
    }
  }

  Future<void> _initInterpreter() async {
  try {
    // Verifikasi path model
    // final ByteData data = await rootBundle.load('assets/tes1.tflite');
    // print('Model size: ${data.lengthInBytes} bytes');

    // // Membuat interpreter dengan FlexDelegate
    // final delegate = GpuDelegateV2(options: GpuDelegateOptionsV2(isPrecisionLossAllowed: false));
    // final interpreterOptions = InterpreterOptions()..addDelegate(GpuDelegate());

     var _interpreter = await Interpreter.fromAsset(
      'assets/tes1.tflite'
    );
    print("sukses $_interpreter");
  } catch (e) {
    print('Error loading model: $e');
  }
  }

  Future<void> _initSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
      },
      onError: (val) {
        print('onError: $val');
      },
    );
    if (available) {
      var locales = await _speech.locales();
      print('Available locales: $locales');

      var selectedLocale = locales.firstWhere(
        (locale) => locale.localeId == 'ms_MY',
        orElse: () => locales.first,
      );

      setState(() {
        _localeId = selectedLocale.localeId;
      });
      print('Selected locale: $_localeId');
    } else {
      print('Speech recognition not available');
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
        },
        onError: (val) {
          print('onError: $val');
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            setState(() {
              _text = val.recognizedWords;
            });

            print('Recognized words: $_text');

            // Handle recognized commands
            

            // Perform voice authentication using TensorFlow Lite
            var features = extractAudioFeatures(_text);
            if (features.isNotEmpty) {
              print('Extracted features: $features');

              int desiredLength = 40;
              List<double> paddedTensor = padOrTrimTensor(features, desiredLength);
              List<List<double>> reshapedTensor = reshapeTensor(paddedTensor, desiredLength, 1);

              print("Reshaped Tensor: $reshapedTensor");

              var inputShape = [1, features.length, 1];
              var input = features.reshape(inputShape);
              print('Input tensor: $input');

              var inputTensor = reshapedTensor.expand((i) => i).toList();
              var finalinput = inputTensor.reshape([1, desiredLength]);
              var transposedTensor = [finalinput];

              var output = List.filled(labels.length, 0).reshape([1, labels.length]);
              print('Initialized output: $output');
              print('Initialized inputfinal: $finalinput');

              try {
                _interpreter?.run(transposedTensor, output);
                print('Output after run: $output');

                var result = output[0];
                print('Result final: $result');
                var maxIndex = result.indexOf(result.reduce((a, b) => a > b ? a : b));
                var identifiedLabel = labels[maxIndex];

                setState(() {
                  _identifiedSpeaker = 'Speaker Identified: $identifiedLabel';
                  _identity = '$identifiedLabel'; 
                });

                print('Authentication successful, identified speaker: $identifiedLabel');
              } catch (e) {
                print('Error running interpreter: $e');
                setState(() {
                  _identifiedSpeaker = 'Authentication failed';
                });
              }
            } else {
              print('Failed to extract features from audio');
              setState(() {
                _identifiedSpeaker = 'Authentication failed';
              });
            }
            if (_text.toLowerCase().contains("nyalakan lampu tengah") && (_identity == userName)) {
              _updateFirebaseLed1('0');
            } else if (_text.toLowerCase().contains("matikan lampu tengah") && (_identity == userName)) {
              _updateFirebaseLed1('1');
            } else if (_text.toLowerCase().contains("nyalakan lampu teras") && (_identity == userName)) {
              _updateFirebaseLed2('0');
            } else if (_text.toLowerCase().contains("matikan lampu teras") && (_identity == userName)) {
              _updateFirebaseLed2('1');
            } else if (_text.toLowerCase().contains("nyalakan kipas") && (_identity == userName)) {
              _updateFirebaseKipas('0');
            } else if (_text.toLowerCase().contains("matikan kipas") && (_identity == userName)) {
              _updateFirebaseKipas('1');
            } else if (_text.toLowerCase().contains("nyalakan semua") && (_identity == userName)) {
              _updateFirebaseKipas('0');
              _updateFirebaseLed1('0');
              _updateFirebaseLed2('0');
            } else if (_text.toLowerCase().contains("matikan semua") && (_identity == userName)) {
              _updateFirebaseKipas('1');
              _updateFirebaseLed1('1');
              _updateFirebaseLed2('1');
            } else {
              _unrecognizedCommand();
            }
          },
          localeId: _localeId, // Set the language to the selected locale
          
        );
      } else {
        print('Speech recognition not available');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  void _updateFirebaseLed1(String value) {
    databaseReference.child('led-db/led_1').set(value).then((_) {
      print('led_1 updated successfully in Firebase.');
    }).catchError((error) {
      print('Failed to update led_1: $error');
    });
  }

  void _updateFirebaseLed2(String value) {
    databaseReference.child('led-db/led_2').set(value).then((_) {
      print('led_2 updated successfully in Firebase.');
    }).catchError((error) {
      print('Failed to update led_2: $error');
    });
  }

  void _updateFirebaseKipas(String value) {
    databaseReference.child('led-db/kipas').set(value).then((_) {
      print('kipas updated successfully in Firebase.');
    }).catchError((error) {
      print('Failed to update kipas: $error');
    });
  }

  void _unrecognizedCommand() {
    print('Unknown command received.');
  }

  List<double> extractAudioFeatures(String speechText) {
    List<double> features = [];
    for (int i = 0; i < speechText.length; i++) {
      features.add(speechText.codeUnitAt(i).toDouble());
    }
    print('Extracted features from speech text: $features');
    return features;
  }

  List<double> padOrTrimTensor(List<double> tensor, int length) {
    if (tensor.length > length) {
      return tensor.sublist(0, length);
    } else if (tensor.length < length) {
      return tensor + List<double>.filled(length - tensor.length, 0.0);
    } else {
      return tensor;
    }
  }

  List<List<double>> reshapeTensor(List<double> tensor, int rows, int cols) {
    List<List<double>> reshaped = [];
    for (int i = 0; i < rows; i++) {
      reshaped.add([tensor[i]]);
    }
    return reshaped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_text',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              '$_identifiedSpeaker',
              style: TextStyle(fontSize: 24, color: Colors.green),
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _listen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ],
        ),
      ),
    );
  }
}

extension ListUtils<T> on List<T> {
  List<List<T>> reshape(List<int> newShape) {
    List<List<T>> reshaped = [];
    int sublistSize = newShape.last;
    for (var i = 0; i < length; i += sublistSize) {
      reshaped.add(sublist(i, i + sublistSize));
    }
    return reshaped;
  }
}
