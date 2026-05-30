import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/dart.dart';
import '../models/coding_question.dart';
import '../services/judge_service.dart';
import '../utils/languages.dart';

class CodingEditorPreview extends StatefulWidget {
  final CodingQuestion? question;
  final String? initialInput;
  final VoidCallback? onAccepted;

  const CodingEditorPreview({
    super.key,
    this.question,
    this.initialInput,
    this.onAccepted,
  });

  @override
  State<CodingEditorPreview> createState() => _CodingEditorPreviewState();
}

class _CodingEditorPreviewState extends State<CodingEditorPreview> {
  final Map<String, dynamic> highlightLanguageMap = {
    'Python': python,
    'C++': cpp,
    'Java': java,
    'Dart': dart,
  };

  String selectedLanguage = 'Python';
  late CodeController _codeController;
  String? output;
  bool isLoading = false;
  bool isAccepted = false;
  Duration? executionTime;
  int? peakMemory;

  Map<String, String> get _testcase {
    final question = widget.question;
    return {
      'input': question?.sampleInput ?? widget.initialInput ?? '2 3',
      'expected': question?.sampleOutput ?? '5',
    };
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '',
      language: highlightLanguageMap[selectedLanguage],
    );
  }

  void _onLanguageChanged(String language) {
    setState(() {
      selectedLanguage = language;
      _codeController.language = highlightLanguageMap[language];
      _codeController.text = '';
    });
  }

  void _onClearCode() {
    setState(() {
      _codeController.text = '';
      output = '';
      isAccepted = false;
      executionTime = null;
      peakMemory = null;
    });
  }

  Future<void> _onRunCode() async {
    setState(() {
      isLoading = true;
      output = null;
      isAccepted = false;
      executionTime = null;
      peakMemory = null;
    });

    double totalTime = 0.0;
    int maxMem = 0;
    final testcase = _testcase;
    final res = await runCodeWithJudge0(
      sourceCode: _codeController.text,
      languageId: languageMap[selectedLanguage]!,
      languageName: selectedLanguage,
      stdin: testcase['input'],
    );
    final thisPassed =
        res.success &&
        _normalizedJudgeText(res.output) ==
            _normalizedJudgeText(testcase['expected']!);

    final timeVal = double.tryParse(res.time ?? '0') ?? 0.0;
    final memVal = int.tryParse(res.memory ?? '0') ?? 0;
    totalTime += timeVal;
    if (memVal > maxMem) maxMem = memVal;

    setState(() {
      isLoading = false;
      isAccepted = thisPassed;
      executionTime = Duration(microseconds: (totalTime * 1000000).toInt());
      peakMemory = maxMem;
      output =
          'Input: ${testcase['input']}\nYour output: ${res.output.trim()}\nExpected: ${testcase['expected']}\nResult: ${thisPassed ? "Accepted" : "Wrong Answer"}';
    });

    if (thisPassed) {
      widget.onAccepted?.call();
    }
  }

  String _normalizedJudgeText(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade700, width: 1),
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: CodeField(
              controller: _codeController,
              textStyle: const TextStyle(
                fontFamily: 'FiraMono',
                color: Colors.white,
                fontSize: 15,
              ),
              expands: true,
              background: Colors.transparent,
              cursorColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              DropdownButton<String>(
                value: selectedLanguage,
                items: <String>['Python']
                    .map(
                      (lang) => DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang),
                      ),
                    )
                    .toList(),
                onChanged: (lang) => _onLanguageChanged(lang!),
                dropdownColor: Colors.grey[900],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.redAccent,
                ),
                onPressed: _onClearCode,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Submit Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading ? null : _onRunCode,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isLoading && output != null)
            Container(
              decoration: BoxDecoration(
                color: isAccepted ? Colors.green[900] : Colors.red[900],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAccepted ? 'Accepted' : 'Wrong Answer',
                    style: TextStyle(
                      color: isAccepted
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 19),
                      const SizedBox(width: 6),
                      Text(
                        "Execution Time: ${executionTime != null ? (executionTime!.inMilliseconds / 1000).toStringAsFixed(3) : '-'}s",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.memory, color: Colors.white, size: 19),
                      const SizedBox(width: 6),
                      Text(
                        "Memory: ${peakMemory ?? '-'} KB",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 60, maxHeight: 200),
              color: Colors.black.withOpacity(0.93),
              padding: const EdgeInsets.all(8),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(
                        output ?? '',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 15,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
