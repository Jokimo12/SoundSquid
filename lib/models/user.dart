class User {
  final String name; 
  final String image;

  User({
    required this.name,
    required this.image
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['display_name'],
      image: json['images'][0]['url']
    );
  }
}