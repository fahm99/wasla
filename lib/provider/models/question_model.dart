import 'answer_model.dart';

class QuestionModel {
  final String id;
  final String text;
  final String type;
  final int points;
  final int order;
  final String examId;
  final List<AnswerModel> answers;
  final DateTime? createdAt;

  QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.points,
    required this.order,
    required this.examId,
    this.answers = const [],
    this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      type: json['type'] ?? 'اختيار متعدد',
      points: json['points'] ?? 1,
      order: json['order'] ?? 0,
      examId: json['exam_id'] ?? '',
      answers: json['answers'] != null
          ? (json['answers'] as List)
              .map((a) => AnswerModel.fromJson(a))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'points': points,
      'order': order,
      'exam_id': examId,
    };
  }

  QuestionModel copyWith({
    String? text,
    String? type,
    int? points,
    int? order,
    List<AnswerModel>? answers,
  }) {
    return QuestionModel(
      id: id,
      text: text ?? this.text,
      type: type ?? this.type,
      points: points ?? this.points,
      order: order ?? this.order,
      examId: examId,
      answers: answers ?? this.answers,
      createdAt: createdAt,
    );
  }
}
