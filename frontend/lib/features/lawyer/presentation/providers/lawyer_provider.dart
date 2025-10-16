import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/lawyer_remote_datasource.dart';
import '../../data/repositories/lawyer_repository.dart';
import '../../domain/entities/lawyer_entity.dart';

class LawyerListState {
  final List<LawyerEntity> lawyers;
  final bool isLoading;
  final String? error;

  LawyerListState({this.lawyers = const [], this.isLoading = false, this.error});

  LawyerListState copyWith({List<LawyerEntity>? lawyers, bool? isLoading, String? error}) {
    return LawyerListState(
      lawyers: lawyers ?? this.lawyers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LawyerListNotifier extends StateNotifier<LawyerListState> {
  final LawyerRepository repository;

  LawyerListNotifier(this.repository) : super(LawyerListState());

  Future<void> search({String? q, String? specialization, double? minRating}) async {
    // normalize inputs
    final normalizedQ = q?.trim().isEmpty ?? true ? null : q?.trim();
    final normalizedSpec = specialization?.trim().isEmpty ?? true ? null : specialization?.trim();

    // Debug: print search parameters
    // ignore: avoid_print
    print('LawyerListNotifier.search called with q=$normalizedQ specialization=$normalizedSpec minRating=$minRating');

    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await repository.searchLawyers(q: normalizedQ, specialization: normalizedSpec, minRating: minRating);
      state = state.copyWith(lawyers: res, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final lawyerRemoteDataSourceProvider = Provider<LawyerRemoteDataSource>((ref) => LawyerRemoteDataSource(apiClient: ref.watch(apiClientProvider)));

final lawyerRepositoryProvider = Provider<LawyerRepository>((ref) => LawyerRepository(remoteDataSource: ref.watch(lawyerRemoteDataSourceProvider)));

final lawyerListNotifierProvider = StateNotifierProvider<LawyerListNotifier, LawyerListState>((ref) => LawyerListNotifier(ref.watch(lawyerRepositoryProvider)));

final lawyerDetailProvider = FutureProvider.family<LawyerEntity?, String>((ref, id) async {
  final repo = ref.watch(lawyerRepositoryProvider);
  return await repo.getLawyerById(id);
});

final lawyerSpecializationsProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final ds = LawyerRemoteDataSource(apiClient: api);
  final response = await ds.apiClient.get('/lawyers/specializations');
  final raw = response['data'] as List<dynamic>? ?? [];
  return raw.map((e) => e.toString()).toList();
});
