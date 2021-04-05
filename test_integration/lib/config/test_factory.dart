import '../factory/reporter.dart';
import '../test/basic_test.dart';
import '../test/echo_test.dart';
import '../test/events_test.dart';
import '../test/publish_test.dart';
import '../test/publish_with_ack_test.dart';
import 'test_names.dart';

typedef TestFactory = Future<Map<String, dynamic>> Function({
  Reporter reporter,
  Map<String, dynamic> payload,
});

final testFactory = <String, TestFactory>{
  TestName.basic: basicTest,
  TestName.listen: listenTest,
  TestName.events: eventsTest,
  TestName.publish: publishTest,
  TestName.echo: echoTest,
  TestName.ack: publishWithACKTest,
};
