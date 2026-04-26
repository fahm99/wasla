/// نموذج الإجابة - يطابق جدول answers في قاعدة البيانات
/// Answer Model - matches the answers table in the database
class AnswerModel {
  final String id;
  final String text;
  final bool isCorrect;
  final String questionId;

  AnswerModel({
    required this.id,
    required this.text,
    this.isCorrect = false,
    required this.questionId,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      questionId: json['question_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_correct': isCorrect,
      'question_id': questionId,
    };
  }

  AnswerModel copyWith({
    String? text,
    bool? isCorrect,
  }) {
    return AnswerModel(
      id: id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
      questionId: questionId,
    );
  }
}
