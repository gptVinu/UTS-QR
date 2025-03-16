import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../data/database.dart';
import 'station_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> filteredStations = [];
  bool _isSearching = false;
  bool _isListening = false;

  // Animation controller for voice recognition
  late AnimationController _animationController;

  // List of all stations available for search
  late List<Map<String, dynamic>> allStations;

  // Voice recognition samples
  late List<String> _voiceRecognitionResults;

  @override
  void initState() {
    super.initState();
    // Get stations from database
    allStations = StationDatabase.getAllStationsForSearch();
    _voiceRecognitionResults = StationDatabase.voiceRecognitionSamples;

    filteredStations = List.from(allStations);
    _searchController.addListener(_onSearchChanged);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Request focus on the search field when the page loads
    Future.delayed(const Duration(milliseconds: 500), () {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterStations(_searchController.text);
  }

  void _filterStations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStations = List.from(allStations);
        _isSearching = false;
      } else {
        _isSearching = true;
        filteredStations = allStations
            .where((station) =>
                station['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                station['code']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                station['line']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _startVoiceSearch() {
    setState(() {
      _isListening = true;
    });

    _animationController.reset();
    _animationController.repeat();

    // Simulate voice recognition with delay
    final random = Random();
    final resultIndex = random.nextInt(_voiceRecognitionResults.length);
    final recognizedText = _voiceRecognitionResults[resultIndex];

    // Simulate processing time (2-3 seconds)
    Timer(Duration(milliseconds: 2000 + random.nextInt(1000)), () {
      if (mounted) {
        setState(() {
          _searchController.text = recognizedText;
          _filterStations(recognizedText);
          _isListening = false;
        });
        _animationController.stop();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      filteredStations = List.from(allStations);
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 80,
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(_isSearching ? 0.1 : 0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.center,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(25),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: _isListening ? 'Listening...' : 'Search stations',
                  hintStyle: TextStyle(
                    color: _isListening ? Colors.redAccent : Colors.grey[500],
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: _clearSearch,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            maxWidth: 32,
                          ),
                        ),
                      IconButton(
                        icon: _isListening
                            ? _buildListeningAnimation()
                            : const Icon(Icons.mic),
                        onPressed: _isListening ? null : _startVoiceSearch,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          maxWidth: 40,
                        ),
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterStations,
              ),
            ),
          ),

          // Voice recognition overlay when active
          if (_isListening)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildListeningAnimation(size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    "Listening for station name...",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

          // Results section
          Expanded(
            child: filteredStations.isEmpty
                ? const Center(
                    child: Text(
                      'No stations found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ListView.builder(
                      key: ValueKey<int>(filteredStations.length),
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = filteredStations[index];
                        return StationListItem(
                          name: station['name'] as String,
                          code: station['code'] as String,
                          line: station['line'] as String,
                          color: station['color'] as Color,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningAnimation({double size = 24}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Offset the animations for each bar
            final animation = Tween<double>(begin: 0.3, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index * 0.2,
                  0.6 + index * 0.2,
                  curve: Curves.easeInOut,
                ),
              ),
            );

            return Container(
              margin: EdgeInsets.symmetric(horizontal: size * 0.1),
              width: size * 0.2,
              height: size * animation.value,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            );
          }),
        );
      },
    );
  }
}

class StationListItem extends StatelessWidget {
  final String name;
  final String code;
  final String line;
  final Color color;

  const StationListItem({
    super.key,
    required this.name,
    required this.code,
    required this.line,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            foregroundColor: color,
            radius: 24,
            child: Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.train,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Get QR code path from database and navigate to details
            final station = StationDatabase.allStations.firstWhere(
              (s) => s['name'] == name,
              orElse: () => {'qr': null},
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StationDetailsPage(
                  name: name,
                  code: code,
                  line: line,
                  color: color,
                  qrImagePath: station['qr'] as String?,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
