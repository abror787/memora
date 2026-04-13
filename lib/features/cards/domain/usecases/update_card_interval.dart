import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';

class UpdateCardInterval {
  final CardRepository repository;
  UpdateCardInterval(this.repository);

  Future<void> call(CardEntity card, bool isSuccess) async {
    int newInterval;
    int newSuccessCount = card.successCount;
    int newFailCount = card.failCount;

    if (isSuccess) {
      newInterval = (card.interval * 2).clamp(1, 30);
      newSuccessCount++;
    } else {
      newInterval = 1;
      newFailCount++;
    }

    final updatedCard = card.copyWith(
      interval: newInterval,
      nextReviewDate: DateTime.now().add(Duration(days: newInterval)),
      successCount: newSuccessCount,
      failCount: newFailCount,
    );

    await repository.updateCard(updatedCard);
  }
}
