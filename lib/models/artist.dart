class Artist {
  final String id;
  final String name;
  final String image;
  final int popularity;
  final List<dynamic> genres;

  Artist({
    required this.id,
    required this.name,
    required this.image,
    required this.popularity,
    required this.genres
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      image: json['images'][0]['url'],
      popularity: json['popularity'],
      genres: json['genres']
    );
  }
}