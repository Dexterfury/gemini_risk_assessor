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
                  iconData: getWeatherIcon(weather),
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
}
