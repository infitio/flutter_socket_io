import '../test/basic_test.dart';
import '../test/echo_test.dart';
import '../test/events_test.dart';
import '../test/publish_test.dart';
import '../test_dispatcher.dart';
import 'test_names.dart';

final testFactory = <String, TestFactory>{
  TestName.basic: basicTest,
  TestName.connect: connectTest,
  TestName.events: eventsTest,
  TestName.publish: publishTest,
  TestName.echo: echoTest,
  // TestName.ack:
  // TestName.namespace:
};
