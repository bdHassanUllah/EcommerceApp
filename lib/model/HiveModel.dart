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



  HiveModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  factory HiveModel.fromJson(Map<String, dynamic> json) {
    return HiveModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'No Title',
      imageUrl: json['image'] ?? '',
      content: json['content'] ?? '',
      /*date: json['date'] != null
          ? DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json['date'].toString()).toIso8601String()
          : DateTime.now().toIso8601String(),*/
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "imageUrl": imageUrl,
      "content": content,

    };
  }
}
