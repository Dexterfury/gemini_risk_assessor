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
      orElse: () => Weather.sunny, // Default to sunny if unknown weather
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

// generationType
enum GenerationType {
  tool,
  dsti,
  riskAssessment,
}

// user Type enum
enum UserViewType { admin, user, creator, tempPlus }
