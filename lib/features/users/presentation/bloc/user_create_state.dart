part of 'user_create_bloc.dart';

class UserCreateState extends Equatable {
  const UserCreateState({
    this.optionsLoading = false,
    this.districtsLoading = false,
    this.submitting = false,
    this.success = false,
    this.positions = const [],
    this.regions = const [],
    this.districts = const [],
    this.selectedRegionId,
    this.failure,
  });

  final bool optionsLoading;
  final bool districtsLoading;
  final bool submitting;
  final bool success;
  final List<Position> positions;
  final List<Region> regions;
  final List<District> districts;
  final int? selectedRegionId;
  final Failure? failure;

  UserCreateState copyWith({
    bool? optionsLoading,
    bool? districtsLoading,
    bool? submitting,
    bool? success,
    List<Position>? positions,
    List<Region>? regions,
    List<District>? districts,
    int? selectedRegionId,
    Failure? failure,
    bool clearFailure = false,
  }) => UserCreateState(
    optionsLoading: optionsLoading ?? this.optionsLoading,
    districtsLoading: districtsLoading ?? this.districtsLoading,
    submitting: submitting ?? this.submitting,
    success: success ?? this.success,
    positions: positions ?? this.positions,
    regions: regions ?? this.regions,
    districts: districts ?? this.districts,
    selectedRegionId: selectedRegionId ?? this.selectedRegionId,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    optionsLoading,
    districtsLoading,
    submitting,
    success,
    positions,
    regions,
    districts,
    selectedRegionId,
    failure,
  ];
}
