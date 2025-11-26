import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:melyj/bloc/player_event.dart';
import 'package:melyj/bloc/player_load_event.dart';
import 'package:melyj/bloc/player_load_states.dart';
import 'package:melyj/bloc/player_state.dart';
import '../model/audio_item.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayState> {
  final AudioPlayer audioPlayer;
  final List<AudioItem> canciones;
  StreamSubscription? position, duration, estado;

  PlayerBloc({required this.audioPlayer, required this.canciones})
      : super(InitialState()) {
    // Registrar todos los manejadores de eventos
    on<PlayerLoadEvent>(cargando);
    on<PlayEvent>(reproduciendo);
    on<PauseEvent>(pausando);
    on<NextEvent>(siguiente);
    on<PrevEvent>(anterior);
    on<SeekEvent>(moviendo);
    on<PlayerSetVolumeEvent>(volumen);
    on<PlayerSetSpeedEvent>(velocidad);
    setUp();  // Configura los listeners
  }

  FutureOr<void> cargando(
      PlayerLoadEvent event,
      Emitter<PlayState> emit,
      ) async {
    try {
      emit(LoadingState(currentIndex: event.index));

      await audioPlayer.stop();
      final String assetPath = canciones[event.index].assetPath;

        await audioPlayer.setSourceAsset(assetPath);

      Duration? duracionObtenida;
      if (!kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 100));

        duracionObtenida = await audioPlayer.getDuration();

        if (duracionObtenida == null) {
          await Future.delayed(const Duration(milliseconds: 200));
          duracionObtenida = await audioPlayer.getDuration();
        }
      }

      double velocidadActual = 1.0;
      double volumenActual = 1.0;
      if (state is PlayingState) {
        final estadoAnterior = state as PlayingState;
        velocidadActual = estadoAnterior.velocidad;
        volumenActual = estadoAnterior.volumen;
      }

      emit(
        PlayingState(
          currentIndex: event.index,
          duration: duracionObtenida ?? Duration.zero,
          position: Duration.zero,
          playing: false,
          volumen: volumenActual,
          velocidad: velocidadActual,
        ),
      );
      add(PlayEvent());
    } catch (e) {
      emit(ErrorState("Error: no se pudo cargar el archivo"));
      debugPrint(e.toString());
    }
  }

  FutureOr<void> reproduciendo(PlayEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.resume();
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(playing: true));
      } catch (e) {
        emit(ErrorState("Error: no se pudo reproducir el archivo"));
        debugPrint(e.toString());
      }
    }
  }

  FutureOr<void> pausando(PauseEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.pause();
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(playing: false));
      } catch (e) {
        emit(ErrorState("Error: no se pudo pausar el archivo"));
        debugPrint(e.toString());
      }
    }
  }

  FutureOr<void> siguiente(NextEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      final PlayingState estadoActual = state as PlayingState;
      final int nextIndex = (estadoActual.currentIndex + 1) % canciones.length;

      emit(estadoActual.copyWith(
        currentIndex: nextIndex,
        playing: false,
        position: Duration.zero,
      ));

      add(PlayerLoadEvent(nextIndex));
    }
  }

  FutureOr<void> anterior(PrevEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      final PlayingState estadoActual = state as PlayingState;
      final int previousIndex =
          (estadoActual.currentIndex - 1 + canciones.length) % canciones.length;

      emit(estadoActual.copyWith(
        currentIndex: previousIndex,
        playing: false,
        position: Duration.zero,
      ));

      add(PlayerLoadEvent(previousIndex));
    }
  }

  FutureOr<void> moviendo(SeekEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      final PlayingState estadoActual = state as PlayingState;
      emit(estadoActual.copyWith(position: event.position));
      await audioPlayer.seek(event.position);
    }
  }

  void setUp() {
    position = audioPlayer.onPositionChanged.listen((newPosition) {
      if (state is PlayingState) {
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(position: newPosition));
      }
    });
    duration = audioPlayer.onDurationChanged.listen((newDuration) {
      if (state is PlayingState) {
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(duration: newDuration));
      }
    });

    estado = audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (state is PlayingState) {
        final PlayingState estadoActual = state as PlayingState;
        if (playerState == PlayerState.playing && !estadoActual.playing) {
          emit(estadoActual.copyWith(playing: true));
        }
        else if (playerState == PlayerState.paused && estadoActual.playing) {
          emit(estadoActual.copyWith(playing: false));
        }
        else if (playerState == PlayerState.completed) {
          emit(estadoActual.copyWith(playing: false, position: Duration.zero));
          add(NextEvent());
        }
      }
    });
  }

  @override
  Future<void> close() {
    estado?.cancel();
    position?.cancel();
    duration?.cancel();
    audioPlayer.dispose();
    return super.close();
  }

  FutureOr<void> volumen(
      PlayerSetVolumeEvent event,
      Emitter<PlayState> emit,
      ) async {
    await audioPlayer.setVolume(event.volumen);
    if (state is PlayingState) {
      final currentState = state as PlayingState;
      emit(currentState.copyWith(volumen: event.volumen));
    }
  }

  FutureOr<void> velocidad(
      PlayerSetSpeedEvent event,
      Emitter<PlayState> emit,
      ) async {
    await audioPlayer.setPlaybackRate(event.velocidad);
    if (state is PlayingState) {
      final currentState = state as PlayingState;
      emit(currentState.copyWith(velocidad: event.velocidad));
    }
  }
}