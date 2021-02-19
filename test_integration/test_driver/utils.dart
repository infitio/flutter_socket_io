import 'dart:io';

Future<String> getIP() async {
  for (final interface in await NetworkInterface.list()) {
    return (interface.addresses
                .firstWhere((address) => address.address.startsWith('192.')) ??
            interface.addresses
                .firstWhere((address) => address.address.startsWith('10.')))
        ?.address;
  }
  return null;
}
