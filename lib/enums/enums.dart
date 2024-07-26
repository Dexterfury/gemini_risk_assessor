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
  email,
  google,
  apple,
  anonymous,
}

// auth status
enum AuthStatus {
  authenticated,
  authenticatedButNoData,
  unauthenticated,
}

// message type
enum MessageType {
  text,
  image,
  video,
  audio,
  quiz,
  quizAnswer,
  additional,
  dailyTip,
}

// extension convertMessageEnumToString on String
extension MessageTypeExtension on String {
  MessageType toMessageType() {
    switch (this) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'quiz':
        return MessageType.quiz;
      case 'quizAnswer':
        return MessageType.quizAnswer;
      case 'additional':
        return MessageType.additional;
      case 'dailyTip':
        return MessageType.dailyTip;
      default:
        return MessageType.text;
    }
  }
}

enum AiActions {
  safetyQuiz,
  tipOfTheDay,
  identifyRisk,
  additionalData,
  summerize,
  none,
}

// extension convertAIActionEnumToString on String
extension AiActionExtension on String {
  AiActions toAIAction() {
    switch (this) {
      case 'safetyQuiz':
        return AiActions.safetyQuiz;
      case 'tipOfTheDay':
        return AiActions.tipOfTheDay;
      case 'identifyRisk':
        return AiActions.identifyRisk;
      case 'none':
        return AiActions.none;
      default:
        return AiActions.safetyQuiz;
    }
  }
}
