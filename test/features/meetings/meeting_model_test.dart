import 'package:dc_management_app/features/meetings/data/models/meeting_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'MeetingModel reads participants from participants_info '
    '(participants is writeOnly and absent in responses)',
    () {
      final model = MeetingModel.fromJson({
        'id': 7,
        'title': 'Weekly sync',
        'participants_info': [
          {'id': 3, 'username': 'ali', 'position': 'Dev', 'avatar': ''},
          {'id': 9, 'username': 'vali', 'position': 'QA', 'avatar': ''},
        ],
      });

      expect(model.participantIds, [3, 9]);
      expect(model.participantsInfo.length, 2);
      expect(model.participantsInfo.first.username, 'ali');
      expect(model.participantsInfo.last.position, 'QA');
    },
  );
}
