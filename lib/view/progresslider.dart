import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/player_load_event.dart';
import '../bloc/player_load_states.dart';
import '../bloc/player_state.dart';
import '../bloc/playerbloc.dart';

class Progresslider extends StatelessWidget {
  final Color color;
  final PlayerBloc bloc;

  const Progresslider({Key? key, required this.color, required this.bloc})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        Duration position = Duration.zero;
        Duration duration = Duration.zero;
        double sliderValue = 0.0;

        if (state is PlayingState) {
          position = state.position;
          duration = state.duration;

          if (duration.inMilliseconds > 0) {
            sliderValue = (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);
          }
        }

        return Column(
          children: [
            Slider(
              value: sliderValue,
              activeColor: color,
              inactiveColor: Colors.grey[300],
              onChanged: (value) {
                final newPosition = Duration(
                  milliseconds: (value * duration.inMilliseconds).round(),
                );
                bloc.add(SeekEvent(newPosition));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
