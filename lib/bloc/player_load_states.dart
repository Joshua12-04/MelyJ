
import 'package:melyj/bloc/player_state.dart';
import 'package:melyj/model/audio_item.dart';

class InitialState extends PlayState {
  const InitialState();
}

class LoadingState extends PlayState {
  final int currentIndex;
  const LoadingState({required this.currentIndex});
}

final class LoadedState extends PlayState {
  final List<AudioItem>? canciones;

  LoadedState({this.canciones});

  LoadedState copyWidth({List<AudioItem>? canciones}) {
    return LoadedState(
      canciones: canciones ?? this.canciones
    );
  }

  @override
  List<Object> get props => [canciones!];
}

class PlayingState extends PlayState {
  final int currentIndex;
  final Duration duration;
  final Duration position;
  final bool playing;
  final double volumen;
  final double velocidad;

  const PlayingState({
    required this.volumen,
    required this.currentIndex,
    required this.duration,
    required this.position,
    required this.playing,
    required this.velocidad,
  });

  @override
  List<Object?> get props => [currentIndex, duration, position, playing, volumen, velocidad];

  PlayingState copyWith({
    double? volumen,
    int? currentIndex,
    Duration? duration,
    Duration? position,
    bool? playing,
    double? velocidad,
  }) {
    return PlayingState(
      currentIndex: currentIndex ?? this.currentIndex,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      playing: playing ?? this.playing,
      volumen: volumen ?? this.volumen,
      velocidad: velocidad ?? this.velocidad,
    );
  }
}

class ErrorState extends PlayState {
  final String? msg;

  const ErrorState(this.msg);

  @override
  List<Object> get props => [?msg];
}

class PlayPauseState extends PlayState {
  @override
  List<Object> get props => [];
}