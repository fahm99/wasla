class AnswerModel {
  final String id;
  final String questionId;
  final String examId;
  final String userId;
  final String? selectedOption;
  final String? textAnswer;
  final DateTime createdAt;

  AnswerModel({
    required this.id,
    required this.questionId,
    required this.examId,
    required this.userId,
    this.selectedOption,
    this.textAnswer,
    required this.createdAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      examId: json['exam_id'] as String,
      userId: json['user_id'] as String,
      selectedOption: json['selected_option'] as String?,
      textAnswer: json['text_answer'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'exam_id': examId,
      'user_id': userId,
      'selected_option': selectedOption,
      'text_answer': textAnswer,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
