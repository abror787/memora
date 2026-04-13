import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';

class GetCardsForReview {
  final CardRepository repository;
  GetCardsForReview(this.repository);

  Future<List<CardEntity>> call({bool forceAll = false}) async {
    return await repository.getCardsForReview(forceAll: forceAll);
  }
}
