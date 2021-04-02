import 'dart:io';

import 'codegencontext.dart' show context;
import 'templates/platformconstants.dart.dart' as dart_template;
import 'templates/platformconstants.java.dart' as java_template;
import 'templates/platformconstants.swift.dart' as swift_template;

typedef Template = String Function(Map<String, dynamic> context);

const String projectRoot = '../';

Map<Template, String> toGenerate = {
  // input template method vs output file path
  dart_template.$: '${projectRoot}lib/generated/platform_constants.dart',
  java_template.$:
      '${projectRoot}android/src/main/java/com/infitio/adharasocketio/PlatformConstants.java',
  swift_template.$:
      '${projectRoot}ios/Classes/codec/AdharaSocketIoPlatformConstants.swift',
};

void main() {
  for (final entry in toGenerate.entries) {
    final source = entry.key(context).replaceAll(RegExp(r'\t'), '    ');
    File(entry.value).writeAsStringSync('''
//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

$source''');
    // ignore: avoid_print
    print('File written: ${entry.value} ✔');
  }
}
