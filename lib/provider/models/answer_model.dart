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
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      questionId: json['question_id'] ?? '',
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
