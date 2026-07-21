part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, saving, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.failure,
  });

  final ProfileStatus status;
  final Profile? profile;
  final Failure? failure;

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    Failure? failure,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, profile, failure];
}
