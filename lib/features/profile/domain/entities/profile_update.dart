import 'package:equatable/equatable.dart';

/// `/users/me/` PATCH uchun o'zgargan maydonlar va tanlangan avatar fayli.
class ProfileUpdate extends Equatable {
  const ProfileUpdate({required this.fields, this.avatarPath});

  final Map<String, dynamic> fields;
  final String? avatarPath;

  @override
  List<Object?> get props => [fields, avatarPath];
}
