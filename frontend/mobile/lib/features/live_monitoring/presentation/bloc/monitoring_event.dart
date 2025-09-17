// monitoring_event.dart
part of 'monitoring_bloc.dart';

abstract class MonitoringEvent extends Equatable {
  const MonitoringEvent();

  @override
  List<Object?> get props => [];
}

class LoadLatestReadingsEvent extends MonitoringEvent {}

class LoadHistoricalReadingsEvent extends MonitoringEvent {
  final String farmId;
  final int days;

  const LoadHistoricalReadingsEvent({required this.farmId, this.days = 7});

  @override
  List<Object?> get props => [farmId, days];
}

class RefreshReadingsEvent extends MonitoringEvent {
  final String? farmId;

  const RefreshReadingsEvent({this.farmId});

  @override
  List<Object?> get props => [farmId];
}

class LoadGeospatialDataEvent extends MonitoringEvent {
  final String farmId;

  const LoadGeospatialDataEvent({required this.farmId});

  @override
  List<Object?> get props => [farmId];
}

class GenerateFieldsEvent extends MonitoringEvent {
  final String farmId;

  const GenerateFieldsEvent({required this.farmId});

  @override
  List<Object?> get props => [farmId];
}

class LoadWeatherDataEvent extends MonitoringEvent {
  final String farmId;

  const LoadWeatherDataEvent({required this.farmId});

  @override
  List<Object?> get props => [farmId];
}

class LoadFarmAnalyticsEvent extends MonitoringEvent {
  final String farmId;

  const LoadFarmAnalyticsEvent({required this.farmId});

  @override
  List<Object?> get props => [farmId];
}

class AnalyticsUpdatedEvent extends MonitoringEvent {
  final Map<String, dynamic> analytics;

  const AnalyticsUpdatedEvent({required this.analytics});

  @override
  List<Object?> get props => [analytics];
}