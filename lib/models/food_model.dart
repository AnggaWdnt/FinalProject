class FoodModel {
  final int id;
  final String name;
  final String description;
  final int calories;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      calories: json['calories'],
    );
  }
}
