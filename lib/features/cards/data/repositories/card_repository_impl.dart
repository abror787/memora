import 'package:isar/isar.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final Isar? isar;

  CardRepositoryImpl(this.isar);

  @override
  Future<List<CardEntity>> getCardsForReview({bool forceAll = false}) async {
    if (isar == null) return [];
    final now = DateTime.now();

    List<CardModel> models;

    if (forceAll) {
      models = await isar!.cardModels.where().findAll();
    } else {
      models = await isar!.cardModels
          .filter()
          .nextReviewDateLessThan(now, include: true)
          .findAll();
    }

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CardEntity>> getAllCards() async {
    if (isar == null) return [];
    final models = await isar!.cardModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addCard(CardEntity card) async {
    if (isar == null) return;
    final model = CardModel.fromEntity(card);
    await isar!.writeTxn(() async {
      await isar!.cardModels.put(model);
    });
  }

  @override
  Future<void> updateCard(CardEntity card) async {
    if (isar == null) return;
    final model = CardModel.fromEntity(card);
    await isar!.writeTxn(() async {
      await isar!.cardModels.put(model);
    });
  }

  @override
  Future<void> deleteCard(int id) async {
    if (isar == null) return;
    await isar!.writeTxn(() async {
      await isar!.cardModels.delete(id);
    });
  }
}
