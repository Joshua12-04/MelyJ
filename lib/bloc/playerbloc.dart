import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:melyj/bloc/player_event.dart';
import 'package:melyj/bloc/player_load_event.dart';
import 'package:melyj/bloc/player_load_states.dart';
import 'package:melyj/bloc/player_state.dart';
import '../model/audio_item.dart';
import '../model/databasehelper.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayState> {
  final AudioPlayer? audioPlayer;
  List<AudioItem>? canciones;
  StreamSubscription? position, duration, estado;
  final DatabaseHelper? dbhelper;

  PlayerBloc({this.dbhelper, this.audioPlayer, this.canciones})
      : super(const InitialState()) {
    // Registrar y manipular la base de datos
    on<CreateAudioItem>(crearCanciones);
    on<ReadAudioItem>(leerCanciones);
    on<DeleteAudioItem>(eliminarCancion);
    on<DeleteAllAudioItems>(eliminarTodasCanciones);
    on<UpdateAudioItem>(actualizarCancion);
    // Registrar todos los manejadores de eventos
    on<PlayerLoadEvent>(cargando);
    on<PlayEvent>(reproduciendo);
    on<PauseEvent>(pausando);
    on<NextEvent>(siguiente);
    on<PrevEvent>(anterior);
    on<SeekEvent>(moviendo);
    on<PlayerSetVolumeEvent>(volumen);
    on<PlayerSetSpeedEvent>(velocidad);
    setUp(); // Configura los listeners
  }

  FutureOr<void> cargando(
      PlayerLoadEvent event,
      Emitter<PlayState> emit,
      ) async {
    try {
      // Asegurarse de que las canciones estén cargadas
      if (canciones == null || canciones!.isEmpty) {
        emit(const ErrorState("No hay canciones disponibles"));
        return;
      }

      emit(LoadingState(currentIndex: event.index));

      await audioPlayer!.stop();
      final String? assetPath = canciones![event.index].assetPath;

      await audioPlayer!.setSourceAsset(assetPath!);

      Duration? duracionObtenida;
      if (!kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 100));

        duracionObtenida = await audioPlayer!.getDuration();

        if (duracionObtenida == null) {
          await Future.delayed(const Duration(milliseconds: 200));
          duracionObtenida = await audioPlayer!.getDuration();
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
      emit(const ErrorState("Error: no se pudo cargar el archivo"));
      debugPrint(e.toString());
    }
  }

  FutureOr<void> reproduciendo(PlayEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer!.resume();
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(playing: true));
      } catch (e) {
        emit(const ErrorState("Error: no se pudo reproducir el archivo"));
        debugPrint(e.toString());
      }
    }
  }

  FutureOr<void> pausando(PauseEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer!.pause();
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(playing: false));
      } catch (e) {
        emit(const ErrorState("Error: no se pudo pausar el archivo"));
        debugPrint(e.toString());
      }
    }
  }

  FutureOr<void> siguiente(NextEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState && canciones != null) {
      final PlayingState estadoActual = state as PlayingState;
      final int nextIndex = (estadoActual.currentIndex + 1) % canciones!.length;

      emit(
        estadoActual.copyWith(
          currentIndex: nextIndex,
          playing: false,
          position: Duration.zero,
        ),
      );

      add(PlayerLoadEvent(nextIndex));
    }
  }

  FutureOr<void> anterior(PrevEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState && canciones != null) {
      final PlayingState estadoActual = state as PlayingState;
      final int previousIndex =
          (estadoActual.currentIndex - 1 + canciones!.length) %
              canciones!.length;

      emit(
        estadoActual.copyWith(
          currentIndex: previousIndex,
          playing: false,
          position: Duration.zero,
        ),
      );

      add(PlayerLoadEvent(previousIndex));
    }
  }

  FutureOr<void> moviendo(SeekEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      final PlayingState estadoActual = state as PlayingState;
      emit(estadoActual.copyWith(position: event.position));
      await audioPlayer!.seek(event.position);
    }
  }

  void setUp() {
    position = audioPlayer!.onPositionChanged.listen((newPosition) {
      if (state is PlayingState) {
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(position: newPosition));
      }
    });
    duration = audioPlayer!.onDurationChanged.listen((newDuration) {
      if (state is PlayingState) {
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(duration: newDuration));
      }
    });

    estado = audioPlayer!.onPlayerStateChanged.listen((playerState) {
      if (state is PlayingState) {
        final PlayingState estadoActual = state as PlayingState;
        if (playerState == PlayerState.playing && !estadoActual.playing) {
          emit(estadoActual.copyWith(playing: true));
        } else if (playerState == PlayerState.paused && estadoActual.playing) {
          emit(estadoActual.copyWith(playing: false));
        } else if (playerState == PlayerState.completed) {
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
    audioPlayer?.dispose();
    return super.close();
  }

  FutureOr<void> volumen(
      PlayerSetVolumeEvent event,
      Emitter<PlayState> emit,
      ) async {
    await audioPlayer?.setVolume(event.volumen);
    if (state is PlayingState) {
      final currentState = state as PlayingState;
      emit(currentState.copyWith(volumen: event.volumen));
    }
  }

  FutureOr<void> velocidad(
      PlayerSetSpeedEvent event,
      Emitter<PlayState> emit,
      ) async {
    await audioPlayer?.setPlaybackRate(event.velocidad);
    if (state is PlayingState) {
      final currentState = state as PlayingState;
      emit(currentState.copyWith(velocidad: event.velocidad));
    }
  }

  FutureOr<void> crearCanciones(
      CreateAudioItem event,
      Emitter<PlayState> emit,
      ) async {
    try {
      await dbhelper?.Create(event.audioItem!);
      add(ReadAudioItem());
    } catch (e) {
      emit(const ErrorState("Error: No se pudo agregar la canción"));
      add(ReadAudioItem());
    }
  }

  FutureOr<void> leerCanciones(
      ReadAudioItem event,
      Emitter<PlayState> emit,
      ) async {
    try {
      // Mantener el índice actual si existe
      int currentIndex = 0;
      if (state is PlayingState) {
        currentIndex = (state as PlayingState).currentIndex;
      }

      emit(LoadingState(currentIndex: currentIndex));

      // Leer canciones de la base de datos
      canciones = await dbhelper?.ReadAll();

      if (canciones == null || canciones!.isEmpty) {
        emit(const ErrorState("No hay canciones en la base de datos"));
        return;
      }

      emit(LoadedState(canciones: canciones));
    } catch (e) {
      emit(const ErrorState("Error: No se pudo conectar a la base de datos"));
      debugPrint(e.toString());
    }
  }

  FutureOr<void> eliminarCancion(
      DeleteAudioItem event,
      Emitter<PlayState> emit,
      ) async {
    try {
      await dbhelper?.Delete(event.id);
      add(ReadAudioItem());
    } catch (e) {
      emit(const ErrorState("Error: No se pudo eliminar la canción"));
      debugPrint(e.toString());
      add(ReadAudioItem());
    }
  }

  FutureOr<void> eliminarTodasCanciones(
      DeleteAllAudioItems event,
      Emitter<PlayState> emit,
      ) async {
    try {
      await audioPlayer?.stop();
      await dbhelper?.DeleteAll();
      canciones = [];
      emit(const InitialState());
    } catch (e) {
      emit(const ErrorState("Error: No se pudieron eliminar las canciones"));
      debugPrint(e.toString());
    }
  }

  FutureOr<void> actualizarCancion(
      UpdateAudioItem event,
      Emitter<PlayState> emit,
      ) async {
    try {
      await dbhelper?.Update(event.audioItem);
      add(ReadAudioItem());
    } catch (e) {
      emit(const ErrorState("Error: No se pudo actualizar la canción"));
      debugPrint(e.toString());
      add(ReadAudioItem());
    }
  }
}