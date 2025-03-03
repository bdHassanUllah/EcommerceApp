import 'package:hive/hive.dart';

part 'hive_model.g.dart'; // Generated file

@HiveType(typeId: 0)
class HiveModel extends HiveObject { // Rename class to HiveModel
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String imageUrl;

  @HiveField(3)
  late String content;

  HiveModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
  });
}