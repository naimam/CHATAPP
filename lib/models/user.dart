class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.ratingUids,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        rating: data['rating'].toDouble(),
        ratingUids: data['ratingUids']);
  }

  final String id;
  final String name;
  final String email;
  final double rating;
  final List<dynamic> ratingUids;
}
