String $(Map<String, dynamic> c) => '''
#import "AdharaSocketIoPlatformConstants.h"


@implementation AdharaSocketIoPlatformMethod
${c['methods'].map((_) => 'NSString *const AdharaSocketIoPlatformMethod_${_['name']}= @"${_['value']}";').join('\n')}
@end

${c['objects'].map((_) => '''
@implementation Tx${_['name']}
${_['properties'].map((name) => 'NSString *const Tx${_['name']}_$name = @"$name";').join('\n')}
@end
''').join('\n')}''';
