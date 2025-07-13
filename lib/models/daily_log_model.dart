class DailyLog {
  final int id;
  final String foodName;
  final int portion;
  final String unit;
  final int? calories;
  final String? photo;
  final String date; // ✅ Tambahkan field date

  DailyLog({
    required this.id,
    required this.foodName,
    required this.portion,
    required this.unit,
    this.calories,
    this.photo,
    required this.date, // ✅ Tambahkan
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      id: json['id'],
      foodName: json['food_name'],
      portion: json['portion'],
      unit: json['unit'],
      calories: json['calories'],
      photo: json['photo'],
      date: json['created_at'], // ✅ Ambil dari field API misalnya created_at
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'portion': portion,
      'unit': unit,
      'calories': calories,
      'photo': photo,
    };
  }
}
