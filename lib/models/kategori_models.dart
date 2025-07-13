class KategoriModel {
  final int id;
  final String name;

  KategoriModel({
    required this.id,
    required this.name,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
