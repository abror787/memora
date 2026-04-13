import 'package:isar/isar.dart';
import '../../domain/entities/card_entity.dart';

part 'card_model.g.dart';

@collection
class CardModel {
  Id id = Isar.autoIncrement;

  late String question;
  late String answer;
  late int interval;           // дни до следующего повторения
  late DateTime nextReviewDate;
  late int successCount;
  late int failCount;

  // Маппинг из Entity в Model
  static CardModel fromEntity(CardEntity entity) {
    final model = CardModel()
      ..question = entity.question
      ..answer = entity.answer
      ..interval = entity.interval
      ..nextReviewDate = entity.nextReviewDate
      ..successCount = entity.successCount
      ..failCount = entity.failCount;
    
    if (entity.id != null) {
      model.id = entity.id!;
    }
    
    return model;
  }

  // Маппинг из Model в Entity
  CardEntity toEntity() {
    return CardEntity(
      id: id,
      question: question,
      answer: answer,
      interval: interval,
      nextReviewDate: nextReviewDate,
      successCount: successCount,
      failCount: failCount,
    );
  }
}
