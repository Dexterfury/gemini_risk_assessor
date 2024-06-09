import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/weather.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/widgets/weather_button.dart';

class WeatherRow extends StatelessWidget {
  const WeatherRow({
    super.key,
    required this.assessmentProvider,
  });

  final AssessmentProvider assessmentProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        WeatherButton(
            title: Weather.sunny.name,
            value: assessmentProvider.weather == Weather.sunny,
            iconData: Icons.wb_sunny_outlined,
            onChanged: () {
              assessmentProvider.setWeather(newWeather: Weather.sunny);
            }),
        const SizedBox(
          width: 10,
        ),
        WeatherButton(
            title: Weather.rain.name,
            value: assessmentProvider.weather == Weather.rain,
            iconData: Icons.shower,
            onChanged: () {
              assessmentProvider.setWeather(newWeather: Weather.rain);
            }),
        const SizedBox(
          width: 10,
        ),
        WeatherButton(
            title: Weather.windy.name,
            value: assessmentProvider.weather == Weather.windy,
            iconData: Icons.wind_power,
            onChanged: () {
              assessmentProvider.setWeather(newWeather: Weather.windy);
            }),
        const SizedBox(
          width: 10,
        ),
        WeatherButton(
            title: Weather.snow.name,
            value: assessmentProvider.weather == Weather.snow,
            iconData: Icons.snowing,
            onChanged: () {
              assessmentProvider.setWeather(newWeather: Weather.snow);
            }),
      ],
    );
  }
}
