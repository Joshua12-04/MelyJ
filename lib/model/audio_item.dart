//PODO
class AudioItem {
  final String? assetPath, title, artist, imagePath;

  AudioItem({this.assetPath, this.title, this.artist, this.imagePath});

  @override
  List<Object?> get props => [
    this.assetPath,
    this.title,
    this.artist,
    this.imagePath,
  ];

  // Convierte el objeto en un map
  Map<String, dynamic> toMap() {
    return {
      'assetPath': assetPath,
      'title': title,
      'artist': artist,
      'imagePath': imagePath,
    };
  }

  // Constructor que puede retornar objetos
  factory AudioItem.fromMap(Map<String, dynamic> map) {
    return AudioItem(
      assetPath: map['assetPath'],
      title: map['title'],
      artist: map['artist'],
      imagePath: map['imagePath'],
    );
  }

  AudioItem copyWith({
    String? assetPath,
    String? title,
    String? artist,
    String? imagePath,
  }) {
    return AudioItem(
      assetPath: assetPath ?? this.assetPath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'AudioItem{assetPath: $assetPath, title: $title, artist: $artist, imagePath: $imagePath}';
  }

} // end class
