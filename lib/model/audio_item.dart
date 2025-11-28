class AudioItem {
  final int? id;
  final String? assetPath;
  final String? title;
  final String? artist;
  final String? imagePath;

  AudioItem({
    this.id,
    this.assetPath,
    this.title,
    this.artist,
    this.imagePath,
  });

  // Convertir de Map a AudioItem (para leer de la BD)
  factory AudioItem.fromMap(Map<String, dynamic> map) {
    return AudioItem(
      id: map['id'] as int?,
      assetPath: map['assetPath'] as String?,
      title: map['title'] as String?,
      artist: map['artist'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }

  // Convertir de AudioItem a Map (para guardar en la BD)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'assetPath': assetPath,
      'title': title,
      'artist': artist,
      'imagePath': imagePath,
    };
  }

  // CopyWith para crear copias con modificaciones
  AudioItem copyWith({
    int? id,
    String? assetPath,
    String? title,
    String? artist,
    String? imagePath,
  }) {
    return AudioItem(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'AudioItem{id: $id, title: $title, artist: $artist}';
  }
}