import 'package:flutter_test/flutter_test.dart';
import 'package:jebol_mobile/core/hardening/safe_json.dart';

void main() {
  group('SafeJson', () {
    group('tryParse', () {
      test('parses valid JSON object', () {
        final result = SafeJson.tryParse('{"key": "value"}');
        expect(result, isNotNull);
        expect(result!['key'], equals('value'));
      });

      test('returns null for invalid JSON', () {
        final result = SafeJson.tryParse('not valid json');
        expect(result, isNull);
      });

      test('returns null for null input', () {
        final result = SafeJson.tryParse(null);
        expect(result, isNull);
      });

      test('returns null for empty string', () {
        final result = SafeJson.tryParse('');
        expect(result, isNull);
      });

      test('returns null for JSON array (not object)', () {
        final result = SafeJson.tryParse('[1, 2, 3]');
        expect(result, isNull);
      });
    });

    group('tryParseList', () {
      test('parses valid JSON array', () {
        final result = SafeJson.tryParseList('[1, 2, 3]');
        expect(result, equals([1, 2, 3]));
      });

      test('returns empty list for invalid JSON', () {
        final result = SafeJson.tryParseList('not valid');
        expect(result, isEmpty);
      });

      test('returns empty list for null', () {
        final result = SafeJson.tryParseList(null);
        expect(result, isEmpty);
      });

      test('returns empty list for JSON object (not array)', () {
        final result = SafeJson.tryParseList('{"key": "value"}');
        expect(result, isEmpty);
      });
    });

    group('getString', () {
      test('returns string value', () {
        final map = {'name': 'John'};
        expect(SafeJson.getString(map, 'name'), equals('John'));
      });

      test('returns default for missing key', () {
        final map = {'name': 'John'};
        expect(
          SafeJson.getString(map, 'age', defaultValue: 'unknown'),
          equals('unknown'),
        );
      });

      test('returns default for null map', () {
        expect(
          SafeJson.getString(null, 'name', defaultValue: 'default'),
          equals('default'),
        );
      });

      test('converts non-string to string', () {
        final map = {'count': 42};
        expect(SafeJson.getString(map, 'count'), equals('42'));
      });
    });

    group('getInt', () {
      test('returns int value', () {
        final map = {'count': 42};
        expect(SafeJson.getInt(map, 'count'), equals(42));
      });

      test('returns default for missing key', () {
        final map = {'count': 42};
        expect(SafeJson.getInt(map, 'age', defaultValue: -1), equals(-1));
      });

      test('converts double to int', () {
        final map = {'value': 3.7};
        expect(SafeJson.getInt(map, 'value'), equals(3));
      });

      test('parses string to int', () {
        final map = {'value': '123'};
        expect(SafeJson.getInt(map, 'value'), equals(123));
      });

      test('returns default for invalid string', () {
        final map = {'value': 'not a number'};
        expect(SafeJson.getInt(map, 'value', defaultValue: -1), equals(-1));
      });
    });

    group('getDouble', () {
      test('returns double value', () {
        final map = {'price': 9.99};
        expect(SafeJson.getDouble(map, 'price'), equals(9.99));
      });

      test('converts int to double', () {
        final map = {'value': 42};
        expect(SafeJson.getDouble(map, 'value'), equals(42.0));
      });

      test('parses string to double', () {
        final map = {'value': '3.14'};
        expect(SafeJson.getDouble(map, 'value'), equals(3.14));
      });
    });

    group('getBool', () {
      test('returns bool value', () {
        final map = {'active': true};
        expect(SafeJson.getBool(map, 'active'), isTrue);
      });

      test('converts int 1 to true', () {
        final map = {'active': 1};
        expect(SafeJson.getBool(map, 'active'), isTrue);
      });

      test('converts int 0 to false', () {
        final map = {'active': 0};
        expect(SafeJson.getBool(map, 'active'), isFalse);
      });

      test('converts string true to true', () {
        final map = {'active': 'true'};
        expect(SafeJson.getBool(map, 'active'), isTrue);
      });

      test('converts string TRUE to true', () {
        final map = {'active': 'TRUE'};
        expect(SafeJson.getBool(map, 'active'), isTrue);
      });

      test('converts string 1 to true', () {
        final map = {'active': '1'};
        expect(SafeJson.getBool(map, 'active'), isTrue);
      });
    });

    group('getMap', () {
      test('returns nested map', () {
        final map = {
          'user': {'name': 'John', 'age': 30},
        };
        final user = SafeJson.getMap(map, 'user');
        expect(user, isNotNull);
        expect(user!['name'], equals('John'));
      });

      test('returns null for non-map value', () {
        final map = {'user': 'not a map'};
        expect(SafeJson.getMap(map, 'user'), isNull);
      });
    });
  });

  group('ApiResponseValidator', () {
    group('validate', () {
      test('returns valid for proper response', () {
        final response = {'success': true, 'data': {}};
        final result = ApiResponseValidator.validate(response);
        expect(result.isValid, isTrue);
      });

      test('returns invalid for null response', () {
        final result = ApiResponseValidator.validate(null);
        expect(result.isValid, isFalse);
        expect(result.error, equals('Response is null'));
      });

      test('detects missing required fields', () {
        final response = {'success': true};
        final result = ApiResponseValidator.validate(
          response,
          requiredFields: ['data', 'message'],
        );
        expect(result.isValid, isFalse);
        expect(result.missingFields, contains('data'));
      });
    });

    group('isSuccess', () {
      test('returns true for success: true', () {
        expect(ApiResponseValidator.isSuccess({'success': true}), isTrue);
      });

      test('returns false for success: false', () {
        expect(ApiResponseValidator.isSuccess({'success': false}), isFalse);
      });

      test('returns true for status: success', () {
        expect(ApiResponseValidator.isSuccess({'status': 'success'}), isTrue);
      });

      test('returns true for code: 200', () {
        expect(ApiResponseValidator.isSuccess({'code': 200}), isTrue);
      });

      test('returns false when error field present', () {
        expect(
          ApiResponseValidator.isSuccess({'error': 'Something went wrong'}),
          isFalse,
        );
      });

      test('returns false for null response', () {
        expect(ApiResponseValidator.isSuccess(null), isFalse);
      });
    });

    group('getErrorMessage', () {
      test('returns message field', () {
        final response = {'message': 'Error occurred'};
        expect(
          ApiResponseValidator.getErrorMessage(response),
          equals('Error occurred'),
        );
      });

      test('returns error field', () {
        final response = {'error': 'Something went wrong'};
        expect(
          ApiResponseValidator.getErrorMessage(response),
          equals('Something went wrong'),
        );
      });

      test('returns first validation error', () {
        final response = {
          'errors': {
            'email': ['Email tidak valid', 'Email sudah digunakan'],
          },
        };
        expect(
          ApiResponseValidator.getErrorMessage(response),
          equals('Email tidak valid'),
        );
      });

      test('returns default message for null response', () {
        expect(
          ApiResponseValidator.getErrorMessage(null, defaultMessage: 'Default'),
          equals('Default'),
        );
      });
    });
  });
}
