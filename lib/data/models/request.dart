import 'package:hive/hive.dart';


@HiveType(typeId: 3)
class EmergencyRequest extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int patientId;
  @HiveField(2)
  final int? doctorId;
  @HiveField(3)
  final String status; // pending/accepted/completed
  @HiveField(4)
  final String? notes;

  EmergencyRequest({required this.id, required this.patientId, this.doctorId, required this.status, this.notes});

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) => EmergencyRequest(
        id: (json['id'] as num).toInt(),
        patientId: (json['patient_id'] as num).toInt(),
        doctorId: (json['doctor_id'] as num?)?.toInt(),
        status: json['status']?.toString() ?? 'pending',
        notes: json['notes']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'status': status,
        'notes': notes,
      };
}

class EmergencyRequestAdapter extends TypeAdapter<EmergencyRequest> {
  @override
  final int typeId = 3;

  @override
  EmergencyRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return EmergencyRequest(
      id: fields[0] as int,
      patientId: fields[1] as int,
      doctorId: fields[2] as int?,
      status: fields[3] as String,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyRequest obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.doctorId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.notes);
  }
}
