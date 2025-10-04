import 'package:hive/hive.dart';


@HiveType(typeId: 5)
class Review extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int doctorId;
  @HiveField(2)
  final int patientId;
  @HiveField(3)
  final int rating; // 1..5
  @HiveField(4)
  final String? comment;

   Review({required this.id, required this.doctorId, required this.patientId, required this.rating, this.comment});

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: (json['id'] as num).toInt(),
        doctorId: (json['doctor_id'] as num).toInt(),
        patientId: (json['patient_id'] as num).toInt(),
        rating: (json['rating'] as num).toInt(),
        comment: json['comment']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctor_id': doctorId,
        'patient_id': patientId,
        'rating': rating,
        'comment': comment,
      };
}

class ReviewAdapter extends TypeAdapter<Review> {
  @override
  final int typeId = 5;

  @override
  Review read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Review(
      id: fields[0] as int,
      doctorId: fields[1] as int,
      patientId: fields[2] as int,
      rating: fields[3] as int,
      comment: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Review obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.doctorId)
      ..writeByte(2)
      ..write(obj.patientId)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.comment);
  }
}
