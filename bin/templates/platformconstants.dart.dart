String getPrefix(Object? str, [Object? key]) {
  var overflow = false;
  if (key == null) {
    overflow = (str as String).length > 26;
  } else {
    overflow = (str as String).length + (key as String).length > 52;
  }
  return overflow ? '\n      ' : ' ';
}

String $(Map<String, dynamic> c) => '''
// ignore_for_file: public_member_api_docs

class MethodChannelNames {
${c['channels'].map((_) => "  static const String ${_['name']} =${getPrefix(_['value'], _['name'])}'${_['value']}';").join('\n')}
}

class CodecTypes {
${c['types'].map((_) => "  static const int ${_['name']} ="
        " ${_['value']};").join('\n')}
}

class PlatformMethod {
${c['methods'].map((_) => "  static const String ${_['name']} =${getPrefix(_['value'])}'${_['value']}';").join('\n')}
}

${c['objects'].map((_) => '''
class Tx${_['name']} {
${_['properties'].map((_p) => "  static const String $_p = '$_p';").join('\n')}
}
''').join('\n')}''';
