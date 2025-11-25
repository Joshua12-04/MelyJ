import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../bloc/player_load_event.dart';
import '../bloc/player_load_states.dart';
import '../bloc/player_state.dart';
import '../bloc/playerbloc.dart';

class Buttonpractice extends StatelessWidget {
  final Color color;
  final PlayerBloc bloc;

  const Buttonpractice({
    Key? key,
    required this.color,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        Duration position = Duration.zero;
        Duration duration = Duration.zero;
        bool playing = false;
        double progressPorcent = 0.0;

        if (state is PlayingState) {
          position = state.position;
          duration = state.duration;
          playing = state.playing;

          if (duration.inSeconds != 0) {
            progressPorcent = (position.inSeconds / duration.inSeconds).clamp(0, 1);
          }
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final radius = (constraints.maxWidth * 0.20).clamp(60.0, 180.0);
                final iconSize = (constraints.maxWidth * 0.05).clamp(24.0, 48.0);

                return Center(
                  child: CircularPercentIndicator(
                    radius: radius,
                    lineWidth: 3,
                    percent: progressPorcent.clamp(0.0, 1.0),
                    progressColor: color,
                    backgroundColor: Colors.blueGrey.withOpacity(0.3),
                    circularStrokeCap: CircularStrokeCap.round,
                    arcType: ArcType.HALF,
                    center: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: iconSize,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () => bloc.add(PrevEvent()),
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                            child: IconButton(
                              iconSize: iconSize * 1.2,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () => bloc.add(playing ? PauseEvent() : PlayEvent()),
                              icon: Icon(
                                playing ? Icons.pause : Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            iconSize: iconSize,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () => bloc.add(NextEvent()),
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}