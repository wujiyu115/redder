import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/repositories/sync_repository.dart';
import 'package:reeder/data/services/sync/sync_models.dart';
import '../../test_mocks.mocks.dart';

void main() {
  group('SyncRepository', () {
    late MockSyncLocalDataSource mockLocalDs;
    late MockAuthService mockAuthService;
    late SyncRepository repository;

    setUp(() {
      mockLocalDs = MockSyncLocalDataSource();
      mockAuthService = MockAuthService();
      repository = SyncRepository(
        localDs: mockLocalDs,
        authService: mockAuthService,
      );
    });

    group('getAccounts()', () {
      test('should correctly convert SyncAccount to SyncAccountInfo', () async {
        final accounts = [
          SyncAccount(
            id: 1,
            serviceType: 1,
            serverUrl: null,
            username: 'test@example.com',
            isActive: true,
            lastSyncAt: null,
            syncState: null,
            createdAt: DateTime(2024, 1, 1),
          ),
          SyncAccount(
            id: 2,
            serviceType: 2,
            serverUrl: null,
            username: 'user2@example.com',
            isActive: false,
            lastSyncAt: DateTime(2024, 1, 2),
            syncState: null,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(mockLocalDs.getAllAccounts()).thenAnswer((_) async => accounts);

        final result = await repository.getAccounts();

        expect(result, hasLength(2));
        expect(result[0].id, 1);
        expect(result[0].serviceType, SyncServiceType.feedbin);
        expect(result[0].username, 'test@example.com');
        expect(result[0].isActive, isTrue);
        expect(result[1].id, 2);
        expect(result[1].serviceType, SyncServiceType.feedly);
        expect(result[1].username, 'user2@example.com');
        expect(result[1].isActive, isFalse);
      });
    });

    group('getActiveAccount()', () {
      test('should return SyncAccountInfo when active account exists', () async {
        final account = SyncAccount(
          id: 1,
          serviceType: 1,
          serverUrl: null,
          username: 'test@example.com',
          isActive: true,
          lastSyncAt: null,
          syncState: null,
          createdAt: DateTime(2024, 1, 1),
        );

        when(mockLocalDs.getActiveAccount()).thenAnswer((_) async => account);

        final result = await repository.getActiveAccount();

        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.serviceType, SyncServiceType.feedbin);
        expect(result.username, 'test@example.com');
        expect(result.isActive, isTrue);
      });

      test('should return null when no active account exists', () async {
        when(mockLocalDs.getActiveAccount()).thenAnswer((_) async => null);

        final result = await repository.getActiveAccount();

        expect(result, isNull);
      });
    });

    group('addAccount()', () {
      test('should call upsertAccount', () async {
        when(mockLocalDs.upsertAccount(any))
            .thenAnswer((_) async => 1);

        final result = await repository.addAccount(
          SyncServiceType.feedbin,
          username: 'test@example.com',
        );

        expect(result, 1);
        verify(mockLocalDs.upsertAccount(any)).called(1);
      });
    });

    group('removeAccount()', () {
      test('should delete credentials first then delete account', () async {
        when(mockAuthService.deleteCredentials(any))
            .thenAnswer((_) async {});
        when(mockLocalDs.deleteAccount(any))
            .thenAnswer((_) async => true);

        await repository.removeAccount(1);

        verifyInOrder([
          mockAuthService.deleteCredentials(1),
          mockLocalDs.deleteAccount(1),
        ]);
      });
    });

    group('setActiveAccount()', () {
      test('should call localDs.setActiveAccount', () async {
        when(mockLocalDs.setActiveAccount(any))
            .thenAnswer((_) async {});

        await repository.setActiveAccount(1);

        verify(mockLocalDs.setActiveAccount(1)).called(1);
      });
    });

    group('updateLastSyncAt()', () {
      test('should get account then update sync time', () async {
        final account = SyncAccount(
          id: 1,
          serviceType: 1,
          serverUrl: null,
          username: 'test@example.com',
          isActive: true,
          lastSyncAt: null,
          syncState: null,
          createdAt: DateTime(2024, 1, 1),
        );

        when(mockLocalDs.getAccountById(1)).thenAnswer((_) async => account);
        when(mockLocalDs.upsertAccount(any))
            .thenAnswer((_) async => 1);

        await repository.updateLastSyncAt(1);

        verify(mockLocalDs.getAccountById(1)).called(1);
        verify(mockLocalDs.upsertAccount(any)).called(1);
      });
    });

    group('getAccountById()', () {
      test('should return SyncAccountInfo when account exists', () async {
        final account = SyncAccount(
          id: 1,
          serviceType: 1,
          serverUrl: null,
          username: 'test@example.com',
          isActive: true,
          lastSyncAt: null,
          syncState: null,
          createdAt: DateTime(2024, 1, 1),
        );

        when(mockLocalDs.getAccountById(1)).thenAnswer((_) async => account);

        final result = await repository.getAccountById(1);

        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.serviceType, SyncServiceType.feedbin);
        expect(result.username, 'test@example.com');
      });

      test('should return null when account does not exist', () async {
        when(mockLocalDs.getAccountById(999)).thenAnswer((_) async => null);

        final result = await repository.getAccountById(999);

        expect(result, isNull);
      });
    });

    group('updateAccount()', () {
      SyncAccount existing() => SyncAccount(
            id: 1,
            serviceType: 3,
            serverUrl: 'https://old.example.com',
            username: 'olduser',
            isActive: true,
            lastSyncAt: DateTime(2024, 1, 2),
            syncState: null,
            createdAt: DateTime(2024, 1, 1),
          );

      test('preserves username when only serverUrl is updated (regression)',
          () async {
        when(mockLocalDs.getAccountById(1))
            .thenAnswer((_) async => existing());
        when(mockLocalDs.upsertAccount(any)).thenAnswer((_) async => 1);

        await repository.updateAccount(1, serverUrl: 'https://new.example.com');

        final captured = verify(mockLocalDs.upsertAccount(captureAny))
            .captured
            .single as SyncAccountsCompanion;
        expect(captured.serverUrl.value, 'https://new.example.com');
        // Previously username would be clobbered to null here.
        expect(captured.username.value, 'olduser');
      });

      test('preserves serverUrl when only username is updated (regression)',
          () async {
        when(mockLocalDs.getAccountById(1))
            .thenAnswer((_) async => existing());
        when(mockLocalDs.upsertAccount(any)).thenAnswer((_) async => 1);

        await repository.updateAccount(1, username: 'newuser');

        final captured = verify(mockLocalDs.upsertAccount(captureAny))
            .captured
            .single as SyncAccountsCompanion;
        expect(captured.username.value, 'newuser');
        expect(captured.serverUrl.value, 'https://old.example.com');
      });

      test('throws StateError when the account does not exist', () async {
        when(mockLocalDs.getAccountById(42)).thenAnswer((_) async => null);

        expect(
          () => repository.updateAccount(42, username: 'x'),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}