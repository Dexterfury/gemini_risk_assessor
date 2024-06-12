// weather enum
enum Weather {
  sunny,
  rain,
  windy,
  snow,
}

extension WeatherExtension on Weather {
  static Weather fromString(String weather) {
    return Weather.values.firstWhere(
      (e) => e.toString().split('.').last == weather,
      orElse: () => throw ArgumentError('Unknown weather: $weather'),
    );
  }
}

// data title enum
enum ListHeader {
  equipments,
  hazards,
  risks,
  control,
  signatures,
  approvers,
  ppe,
}
