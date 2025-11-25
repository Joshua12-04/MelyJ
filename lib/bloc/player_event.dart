import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<dynamic> get props => [];
}

class SeekToPosition extends PlayerEvent {
  final Duration position;
  const SeekToPosition(this.position);
}

