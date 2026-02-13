class Post {
  final String id;
  final String recipeName;
  final String recipeId;
  final String photoPath;
  final DateTime cookedAt;
  int likes;
  bool isLikedByMe;

  Post({
    required this.id,
    required this.recipeName,
    required this.recipeId,
    required this.photoPath,
    required this.cookedAt,
    this.likes = 0,
    this.isLikedByMe = false,
});

  Map<String,dynamic> toJson() => {
    'id': id,
    'recipeName': recipeName,
    'recipeId': recipeId,
    'photoPath': photoPath,
    'cookedAt': cookedAt.toIso8601String(),
    'likes': likes,
    'isLikedByMe': isLikedByMe,
  };
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    recipeName: json['recipeName'],
    recipeId: json['recipeId'],
    photoPath: json['photoPath'],
    cookedAt: DateTime.parse(json['cookedAt']),
    likes: json['likes'] ?? 0,
    isLikedByMe: json['isLikedByMe'] ?? false,
  );
}
