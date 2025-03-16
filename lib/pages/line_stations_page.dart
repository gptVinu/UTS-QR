import 'package:flutter/material.dart';
import '../data/database.dart';
import 'station_details_page.dart';

class LineStationsPage extends StatelessWidget {
  final String lineName;
  final Color lineColor;

  const LineStationsPage({
    Key? key,
    required this.lineName,
    required this.lineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get stations for this line from the database
    final stations = StationDatabase.getStationsByLine(lineName.split(' ')[0]);

    return Scaffold(
      appBar: AppBar(
        title: Text('$lineName Stations'),
        backgroundColor: lineColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: station['color'].withOpacity(0.2),
                foregroundColor: station['color'],
                child: Text(
                  station['code'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: station['color'],
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                station['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: station['line'].toString().contains('/')
                  ? Text('Interchange: ${station['line']}')
                  : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Get QR code path and navigate to details page
                final qrPath = station['qr'] as String?;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationDetailsPage(
                      name: station['name'],
                      code: station['code'],
                      line: station['line'],
                      color: station['color'],
                      qrImagePath: qrPath,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
