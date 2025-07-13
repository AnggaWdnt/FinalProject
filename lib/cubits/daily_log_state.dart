part of 'daily_log_cubit.dart';

class DailyLogState extends Equatable {
  final List<DailyLog> logs;
  final bool isLoading;
  final String? errorMessage;

  const DailyLogState({
    this.logs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DailyLogState copyWith({
    List<DailyLog>? logs,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DailyLogState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [logs, isLoading, errorMessage];
}
