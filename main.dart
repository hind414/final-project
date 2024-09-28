import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Usage Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, dynamic>> _profiles = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  void _addProfile() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _profiles
            .add({'id': _profiles.length + 1, 'name': _nameController.text});
        _nameController.clear();
        _controller.forward().then((_) => _controller.reverse());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_profiles.last['name']} added!')),
      );
    }
  }

  void _viewProfile(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterUsageHomePage(profileId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profiles'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_add),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Add Profile'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0)
                        .animate(_controller),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      child: ListTile(
                        title: Text(_profiles[index]['name']),
                        leading: const Icon(Icons.person, size: 40),
                        onTap: () => _viewProfile(_profiles[index]['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterUsageHomePage extends StatefulWidget {
  final int profileId;

  const WaterUsageHomePage({super.key, required this.profileId});

  @override
  State<WaterUsageHomePage> createState() => _WaterUsageHomePageState();
}

class _WaterUsageHomePageState extends State<WaterUsageHomePage> {
  final _usageController = TextEditingController();
  String _recommendation = '';
  int _totalUsage = 0;

  void _submitUsage() {
    if (_usageController.text.isNotEmpty) {
      final input = int.tryParse(_usageController.text);
      if (input != null && input > 0) {
        setState(() {
          _totalUsage += input;
          _recommendation = _getRecommendation(_totalUsage);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usage of $input liters submitted!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a positive number.')),
        );
      }
      _usageController.clear();
    }
  }

  String _getRecommendation(int usage) {
    if (usage < 100) {
      return 'Great job! Keep up the low usage.';
    } else if (usage < 200) {
      return 'You are using a moderate amount of water. Consider reducing usage.';
    } else {
      return 'High usage detected! Here are some tips:\n- Fix leaks in your home.\n- Install low-flow fixtures.\n- Take shorter showers.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Usage Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usageController,
              decoration: const InputDecoration(
                labelText: 'Enter water usage (in liters)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitUsage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text('Submit Usage'),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Water Usage: $_totalUsage liters',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              _recommendation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
