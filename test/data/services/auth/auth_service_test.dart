import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reeder/data/services/auth/auth_service.dart';
import 'package:reeder/data/services/sync/sync_models.dart';
import '../../../test_mocks.mocks.dart';

void main() {
  group('AuthService', () {
    late MockFlutterSecureStorage mockStorage;
    late AuthService authService;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      authService = AuthService(secureStorage: mockStorage);
    });

    group('saveCredentials()', () {
      test('should serialize and write to secure storage', () async {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedbin,
          username: 'user',
          password: 'pass',
        );

        when(mockStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async {});

        await authService.saveCredentials(1, credentials);

        verify(mockStorage.write(
          key: 'reeder_sync_1_credentials',
          value: argThat(
            allOf([
              contains('"serviceType":1'),
              contains('"username":"user"'),
              contains('"password":"pass"'),
            ]),
            named: 'value',
          ),
        )).called(1);
      });
    });

    group('getCredentials()', () {
      test('should read and deserialize from secure storage', () async {
        final json = jsonEncode({
          'serviceType': 1,
          'serverUrl': null,
          'username': 'user',
          'password': 'pass',
          'accessToken': null,
          'refreshToken': null,
          'tokenExpiresAt': null,
        });

        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => json);

        final result = await authService.getCredentials(1);

        expect(result, isNotNull);
        expect(result!.serviceType, SyncServiceType.feedbin);
        expect(result.username, 'user');
        expect(result.password, 'pass');
      });

      test('should return null when key does not exist', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        final result = await authService.getCredentials(999);

        expect(result, isNull);
      });

      test('should return null when JSON parsing fails', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => 'invalid json');

        final result = await authService.getCredentials(1);

        expect(result, isNull);
      });
    });

    group('deleteCredentials()', () {
      test('should call secure storage delete', () async {
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        await authService.deleteCredentials(1);

        verify(mockStorage.delete(key: 'reeder_sync_1_credentials')).called(1);
      });
    });

    group('updateTokens()', () {
      test('should update OAuth tokens', () async {
        final existingCredentials = SyncCredentials(
          serviceType: SyncServiceType.feedly,
          username: 'user',
        );

        final json = jsonEncode({
          'serviceType': 2,
          'serverUrl': null,
          'username': 'user',
          'password': null,
          'accessToken': null,
          'refreshToken': null,
          'tokenExpiresAt': null,
        });

        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => json);
        when(mockStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async {});

        await authService.updateTokens(
          1,
          accessToken: 'new_token',
          refreshToken: 'new_refresh',
        );

        verify(mockStorage.write(
          key: 'reeder_sync_1_credentials',
          value: argThat(
            contains('"accessToken":"new_token"'),
            named: 'value',
          ),
        )).called(1);
      });

      test('should throw StateError when no existing credentials', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        expect(
          () => authService.updateTokens(1, accessToken: 'token'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('hasCredentials()', () {
      test('should return true when credentials exist', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => '{}');

        final result = await authService.hasCredentials(1);

        expect(result, isTrue);
      });

      test('should return false when credentials do not exist', () async {
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);

        final result = await authService.hasCredentials(1);

        expect(result, isFalse);
      });
    });

    group('deleteAllCredentials()', () {
      test('should only delete keys with reeder_sync_ prefix', () async {
        final allKeys = <String, String>{
          'reeder_sync_1_credentials': '{}',
          'reeder_sync_2_credentials': '{}',
          'other_key': 'value',
          'another_key': 'value',
        };

        when(mockStorage.readAll()).thenAnswer((_) async => allKeys);
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        await authService.deleteAllCredentials();

        verify(mockStorage.delete(key: 'reeder_sync_1_credentials')).called(1);
        verify(mockStorage.delete(key: 'reeder_sync_2_credentials')).called(1);
        verifyNever(mockStorage.delete(key: 'other_key'));
        verifyNever(mockStorage.delete(key: 'another_key'));
      });
    });
  });
}
