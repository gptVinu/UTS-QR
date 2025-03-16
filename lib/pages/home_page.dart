import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'search_page.dart';
import 'admin_page.dart';
import '../data/database.dart';
import '../services/station_service.dart';
import 'line_stations_page.dart';
import 'station_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _trainAnimation;

  final List<Widget> _pages = [
    const HomeContent(),
    const SearchContent(),
    const SettingsContent(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _trainAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: const Offset(1.2, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        title: Row(
          children: [
            Text(
              'UTS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 24,
                child: SlideTransition(
                  position: _trainAnimation,
                  child: const Icon(
                    Icons.train,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Get train lines and popular stations from database
    final trainLines = StationDatabase.trainLines;
    final popularStations = StationDatabase.getPopularStations();

    // Fix overflow by improving the layout
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Mumbai Local Train Lines',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                // Increase aspect ratio to give more height
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return EnhancedTrainLineCard(
                    name: trainLines[index]['name'] as String,
                    color: trainLines[index]['color'] as Color,
                    icon: trainLines[index]['icon'] as IconData,
                    stations: trainLines[index]['stations'] as String,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LineStationsPage(
                            lineName: trainLines[index]['name'] as String,
                            lineColor: trainLines[index]['color'] as Color,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: trainLines.length,
              ),
            ),
          ),
          // Popular Stations Header with View All button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Stations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllStationsPage(
                            stations: popularStations,
                          ),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          // Horizontal scrolling stations with fixed width
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: popularStations.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 75, // Fixed width for consistent spacing
                    child: StationCircleItem(
                      name: popularStations[index]['name'] as String,
                      icon: popularStations[index]['icon'] as IconData,
                      color: popularStations[index]['color'] as Color,
                    ),
                  );
                },
              ),
            ),
          ),
          // Add Station Counter Animation
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: StationCounterAnimation(),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced card with better visuals
class EnhancedTrainLineCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final String stations;
  final VoidCallback? onTap;

  const EnhancedTrainLineCard({
    super.key,
    required this.name,
    required this.color,
    required this.icon,
    required this.stations,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias, // Ensures the gradient doesn't overflow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name selected')),
              );
            },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
          ),
          child: Padding(
            // Reduce padding to fit content better
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Make column only as big as needed
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32, // Slightly smaller icon
                  color: Colors.white,
                ),
                const SizedBox(height: 6), // Reduce spacing
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15, // Smaller font
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3), // Reduce spacing
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2), // Reduce padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    stations,
                    style: const TextStyle(
                      fontSize: 11, // Smaller font
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Station Counter Animation Widget
class StationCounterAnimation extends StatefulWidget {
  const StationCounterAnimation({super.key});

  @override
  State<StationCounterAnimation> createState() =>
      _StationCounterAnimationState();
}

class _StationCounterAnimationState extends State<StationCounterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;
  int _totalStations = StationDatabase.allStations.length;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _countAnimation =
        Tween<double>(begin: 0, end: _totalStations.toDouble()).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadStationCount();
  }

  Future<void> _loadStationCount() async {
    try {
      final stationService = StationService();
      await stationService.initialize();
      final count = await stationService.getStationCount();
      if (mounted) {
        setState(() {
          _totalStations = count;
          _isLoading = false;
          _countAnimation =
              Tween<double>(begin: 0, end: _totalStations.toDouble()).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
            ),
          );
          _controller.forward();
        });
      }
    } catch (e) {
      print('Error loading station count: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
            Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Text(
            'Mumbai Railway Network',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Counter section with flexible layout
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon in circle
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                // Counter with digits or loading indicator
                Flexible(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _countAnimation,
                          builder: (context, child) {
                            final value = _countAnimation.value.toInt();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Total Stations',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Tagline with connection status
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FutureBuilder<ConnectivityResult>(
              future: Connectivity().checkConnectivity(),
              builder: (context, snapshot) {
                final isOnline = snapshot.data != ConnectivityResult.none;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 14,
                      color: isOnline ? Colors.green[200] : Colors.orange[200],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Connected to live data' : 'Using cached data',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Station circle item for horizontal scrolling
class StationCircleItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const StationCircleItem({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Format station name if needed
    String displayName = name;
    if (name.length > 8) {
      final nameParts = name.split(' ');
      if (nameParts.length > 1) {
        // For names with spaces, use abbreviation
        displayName = '${nameParts[0]} ${nameParts[1][0]}.';
      } else if (name.length > 10) {
        // For long single words, truncate with ellipsis
        displayName = '${name.substring(0, 7)}...';
      }
    }

    return InkWell(
      onTap: () {
        // Navigate to station details page when tapped
        final station = StationDatabase.allStations.firstWhere(
          (s) => s['name'] == name,
          orElse: () => {'name': name, 'code': '', 'line': '', 'color': color},
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StationDetailsPage(
              name: station['name'] as String,
              code: station['code'] as String,
              line: station['line'] as String,
              color: station['color'] as Color,
              qrImagePath: station['qr'] as String?,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// All Stations Page that shows when "View All" is clicked
class AllStationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> stations;

  const AllStationsPage({
    super.key,
    required this.stations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Stations'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.75,
        ),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          return StationGridItem(
            name: stations[index]['name'] as String,
            icon: stations[index]['icon'] as IconData,
            color: stations[index]['color'] as Color,
          );
        },
      ),
    );
  }
}

// Station item for grid view in All Stations page
class StationGridItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const StationGridItem({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to station details page when tapped
        final station = StationDatabase.allStations.firstWhere(
          (s) => s['name'] == name,
          orElse: () => {'name': name, 'code': '', 'line': '', 'color': color},
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StationDetailsPage(
              name: station['name'] as String,
              code: station['code'] as String,
              line: station['line'] as String,
              color: station['color'] as Color,
              qrImagePath: station['qr'] as String?,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SearchContent extends StatelessWidget {
  const SearchContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchPage();
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPage();
  }
}
