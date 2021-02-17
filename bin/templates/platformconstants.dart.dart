String getPrefix(Object str) =>
    ((str as String).length > 26) ? '\n      ' : ' ';

String $(Map<String, dynamic> c) => '''
// ignore_for_file: public_member_api_docs

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
