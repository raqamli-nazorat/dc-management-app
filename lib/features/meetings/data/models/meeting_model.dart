import '../../domain/entities/meeting.dart';

/// [Meeting] JSON serializatsiyasi (`/meetings/`).
///
/// Backend kontrakti to‘liq aniq emas — `project` va `organizer` int (id) yoki
/// ichma-ich (nested) obyekt bo‘lishi mumkin, shu bois har ikkisi ham bardoshli
/// o‘qiladi. `attended` — `meeting_attendance` ro‘yxatidan (agar berilgan
/// `currentUserId`ga mos yozuv topilsa) yoki tekis `attended`/`is_attended`
/// maydonidan olinadi.
class MeetingModel extends Meeting {
  const MeetingModel({
    required super.id,
    required super.title,
    required super.uid,
    required super.projectName,
    required super.startDate,
    required super.organizerName,
    required super.organizerRole,
    required super.participantName,
    required super.participantPosition,
    required super.isCompleted,
    required super.reason,
    required super.attended,
  });

  factory MeetingModel.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    String str(dynamic v) => v?.toString() ?? '';

    String pick(List<String> keys, [Map<String, dynamic>? src]) {
      final map = src ?? json;
      for (final k in keys) {
        final v = map[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return '';
    }

    int? intValue(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // ── Project nomi: nested {name/title} yoki tekis project_name ──────────
    String projectName() {
      final p = json['project'];
      if (p is Map) return pick(['name', 'title'], p.cast<String, dynamic>());
      return pick(['project_name', 'project_title']);
    }

    // ── Organizer: nested {full_name/username, role/position} ──────────────
    final organizer = json['organizer'];
    final orgMap = organizer is Map
        ? organizer.cast<String, dynamic>()
        : const {};
    final organizerName = orgMap.isNotEmpty
        ? pick([
            'full_name',
            'name',
            'username',
          ], orgMap.cast<String, dynamic>())
        : pick(['organizer_name']);
    final organizerRole = orgMap.isNotEmpty
        ? pick([
            'role',
            'active_role',
            'position',
          ], orgMap.cast<String, dynamic>())
        : pick(['organizer_role']);

    final organizerId = orgMap.isNotEmpty
        ? intValue(orgMap['id'])
        : intValue(organizer);

    Map<String, dynamic> organizerParticipantInfo() {
      final participants = json['participants_info'];
      if (participants is List) {
        for (final participant in participants) {
          if (participant is! Map) continue;
          final participantMap = participant.cast<String, dynamic>();
          if (intValue(participantMap['id']) == organizerId) {
            return participantMap;
          }
        }
      }
      return const <String, dynamic>{};
    }

    final participantMap = organizerParticipantInfo();
    final participantName = participantMap.isNotEmpty
        ? pick(['username', 'full_name', 'name'], participantMap)
        : pick(['participant_name']);
    final participantPosition = participantMap.isNotEmpty
        ? pick(['position'], participantMap)
        : pick(['participant_position']);

    // ── Attendance: joriy foydalanuvchining yozuvi ─────────────────────────
    bool? attended() {
      final list = json['meeting_attendance'];
      if (list is List) {
        for (final e in list) {
          if (e is! Map) continue;
          final m = e.cast<String, dynamic>();
          final uid = (m['user'] is Map)
              ? (m['user']['id'] as num?)?.toInt()
              : (m['user'] as num?)?.toInt();
          if (currentUserId != null && uid != currentUserId) continue;
          final a = m['is_attended'] ?? m['attended'];
          if (a is bool) return a;
          // Agar currentUserId berilmagan bo‘lsa — birinchi yozuvni olamiz.
          if (currentUserId == null && a is bool) return a;
        }
      }
      final flat = json['attended'] ?? json['is_attended'];
      if (flat is bool) return flat;
      return null;
    }

    return MeetingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: pick(['title', 'name']),
      uid: pick(['uid', 'code', 'meeting_uid']),
      projectName: projectName(),
      startDate: DateTime.tryParse(
        pick(['start_time', 'start_date', 'date', 'datetime']),
      ),
      organizerName: organizerName,
      organizerRole: organizerRole,
      participantName: participantName,
      participantPosition: participantPosition,
      isCompleted: (json['is_completed'] as bool?) ?? false,
      reason: str(json['reason']),
      attended: attended(),
    );
  }
}
