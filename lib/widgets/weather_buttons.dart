import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/weather_button.dart';

class WeatherButtons extends StatelessWidget {
  const WeatherButtons({
    super.key,
    required this.assessmentProvider,
  });

  final AssessmentProvider assessmentProvider;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final weather in Weather.values)
            IntrinsicHeight(
              child: WeatherButton(
                title: weather.name,
                value: assessmentProvider.weather == weather,
                iconData: getWeatherIcon(weather),
                onChanged: () {
                  assessmentProvider.setWeather(newWeather: weather);
                },
              ),
            ),
        ],
      ),
    );
  }
}
