/// Demo version of RivalX app without Firebase dependencies
/// 
/// This simplified version showcases the UI theme and basic
/// app structure for testing purposes.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rivalx/config/theme.dart';

/// Demo main function for testing UI without Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure system UI overlay style for consistent theming
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const RivalXDemoApp());
}

/// Demo root widget
class RivalXDemoApp extends StatelessWidget {
  const RivalXDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RivalX Demo',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const DemoHomeScreen(),
    );
  }
}

/// Demo home screen showcasing RivalX theme
class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RivalX'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to RivalX',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                'COMPETE. CONQUER. REPEAT.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rank Demo
            Text(
              'Rank System',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRankChip('E', AppTheme.rankE),
                _buildRankChip('D', AppTheme.rankD),
                _buildRankChip('C', AppTheme.rankC),
                _buildRankChip('B', AppTheme.rankB),
                _buildRankChip('A', AppTheme.rankA),
                _buildRankChip('S', AppTheme.rankS),
                _buildRankChip('SS', AppTheme.rankSS),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Buttons Demo
            Text(
              'Buttons',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start Workout'),
            ),
            
            const SizedBox(height: 8),
            
            OutlinedButton(
              onPressed: () {},
              child: const Text('View Profile'),
            ),
            
            const SizedBox(height: 8),
            
            TextButton(
              onPressed: () {},
              child: const Text('Settings'),
            ),
            
            const SizedBox(height: 24),
            
            // Input Demo
            Text(
              'Input Fields',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            
            const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
              ),
            ),
            
            const SizedBox(height: 12),
            
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Demo
            Text(
              'Stats Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '1,250',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.accentYellow,
                            ),
                          ),
                          Text(
                            'Total Points',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'A',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.rankA,
                            ),
                          ),
                          Text(
                            'Current Rank',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Rivals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildRankChip(String rank, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        rank,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}