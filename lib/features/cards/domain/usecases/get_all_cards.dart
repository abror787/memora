import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';

class GetAllCards {
  final CardRepository repository;
  GetAllCards(this.repository);

  Future<List<CardEntity>> call() async {
    return await repository.getAllCards();
  }
}
