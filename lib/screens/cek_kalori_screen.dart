import 'package:flutter/material.dart';

class CekKaloriScreen extends StatefulWidget {
  const CekKaloriScreen({Key? key}) : super(key: key);

  @override
  State<CekKaloriScreen> createState() => _CekKaloriScreenState();
}

class _CekKaloriScreenState extends State<CekKaloriScreen> {
  final TextEditingController _kaloriController = TextEditingController();
  String? _status;

  void _hitungStatusKalori() {
    final kalori = int.tryParse(_kaloriController.text);

    if (kalori == null) {
      setState(() {
        _status = "Masukkan angka kalori yang valid!";
      });
      return;
    }

    if (kalori < 1500) {
      _status = "⚠️ Kurang Kalori: Tambahkan asupan hari ini.";
    } else if (kalori <= 2200) {
      _status = "✅ Sehat: Asupan kalori hari ini sudah baik!";
    } else {
      _status = "❌ Kelebihan Kalori: Kurangi asupan hari ini.";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek Status Kalori Harian"),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Masukkan Total Kalori Hari Ini",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kaloriController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Kalori (kcal)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_fire_department),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _hitungStatusKalori,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Hitung Status Kalori"),
            ),
            const SizedBox(height: 24),
            if (_status != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: Text(
                  _status!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
