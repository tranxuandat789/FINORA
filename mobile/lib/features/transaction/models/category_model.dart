class CategoryModel {
  final String id;
  final String name;
  final int type;
  final String? icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
    };
  }
}
