class Song {
  final String id;
  final String name;
  final String artist;
  final String image;
  final String? preview;

  Song({
    required this.id, 
    required this.name, 
    required this.artist,
    required this.image, 
    required this.preview
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      artist: json['artists'][0]['name'],
      image: json['album']['images'][0]['url'],
      preview: json['preview_url']
    );
  }
}