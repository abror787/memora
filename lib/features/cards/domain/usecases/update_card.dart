import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';

class UpdateCard {
  final CardRepository repository;
  UpdateCard(this.repository);

  Future<void> call(CardEntity card) async {
    await repository.updateCard(card);
  }
}
