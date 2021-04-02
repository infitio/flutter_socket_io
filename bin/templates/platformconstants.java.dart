String $(Map<String, dynamic> c) => '''
package com.infitio.adharasocketio;


final public class PlatformConstants {

\tstatic final public class MethodChannelNames {
\t\t${c['channels'].map((_) => 'public static final String ${_['name']} = "${_['value']}";').join('\n\t\t')}
\t}

\tstatic final public class CodecTypes {
\t\t${c['types'].map((_) => 'public static final byte ${_['name']} = (byte) ${_['value']};').join('\n\t\t')}
\t}

\tstatic final public class PlatformMethod {
\t\t${c['methods'].map((_) => 'public static final String ${_['name']} = "${_['value']}";').join('\n\t\t')}
\t}

${c['objects'].map((_) => '''
\tstatic final public class Tx${_['name']} {
\t\t${_['properties'].map((_p) => 'public static final String $_p = "$_p";').join('\n\t\t')}
\t}
''').join('\n')}
}
''';
