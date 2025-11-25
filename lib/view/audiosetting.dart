import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/player_load_event.dart';
import '../bloc/player_load_states.dart';
import '../bloc/player_state.dart';
import '../bloc/playerbloc.dart';

class AudioSettings extends StatefulWidget {
  final PlayerBloc bloc;

  const AudioSettings({Key? key, required this.bloc}) : super(key: key);

  @override
  _AudioSettingsState createState() => _AudioSettingsState();
}

class _AudioSettingsState extends State<AudioSettings> {
  late double volumenActual;
  late double velocidadActual;

  @override
  void initState() {
    super.initState();
    final currentState = widget.bloc.state;
    if (currentState is PlayingState) {
      volumenActual = currentState.volumen;
      velocidadActual = currentState.velocidad;
    } else {
      volumenActual = 1.0;
      velocidadActual = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        Duration position = Duration.zero;
        Duration duration = Duration.zero;
        bool estado = false;

        if (state is PlayingState) {
          position = state.position;
          duration = state.duration;
          estado = state.playing;
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white38),
                Row(
                  children: [
                    const Icon(Icons.volume_down, color: Colors.black),
                    Expanded(
                      child: Slider(
                        value: volumenActual,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.red,
                        inactiveColor: Colors.white38,
                        onChanged: (value) {
                          setState(() => volumenActual = value);
                          widget.bloc.add(PlayerSetVolumeEvent(value));
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up, color: Colors.black),
                  ],
                ),
                Text(
                  'Volumen: ${(100 * volumenActual).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white38),
                const Text(
                  'Velocidad de Reproducción',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                        .map((speed) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildSpeedButton(speed),
                    ))
                        .toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 180, 140, 100),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Música',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Estado: ${estado ? "Melodiando" : "Pausado"}',
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                          ),
                          Text(
                            'Posición: ${_formatDuration(position)}',
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                          ),
                          Text(
                            'Duración: ${_formatDuration(duration)}',
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedButton(double velocidad) {
    final bool isSelected = (velocidadActual - velocidad).abs() < 0.01;

    return GestureDetector(
      onTap: () {
        setState(() => velocidadActual = velocidad);
        widget.bloc.add(PlayerSetSpeedEvent(velocidad));
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightBlue : Colors.grey[850],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.lightBlue : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: Colors.white, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              _formatSpeed(velocidad),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatSpeed(double velocidad) {
    if (velocidad == velocidad.toInt()) {
      return '${velocidad.toInt()}.0x';
    }
    String formatted = velocidad.toStringAsFixed(2);
    if (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return '${formatted}x';
  }
}