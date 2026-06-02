import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/config/share_link_config.dart';

void main() {
  test('custom URL format', () {
    expect(
      ShareLinkConfig.prestataireProfileCustomUrl(
        '11111111-1111-1111-1111-111111111111',
      ),
      'com.madbeauty.madbeauty://prestataire/11111111-1111-1111-1111-111111111111',
    );
  });
}
