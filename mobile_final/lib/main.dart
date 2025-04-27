import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'moonPhase.dart';
import 'forecastCard.dart';

void main() {
  runApp(MyApp());
}

class WeatherService {
  final String apiKey = '7349f9b7543947bdb0e214800251004';

  Future<List<Map<String, String>>> fetchForecastWithMoonPhases(String city) async {
    final url = Uri.parse('http://api.weatherapi.com/v1/forecast.xml?key=$apiKey&q=$city&days=14&aqi=no&alerts=no');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final days = document.findAllElements('forecastday');

        List<Map<String, String>> combinedList = [];

        for (var day in days) {
          String date = day.findElements('date').first.text;
          String moonPhase = day.findAllElements('moon_phase').isNotEmpty
              ? day.findAllElements('moon_phase').first.text
              : 'Unknown';
          String condition = day.findAllElements('text').isNotEmpty
              ? day.findAllElements('text').first.text
              : 'Unknown';
          String maxTempC = day.findAllElements('maxtemp_c').isNotEmpty
              ? day.findAllElements('maxtemp_c').first.text
              : '--';
          String minTempC = day.findAllElements('mintemp_c').isNotEmpty
              ? day.findAllElements('mintemp_c').first.text
              : '--';
          String maxTempF = day.findAllElements('maxtemp_f').isNotEmpty
              ? day.findAllElements('maxtemp_f').first.text
              : '--';
          String minTempF = day.findAllElements('mintemp_f').isNotEmpty
              ? day.findAllElements('mintemp_f').first.text
              : '--';
          String weekday = DateFormat('EEEE').format(DateTime.parse(date));

          combinedList.add({
            'day': weekday,
            'date': date,
            'moonPhase': moonPhase,
            'condition': condition,
            'maxTempC': maxTempC,
            'minTempC': minTempC,
            'maxTempF': maxTempF,
            'minTempF': minTempF,
          });
        }
        return combinedList;
      } else {
        return [{'error': 'Error: ${response.statusCode}'}];
      }
    } catch (e) {
      return [{'error': 'Exception: $e'}];
    }
  }

  Future<Map<String, String>> fetchCurrentWeather(String city) async {
    final url = Uri.parse('http://api.weatherapi.com/v1/current.xml?key=$apiKey&q=$city&aqi=yes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        String tempC = document.findAllElements('temp_c').first.text;
        String tempF = document.findAllElements('temp_f').first.text;
        String condition = document.findAllElements('condition').first.findElements('text').first.text;
        String windKph = document.findAllElements('wind_kph').first.text;
        String windMph = document.findAllElements('wind_mph').first.text;
        String humidity = document.findAllElements('humidity').first.text;
        String aqi = document.findAllElements('us-epa-index').isNotEmpty
            ? document.findAllElements('us-epa-index').first.text
            : 'N/A';

        return {
          'tempC': tempC,
          'tempF': tempF,
          'condition': condition,
          'windKph': windKph,
          'windMph': windMph,
          'humidity': humidity,
          'aqi': aqi,
        };
      } else {
        return {'error': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'Exception: $e'};
    }
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  String _location = "London";
  String _unitSystem = "metric";
  final WeatherService service = WeatherService();
  final List<Map<String, String>> forecastData = [];
  Map<String, String> currentWeather = {};
  bool isDataLoading = true;
  bool isCurrentLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeatherData();
  }

  void loadWeatherData() async {
    await loadForecastData();
    await loadCurrentWeather();
  }

  Future<void> loadForecastData() async {
    setState(() => isDataLoading = true);
    List<Map<String, String>> data = await service.fetchForecastWithMoonPhases(_location);

    setState(() {
      forecastData.clear();
      forecastData.addAll(data.where((entry) => !entry.containsKey('error')));
      isDataLoading = false;
    });
  }

  Future<void> loadCurrentWeather() async {
    setState(() => isCurrentLoading = true);
    Map<String, String> weather = await service.fetchCurrentWeather(_location);
    setState(() {
      currentWeather = weather;
      isCurrentLoading = false;
    });
  }

  void _updateSettings(String newLocation, String unitSystem) {
    setState(() {
      _location = newLocation;
      _unitSystem = unitSystem;
      loadWeatherData();
    });
  }

  Color _aqiColor(int aqi) {
    switch (aqi) {
      case 1: return Colors.green;
      case 2: return Colors.yellow;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      case 5: return Colors.purple;
      case 6: return Colors.brown;
      default: return Colors.grey;
    }
  }

  String _aqiLabel(int aqi) {
    switch (aqi) {
      case 1: return "Good";
      case 2: return "Moderate";
      case 3: return "Sensitive Groups";
      case 4: return "Unhealthy";
      case 5: return "Very Unhealthy";
      case 6: return "Hazardous";
      default: return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      isCurrentLoading
          ? Center(child: CircularProgressIndicator())
          : currentWeather.containsKey('error')
              ? Center(child: Text(currentWeather['error']!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/weathericon.png", width: 100, height: 100),
                      SizedBox(height: 10),
                      Text("Today's Weather in $_location", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 10),
                      Text(
                        "Temperature: ${_unitSystem == 'metric' ? '${currentWeather['tempC']!}°C' : '${currentWeather['tempF']!}°F'}",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      Text(
                        "Condition: ${currentWeather['condition']}",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      Text(
                        "Wind: ${_unitSystem == 'metric' ? '${currentWeather['windKph']!} kph' : '${currentWeather['windMph']!} mph'}",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      Text("Humidity: ${currentWeather['humidity']}%", style: TextStyle(fontSize: 18, color: Colors.green)),
                      SizedBox(height: 20),
                      Text("Air Quality Index (US-EPA): ${currentWeather['aqi']}", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: ((int.tryParse(currentWeather['aqi'] ?? '0') ?? 0) / 6).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _aqiColor(int.tryParse(currentWeather['aqi'] ?? '0') ?? 0),
                        ),
                        minHeight: 10,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Level: ${_aqiLabel(int.tryParse(currentWeather['aqi'] ?? '0') ?? 0)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
      isDataLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: forecastData.length,
              itemBuilder: (context, index) {
                final entry = forecastData[index];
                return MoonPhase(
                  day: entry['day']!,
                  date: entry['date']!,
                  phase: entry['moonPhase']!,
                );
              },
            ),
      isDataLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: forecastData.length,
              itemBuilder: (context, index) {
                final entry = forecastData[index];
                return ForecastCard(
                  day: entry['day']!,
                  date: entry['date']!,
                  condition: entry['condition']!,
                  maxTemp: _unitSystem == 'metric'
                      ? '${entry['maxTempC']!}°C'
                      : '${entry['maxTempF']!}°F',
                  minTemp: _unitSystem == 'metric'
                      ? '${entry['minTempC']!}°C'
                      : '${entry['minTempF']!}°F',
                );
              },
            ),
      SettingsScreen(
        onSettingsChanged: (location, unitSystem) {
          _updateSettings(location, unitSystem);
        },
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Weather&More")),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.brightness_2), label: "Moon Phases"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "14-Day Forecast"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final Function(String, String) onSettingsChanged;

  const SettingsScreen({required this.onSettingsChanged, super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedUnit = 'metric';
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Change Location", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter city',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_locationController.text.isNotEmpty) {
                  widget.onSettingsChanged(_locationController.text, selectedUnit);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Location updated to ${_locationController.text}")),
                  );
                }
              },
              child: Text('Update Location'),
            ),
            SizedBox(height: 30),
            Text("Select Units", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text('Metric (°C, kph)'),
              leading: Radio<String>(
                value: 'metric',
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('US (°F, mph)'),
              leading: Radio<String>(
                value: 'us',
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
