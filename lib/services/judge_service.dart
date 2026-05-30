import 'dart:convert';

import 'package:http/http.dart' as http;

class JudgeResult {
  final bool success;
  final String statusMessage;
  final String output;
  final String? time;
  final String? memory;

  JudgeResult({
    required this.success,
    required this.statusMessage,
    required this.output,
    this.time,
    this.memory,
  });
}

class _FunctionSpec {
  final String name;
  final List<_ParameterSpec> parameters;

  const _FunctionSpec({required this.name, required this.parameters});
}

class _ParameterSpec {
  final String type;

  const _ParameterSpec(this.type);
}

Future<JudgeResult> runCodeWithJudge0({
  required String sourceCode,
  required int languageId,
  required String languageName,
  String? stdin,
  String? expectedOutput,
}) async {
  final submissionSource = _prepareSubmissionSource(
    sourceCode: sourceCode,
    languageName: languageName,
  );

  final uri = Uri.parse(
    'https://ce.judge0.com/submissions/?base64_encoded=false&wait=true',
  );
  final response = await http.post(
    uri,
    headers: {'content-type': 'application/json'},
    body: jsonEncode({
      'language_id': languageId,
      'source_code': submissionSource,
      'stdin': stdin ?? '',
    }),
  );

  final result = jsonDecode(response.body);
  final statusId = result['status']?['id'];
  final statusDesc = result['status']?['description'] ?? '';
  final output = result['stdout'] ?? '';
  final time = result['time']?.toString();
  final memory = result['memory']?.toString();
  final success = statusId == 3;

  return JudgeResult(
    success: success,
    statusMessage: statusDesc,
    output: output,
    time: time,
    memory: memory,
  );
}

String _prepareSubmissionSource({
  required String sourceCode,
  required String languageName,
}) {
  if (_hasManualEntryPoint(sourceCode, languageName)) {
    return sourceCode;
  }

  final spec = _extractFunctionSpec(sourceCode, languageName);
  if (spec == null) {
    return sourceCode;
  }

  switch (languageName) {
    case 'Python':
      return _wrapPythonSource(sourceCode, spec);
    case 'C++':
      return _wrapCppSource(sourceCode, spec);
    case 'Java':
      return _wrapJavaSource(sourceCode, spec);
    case 'Dart':
      return _wrapDartSource(sourceCode, spec);
    default:
      return sourceCode;
  }
}

bool _hasManualEntryPoint(String sourceCode, String languageName) {
  switch (languageName) {
    case 'Python':
      return sourceCode.contains('if __name__ ==') ||
          sourceCode.contains('input(') ||
          sourceCode.contains('print(');
    case 'C++':
      return RegExp(r'\bint\s+main\s*\(').hasMatch(sourceCode) ||
          RegExp(r'\bsigned\s+main\s*\(').hasMatch(sourceCode);
    case 'Java':
      return RegExp(r'\bvoid\s+main\s*\(').hasMatch(sourceCode) ||
          sourceCode.contains('System.out') ||
          sourceCode.contains('Scanner');
    case 'Dart':
      return RegExp(r'\bvoid\s+main\s*\(').hasMatch(sourceCode) ||
          sourceCode.contains('stdin') ||
          sourceCode.contains('print(');
    default:
      return false;
  }
}

_FunctionSpec? _extractFunctionSpec(String sourceCode, String languageName) {
  switch (languageName) {
    case 'Python':
      return _extractPythonFunctionSpec(sourceCode);
    case 'C++':
      return _extractCppFunctionSpec(sourceCode);
    case 'Java':
      return _extractJavaFunctionSpec(sourceCode);
    case 'Dart':
      return _extractDartFunctionSpec(sourceCode);
    default:
      return null;
  }
}

_FunctionSpec? _extractPythonFunctionSpec(String sourceCode) {
  final match = RegExp(
    r'^\s*def\s+([A-Za-z_][\w]*)\s*\(([^)]*)\)\s*:',
    multiLine: true,
  ).firstMatch(sourceCode);
  if (match == null || match.group(1) == 'main') {
    return null;
  }

  return _FunctionSpec(
    name: match.group(1)!,
    parameters: _parsePythonParameters(match.group(2) ?? ''),
  );
}

List<_ParameterSpec> _parsePythonParameters(String parameterText) {
  if (parameterText.trim().isEmpty) return const [];

  return parameterText
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty && part != 'self' && part != 'cls')
      .map((_) => const _ParameterSpec('dynamic'))
      .toList();
}

_FunctionSpec? _extractCppFunctionSpec(String sourceCode) {
  final match = RegExp(
    r'^(?:\s*(?:inline\s+|static\s+|constexpr\s+)*)?([A-Za-z_][\w:<>,\s\*&\[\]]*?)\s+([A-Za-z_][\w]*)\s*\(([^;{}]*)\)\s*\{',
    multiLine: true,
  ).firstMatch(sourceCode);
  if (match == null || match.group(2) == 'main') {
    return null;
  }

  return _FunctionSpec(
    name: match.group(2)!,
    parameters: _parseTypedParameters(match.group(3) ?? ''),
  );
}

_FunctionSpec? _extractJavaFunctionSpec(String sourceCode) {
  final match = RegExp(
    r'^(?:\s*(?:public|private|protected)\s+)?(?:static\s+)?([A-Za-z_][\w<>\[\], ?]*)\s+([A-Za-z_][\w]*)\s*\(([^;{}]*)\)\s*\{',
    multiLine: true,
  ).firstMatch(sourceCode);
  if (match == null || match.group(2) == 'main') {
    return null;
  }

  return _FunctionSpec(
    name: match.group(2)!,
    parameters: _parseTypedParameters(match.group(3) ?? ''),
  );
}

_FunctionSpec? _extractDartFunctionSpec(String sourceCode) {
  final match = RegExp(
    r'^(?:\s*)([A-Za-z_][\w<>?\[\],\s]*)\s+([A-Za-z_][\w]*)\s*\(([^)]*)\)\s*(?:\{|=>)',
    multiLine: true,
  ).firstMatch(sourceCode);
  if (match == null || match.group(2) == 'main') {
    return null;
  }

  return _FunctionSpec(
    name: match.group(2)!,
    parameters: _parseTypedParameters(match.group(3) ?? ''),
  );
}

List<_ParameterSpec> _parseTypedParameters(String parameterText) {
  if (parameterText.trim().isEmpty) return const [];

  return parameterText
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .map((part) {
        final cleaned = part
            .replaceAll(RegExp(r'\b(final|required|const|mutable)\b'), '')
            .trim();
        final typePart = cleaned.contains(' ')
            ? cleaned.substring(0, cleaned.lastIndexOf(' ')).trim()
            : cleaned;
        return _ParameterSpec(_normalizeType(typePart));
      })
      .toList();
}

String _normalizeType(String type) {
  final normalized = type.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  if (normalized.contains('string')) return 'string';
  if (normalized.contains('bool')) return 'bool';
  if (normalized.contains('double') || normalized.contains('float')) {
    return 'double';
  }
  if (normalized.contains('long')) return 'long';
  if (normalized.contains('int')) return 'int';
  return 'dynamic';
}

String _wrapPythonSource(String sourceCode, _FunctionSpec spec) {
  final runner =
      '''
import sys

def __judge_tokens():
    data = sys.stdin.read().strip().split()
    values = []
    for token in data:
        try:
            values.append(int(token))
        except Exception:
            try:
                values.append(float(token))
            except Exception:
                values.append(token)
    return values

if __name__ == '__main__':
    __values = __judge_tokens()
    __fn = ${spec.name}
    __argc = ${spec.parameters.length}
    __args = __values[:__argc]
    __result = __fn(*__args)
    if __result is not None:
        print(__result)
''';

  return '$sourceCode\n\n$runner';
}

String _wrapCppSource(String sourceCode, _FunctionSpec spec) {
  final args = _buildTypedArgumentList(spec.parameters, sourceStyle: 'cpp');
  final parser = _buildCppParser(spec.parameters);
  return '''
#include <bits/stdc++.h>
using namespace std;

$sourceCode

int main() {
$parser
    auto result = ${spec.name}($args);
    cout << result;
    return 0;
}
''';
}

String _wrapJavaSource(String sourceCode, _FunctionSpec spec) {
  final args = _buildTypedArgumentList(spec.parameters, sourceStyle: 'java');
  final parser = _buildJavaParser(spec.parameters);
  if (!sourceCode.contains('class ')) {
    return sourceCode;
  }

  final mainMethod =
      '''
    public static void main(String[] args) throws Exception {
$parser
        System.out.print(${spec.name}($args));
    }
''';

  final insertionPoint = sourceCode.lastIndexOf('}');
  if (insertionPoint == -1) return sourceCode;
  return '${sourceCode.substring(0, insertionPoint)}$mainMethod\n}';
}

String _wrapDartSource(String sourceCode, _FunctionSpec spec) {
  final args = _buildTypedArgumentList(spec.parameters, sourceStyle: 'dart');
  final parser = _buildDartParser(spec.parameters);
  return '''
import 'dart:io';

$sourceCode

void main(List<String> args) {
$parser
  final result = ${spec.name}($args);
  if (result != null) {
    print(result);
  }
}
''';
}

String _buildTypedArgumentList(
  List<_ParameterSpec> parameters, {
  required String sourceStyle,
}) {
  if (parameters.isEmpty) return '';

  return List.generate(
    parameters.length,
    (index) => _argumentName(index, sourceStyle),
  ).join(', ');
}

String _argumentName(int index, String sourceStyle) {
  switch (sourceStyle) {
    case 'cpp':
    case 'java':
    case 'dart':
      return 'arg${index + 1}';
    default:
      return 'arg${index + 1}';
  }
}

String _buildCppParser(List<_ParameterSpec> parameters) {
  final lines = <String>[
    '    ios::sync_with_stdio(false);',
    '    cin.tie(nullptr);',
  ];
  for (var i = 0; i < parameters.length; i++) {
    final name = 'arg${i + 1}';
    lines.add('    ${_cppType(parameters[i].type)} $name{};');
    lines.add('    cin >> $name;');
  }
  return lines.join('\n');
}

String _buildJavaParser(List<_ParameterSpec> parameters) {
  final lines = <String>[
    '        java.util.Scanner scanner = new java.util.Scanner(System.in);',
  ];
  for (var i = 0; i < parameters.length; i++) {
    final name = 'arg${i + 1}';
    lines.add(
      '        ${_javaType(parameters[i].type)} $name = ${_javaReadExpression(parameters[i].type)};',
    );
  }
  return lines.join('\n');
}

String _buildDartParser(List<_ParameterSpec> parameters) {
  final lines = <String>[
    '  final tokens = stdin.readAsStringSync().trim().split(RegExp(r"\\s+")).where((token) => token.isNotEmpty).toList();',
  ];
  for (var i = 0; i < parameters.length; i++) {
    final tokenExpr = 'tokens.length > $i ? tokens[$i] : ""';
    lines.add(
      '  final ${_dartVarType(parameters[i].type)} arg${i + 1} = ${_dartParseExpression(parameters[i].type, tokenExpr)};',
    );
  }
  return lines.join('\n');
}

String _cppType(String type) {
  switch (type) {
    case 'string':
      return 'string';
    case 'double':
      return 'double';
    case 'long':
      return 'long long';
    case 'bool':
      return 'bool';
    default:
      return 'int';
  }
}

String _javaType(String type) {
  switch (type) {
    case 'string':
      return 'String';
    case 'double':
      return 'double';
    case 'long':
      return 'long';
    case 'bool':
      return 'boolean';
    default:
      return 'int';
  }
}

String _javaReadExpression(String type) {
  switch (type) {
    case 'string':
      return 'scanner.next()';
    case 'double':
      return 'scanner.nextDouble()';
    case 'long':
      return 'scanner.nextLong()';
    case 'bool':
      return 'scanner.nextBoolean()';
    default:
      return 'scanner.nextInt()';
  }
}

String _dartVarType(String type) {
  switch (type) {
    case 'string':
      return 'String';
    case 'double':
      return 'double';
    case 'long':
    case 'int':
      return 'int';
    case 'bool':
      return 'bool';
    default:
      return 'dynamic';
  }
}

String _dartParseExpression(String type, String tokenExpr) {
  switch (type) {
    case 'string':
      return tokenExpr;
    case 'double':
      return 'double.parse($tokenExpr)';
    case 'long':
    case 'int':
      return 'int.parse($tokenExpr)';
    case 'bool':
      return '$tokenExpr.toLowerCase() == "true" || $tokenExpr == "1"';
    default:
      return tokenExpr;
  }
}
