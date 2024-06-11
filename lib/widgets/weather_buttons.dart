import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/widgets/weather_button.dart';

class WeatherButtons extends StatelessWidget {
  const WeatherButtons({
    super.key,
    required this.assessmentProvider,
  });

  final AssessmentProvider assessmentProvider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: Weather.values.length,
        itemBuilder: (context, index) {
          final weather = Weather.values[index];
          final value = assessmentProvider.weather == weather;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 100,
              child: WeatherButton(
                  title: weather.name,
                  value: value,
                  iconData: _getIcon(weather),
                  onChanged: () {
                    assessmentProvider.setWeather(
                      newWeather: weather,
                    );
                  }),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(Weather weather) {
    return weather == Weather.sunny
        ? Icons.wb_sunny_outlined
        : weather == Weather.rain
            ? Icons.shower
            : weather == Weather.windy
                ? Icons.wind_power
                : Icons.snowing;
  }
}
