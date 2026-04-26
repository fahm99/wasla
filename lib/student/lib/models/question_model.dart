import 'answer_model.dart';

/// نموذج السؤال - يطابق جدول questions في قاعدة البيانات
/// Question Model - matches the questions table in the database
class QuestionModel {
  final String id;
  final String text;
  final String type;
  final int points;
  final int order;
  final String examId;
  final String? explanation;
  final String? imageUrl;
  final List<AnswerModel> answers;
  final DateTime? createdAt;

  QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.points,
    required this.order,
    required this.examId,
    this.explanation,
    this.imageUrl,
    this.answers = const [],
    this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      type: json['type']?.toString() ?? 'MULTIPLE_CHOICE',
      points: (json['points'] as int?) ?? 1,
      order: (json['order'] as int?) ?? 0,
      examId: json['exam_id']?.toString() ?? '',
      explanation: json['explanation']?.toString(),
      imageUrl: json['image_url']?.toString(),
      answers: json['answers'] != null
          ? (json['answers'] as List)
              .map((a) =>
                  AnswerModel.fromJson(Map<String, dynamic>.from(a as Map)))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
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
      'explanation': explanation,
      'image_url': imageUrl,
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
      explanation: explanation,
      imageUrl: imageUrl,
      answers: answers ?? this.answers,
      createdAt: createdAt,
    );
  }
}
