import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final int? id;
  final String question;
  final String answer;
  final int interval;
  final DateTime nextReviewDate;
  final int successCount;
  final int failCount;

  const CardEntity({
    this.id,
    required this.question,
    required this.answer,
    required this.interval,
    required this.nextReviewDate,
    required this.successCount,
    required this.failCount,
  });

  CardEntity copyWith({
    int? id,
    String? question,
    String? answer,
    int? interval,
    DateTime? nextReviewDate,
    int? successCount,
    int? failCount,
  }) {
    return CardEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      successCount: successCount ?? this.successCount,
      failCount: failCount ?? this.failCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        question,
        answer,
        interval,
        nextReviewDate,
        successCount,
        failCount,
      ];
}
