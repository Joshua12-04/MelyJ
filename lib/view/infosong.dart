import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/player_load_states.dart';
import '../bloc/player_state.dart';
import '../bloc/playerbloc.dart';
import '../model/audio_item.dart';

class Informationsongs extends StatelessWidget {
  final List<AudioItem> audiolis;
  final PlayerBloc bloc;

  const Informationsongs({
    Key? key,
    required this.bloc,
    required this.audiolis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        String name = "Sin título";
        String artist = "Artista desconocido";

        if (state is PlayingState) {
          final currentIndex = state.currentIndex;
          if (currentIndex >= 0 && currentIndex < audiolis.length) {
            name = audiolis[currentIndex].title;
            artist = audiolis[currentIndex].artist;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "DMSerif",
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                artist,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "DMSerif",
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}