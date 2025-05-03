import 'package:hive/hive.dart';

part 'HiveModel.g.dart';

@HiveType(typeId: 0)
class HiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime? date;

  @HiveField(5)
  final String permalink;



  HiveModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.date,
    required this.permalink,
  });

factory HiveModel.fromJson(Map<String, dynamic> json) {
  return HiveModel(
    id: json['id'] != null ? json['id'].toString() : 'unknown',  // Prevent null.toString() crash
    title: json['title'] ?? 'No Title',
    imageUrl: json['image'] ?? '',
    content: json['content'] ?? '',
    date: json['created_date'] != null && json['created_date'].toString().isNotEmpty
        ? DateTime.tryParse(json['created_date'].toString()) ?? DateTime(2000, 1, 1)  // Default date if parsing fails
        : null,  // Allow null if no valid date
    permalink: json['permalink']?.toString() ?? "None",  // Safe null check
  );
}


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "imageUrl": imageUrl,
      "content": content,
      "created_date": date,
      "permalink": permalink,

    };
  }
}