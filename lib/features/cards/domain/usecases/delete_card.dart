import '../repositories/card_repository.dart';

class DeleteCard {
  final CardRepository repository;
  DeleteCard(this.repository);

  Future<void> call(int id) async {
    await repository.deleteCard(id);
  }
}
