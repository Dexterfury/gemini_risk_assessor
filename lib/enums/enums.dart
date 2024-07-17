// weather enum
enum Weather {
  sunny,
  rain,
  windy,
  snow,
}

extension WeatherExtension on Weather {
  String get name {
    return toString().split('.').last;
  }

  static Weather fromString(String weather) {
    return Weather.values.firstWhere(
      (e) => e.name.toLowerCase() == weather.toLowerCase(),
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
enum UserViewType {
  admin,
  user,
  creator,
  tempPlus,
}

// chat button size
enum ChatButtonSize {
  small,
  medium,
  large,
}

// sign in type enum
enum SignInType {
  google,
  facebook,
  apple,
  email,
  phoneNumber,
  anonymous,
}
