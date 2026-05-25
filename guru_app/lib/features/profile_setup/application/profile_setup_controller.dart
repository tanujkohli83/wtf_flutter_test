import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupState {
  const ProfileSetupState({required this.name, required this.selectedTrainer});

  final String name;
  final String selectedTrainer;

  bool get canContinue => name.trim().isNotEmpty && selectedTrainer.isNotEmpty;

  ProfileSetupState copyWith({String? name, String? selectedTrainer}) {
    return ProfileSetupState(
      name: name ?? this.name,
      selectedTrainer: selectedTrainer ?? this.selectedTrainer,
    );
  }
}

class ProfileSetupController extends Notifier<ProfileSetupState> {
  static const trainers = [
    'Aarav Sharma',
    'Maya Iyer',
    'Kabir Mehta',
    'Nisha Rao',
  ];

  @override
  ProfileSetupState build() {
    return const ProfileSetupState(name: 'DK', selectedTrainer: 'Maya Iyer');
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void selectTrainer(String trainer) {
    state = state.copyWith(selectedTrainer: trainer);
  }
}

final profileSetupControllerProvider =
    NotifierProvider<ProfileSetupController, ProfileSetupState>(
      ProfileSetupController.new,
    );
