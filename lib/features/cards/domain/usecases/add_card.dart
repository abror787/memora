import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';

class AddCard {
  final CardRepository repository;
  AddCard(this.repository);

  Future<void> call(String question, String answer) async {
    final card = CardEntity(
      question: question,
      answer: answer,
      interval: 1,
      nextReviewDate: DateTime.now(),
      successCount: 0,
      failCount: 0,
    );
    await repository.addCard(card);
  }
}
