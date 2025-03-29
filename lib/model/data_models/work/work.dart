final class Work {
  final String id;
  final String name;
  final String description;
  final List<String> imagesUrls;

  Work({
    required this.id,
    required this.name,
    required this.description,
    required this.imagesUrls,
  });

  factory Work.fromJson(Map<String, dynamic> map) {
    return Work(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imagesUrls: List<String>.from(map['images_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images_urls': imagesUrls,
    };
  }
}
