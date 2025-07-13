import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/daily_log_model.dart';

part 'daily_log_state.dart';

class DailyLogCubit extends Cubit<DailyLogState> {
  final String baseUrl = 'http://10.0.2.2:8000';

  DailyLogCubit() : super(const DailyLogState());

  Future<void> fetchDailyLogs() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Token tidak ditemukan. Silakan login ulang.',
        isLoading: false,
      ));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/daily-logs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        final logs = data.map((e) => DailyLog.fromJson(e)).toList();
        emit(state.copyWith(logs: logs, isLoading: false));
      } else {
        emit(state.copyWith(
          errorMessage: 'Gagal memuat log harian',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> addDailyLog({
    required String foodName,
    required int portion,
    required String unit,
    required int calories,
    File? photo,
    double? latitude,
    double? longitude,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Token tidak ditemukan. Silakan login ulang.',
        isLoading: false,
      ));
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/daily-logs'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['food_name'] = foodName;
      request.fields['portion'] = portion.toString();
      request.fields['unit'] = unit;
      if (calories > 0) {
        request.fields['calories'] = calories.toString();
      }
      if (latitude != null && longitude != null) {
        request.fields['latitude'] = latitude.toString();
        request.fields['longitude'] = longitude.toString();
      }
      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        fetchDailyLogs(); // Refresh list setelah tambah
      } else {
        final errorData = json.decode(responseBody);
        emit(state.copyWith(
          errorMessage: errorData['message'] ?? 'Gagal menambahkan log',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }
}
