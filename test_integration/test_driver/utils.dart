import 'dart:io';

Future<String> getIP() async {
  print('addresses:: ${NetworkInterface.list()}');

  for (final interface in await NetworkInterface.list()) {
    return (interface.addresses
                .firstWhere((address) => address.address.startsWith('192.')) ??
            interface.addresses
                .firstWhere((address) => address.address.startsWith('10.')))
        ?.address;
  }
  return null;
}
