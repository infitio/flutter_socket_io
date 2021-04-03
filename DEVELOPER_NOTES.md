### Developing integration tests

Integration tests use flutter driver to connect your CLI to emulator/physical device.
 Once the connection is established, cli will execute specific commands on the device
 based on the code in `test_integration/test_driver`

To add new tests,

1. add test in `test_integration/lib/test/` folder (can be added to an existing file too)
2. add test names in `test_integration/lib/config/test_names.dart`
3. and link test names to test created in (1) in `test_integration/lib/config/test_factory.dart`
