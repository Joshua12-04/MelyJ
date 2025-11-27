

import 'package:melyj/bloc/player_event.dart';
import 'package:melyj/model/audio_item.dart';

class PlayerLoadEvent extends PlayerEvent {
  final int index;

  const PlayerLoadEvent(this.index);

  @override
  List<Object> get props => [index];
}

class PlayEvent extends PlayerEvent {

}


class PauseEvent extends PlayerEvent {

}

class NextEvent extends PlayerEvent {

}

class PrevEvent extends PlayerEvent {

}

class SeekEvent extends PlayerEvent{
  final Duration position;
  const SeekEvent(this.position);
  @override
  List<Object> get props => [position];
}

class PlayerSetVolumeEvent extends PlayerEvent {
  final double volumen;

  const PlayerSetVolumeEvent(this.volumen);
}

class PlayerSetSpeedEvent extends PlayerEvent {
  final double velocidad;

  const PlayerSetSpeedEvent(this.velocidad);
}

class CreateAudioItem extends PlayerEvent {
  final AudioItem? audioItem;

  const CreateAudioItem(this.audioItem);

  @override
  List<Object> get props => [audioItem!];
}

class ReadAudioItem extends PlayerEvent {
  @override
  List<Object> get props => [];
}