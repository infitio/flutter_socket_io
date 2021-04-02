String $(Map<String, dynamic> c) => '''
public class AdharaSocketIoMethodChannelNames {
${c['channels'].map((_) => '\tpublic static let ${_['name']} = "${_['value']}";').join('\n')}
}

public class CodecTypes {
${c['types'].map((_) => '\tpublic static let ${_['name']} = ${_['value']};').join('\n')}
}

public class AdharaSocketIoPlatformMethod {
${c['methods'].map((_) => '\tpublic static let ${_['name']} = "${_['value']}";').join('\n')}
}

${c['objects'].map((_) => '''
public class Tx${_['name']} {
${_['properties'].map((name) => '\tpublic static let $name = "$name";').join('\n')}
}
''').join('\n')}''';
