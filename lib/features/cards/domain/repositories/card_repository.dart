import '../entities/card_entity.dart';

abstract class CardRepository {
  Future<List<CardEntity>> getCardsForReview({bool forceAll = false});
  Future<List<CardEntity>> getAllCards();
  Future<void> addCard(CardEntity card);
  Future<void> updateCard(CardEntity card);
  Future<void> deleteCard(int id);
}
