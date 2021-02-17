String $(Map<String, dynamic> c) => '''
@import Foundation;

typedef NS_ENUM(UInt8, _Value) {
\t${c['types'].map((_) => '${_['name']}CodecType = ${_['value']},').join('\n\t')}
};


@interface AdharaSocketIoPlatformMethod : NSObject
${c['methods'].map((_) => 'extern NSString *const AdharaSocketIoPlatformMethod_${_['name']};').join('\n')}
@end

${c['objects'].map((_) => '''
@interface Tx${_['name']} : NSObject
${_['properties'].map((name) => 'extern NSString *const Tx${_['name']}_$name;').join('\n')}
@end
''').join('\n')}''';
