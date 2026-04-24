class QuestionModel {
  final String id;
  final String examId;
  final String questionText;
  final String questionType;
  final List<String>? options;
  final String? correctAnswer;
  final int points;
  final int order;
  final DateTime createdAt;

  // Getters for compatibility
  String get text => questionText;
  String get type => questionType;
  String? get imageUrl => null; // Add if you have image support
  List<dynamic> get answers =>
      options?.map((opt) => {'id': opt, 'text': opt}).toList() ?? [];

  QuestionModel({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.questionType,
    this.options,
    this.correctAnswer,
    required this.points,
    required this.order,
    required this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      correctAnswer: json['correct_answer'] as String?,
      points: json['points'] as int,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'question_text': questionText,
      'question_type': questionType,
      'options': options,
      'correct_answer': correctAnswer,
      'points': points,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
