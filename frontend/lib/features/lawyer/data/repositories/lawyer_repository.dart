import '../datasources/lawyer_remote_datasource.dart';
import '../../domain/entities/lawyer_entity.dart';

class LawyerRepository {
  final LawyerRemoteDataSource remoteDataSource;

  LawyerRepository({required this.remoteDataSource});

  Future<List<LawyerEntity>> searchLawyers({
    String? q,
    String? specialization,
    double? minRating,
    int page = 1,
    int pageSize = 20,
  }) async {
    final list = await remoteDataSource.searchLawyers(
      q: q,
      specialization: specialization,
      minRating: minRating,
      page: page,
      pageSize: pageSize,
    );
    return list;
  }
}
