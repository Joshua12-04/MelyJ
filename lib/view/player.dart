import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melyj/view/progresslider.dart';
import 'package:melyj/view/swiper.dart';
import 'dart:async';
import '../bloc/player_load_event.dart';
import '../bloc/player_load_states.dart';
import '../bloc/player_state.dart';
import '../bloc/playerbloc.dart';
import '../model/audio_item.dart';
import '../model/databasehelper.dart';
import 'audiosetting.dart';
import 'buttonpractice.dart';
import 'infosong.dart';
import 'musicplayerwithdrawer.dart';

class PlayerWrapper extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const PlayerWrapper({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _PlayerWrapperState createState() => _PlayerWrapperState();
}

class _PlayerWrapperState extends State<PlayerWrapper> {
  late final PlayerBloc bloc;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Inicializar la base de datos con canciones si está vacía
    await _initializeDatabase();

    // Crear el bloc con la base de datos
    bloc = PlayerBloc(
      audioPlayer: widget.audioPlayer,
      dbhelper: DatabaseHelper.instance,
    );

    // Cargar las canciones desde la base de datos
    bloc.add(ReadAudioItem());

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _initializeDatabase() async {
    final db = DatabaseHelper.instance;
    final canciones = await db.ReadAll();

    // Si la base de datos está vacía, insertar canciones predeterminadas
    if (canciones.isEmpty) {
      final cancionesIniciales = [

        AudioItem(
          assetPath: "music/como_lo_mueve.mp3",
          title: "Como lo mueve Low",
          artist: "El Joshua",
          imagePath: "assets/images/pocoyo.png",
        ),
        AudioItem(
          assetPath: "music/arctic_monkeys.mp3",
          title: "Why’d you only call me when you’re high",
          artist: "Arctic Monkeys",
          imagePath: "assets/images/arctic_monkeys.jpg",
        ),
        AudioItem(
          assetPath: "music/back_to_black.mp3",
          title: "Back To Black",
          artist: "Amy Winehouse",
          imagePath: "assets/images/back_to_black.jpg",
        ),
        AudioItem(
          assetPath: "music/Calidad.mp3",
          title: "Calidad",
          artist: "Luis Mexia",
          imagePath: "assets/images/calidad.jpg",
        ),
        AudioItem(
          assetPath: "music/coqueta.mp3",
          title: "Coqueta",
          artist: "Fuerza Regida",
          imagePath: "assets/images/coqueta.jpg",
        ),
        AudioItem(
          assetPath: "music/lavidaesunriesgo.mp3",
          title: "La vida es un reisgo",
          artist: "El Abelito",
          imagePath: "assets/images/la_vida_es_un_riesgo.jpg",
        ),
        AudioItem(
          assetPath: "music/lay_all_your_love_on_me.mp3",
          title: "Lay all your love on me",
          artist: "ABBA",
          imagePath: "assets/images/adba.jpg",
        ),
        AudioItem(
          assetPath: "music/maroon5.mp3",
          title: "This Love",
          artist: "MAROON 5",
          imagePath: "assets/images/maroon5",
        ),
      ];

      // Insertar cada canción en la base de datos
      for (var cancion in cancionesIniciales) {
        await db.Create(cancion);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BlocProvider<PlayerBloc>(
      create: (_) => bloc,
      child: const Player(),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  static const _wormColor = Color(0xffffe082);
  late PageController pageController;
  StreamSubscription? blocSubscription;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: .8);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<PlayerBloc>();

      blocSubscription = bloc.stream.listen((state) {
        if (state is PlayingState && mounted && pageController.hasClients) {
          final currentPage = pageController.page?.round() ?? 0;
          if (currentPage != state.currentIndex) {
            pageController.animateToPage(
              state.currentIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        // Mostrar loading mientras se cargan las canciones
        if (state is LoadingState && state is! PlayingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Obtener las canciones del estado LoadedState
        List<AudioItem> canciones = [];
        if (state is LoadedState) {
          canciones = state.canciones ?? [];
          // Cargar la primera canción automáticamente
          if (canciones.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(PlayerLoadEvent(0));
            });
          }
        } else if (state is PlayingState) {
          // Si ya estamos en PlayingState, obtener canciones del bloc
          canciones = bloc.canciones ?? [];
        }

        if (canciones.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No hay canciones disponibles'),
            ),
          );
        }

        return MusicPlayerWithDrawer(
          canciones: canciones,
          onSettingsTap: () => _showSettings(context, bloc),
          mainScreen: _buildMainContent(bloc, canciones),
        );
      },
    );
  }

  Widget _buildMainContent(PlayerBloc bloc, List<AudioItem> canciones) {
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            Swiper(
              pageController: pageController,
              audioList: canciones,
              color: _wormColor,
              bloc: bloc,
            ),
            Informationsongs(audiolis: canciones, bloc: bloc),
            Progresslider(color: _wormColor, bloc: bloc),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Buttonpractice(color: _wormColor, bloc: bloc),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    blocSubscription?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _showSettings(BuildContext context, PlayerBloc bloc) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: const Color(0xffffe082),
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.45,
                child: AudioSettings(bloc: bloc),
              ),
            ),
          ),
        ),
      ),
    );
  }
}