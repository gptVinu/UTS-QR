import 'package:flutter/material.dart';

class StationDetailsPage extends StatelessWidget {
  final String name;
  final String code;
  final String line;
  final Color color;
  final String? qrImagePath;

  const StationDetailsPage({
    super.key,
    required this.name,
    required this.code,
    required this.line,
    required this.color,
    this.qrImagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if this is Dadar station
    final isDadarStation = name.toLowerCase() == 'dadar';
    // Use a simpler path that's more likely to be correct based on your project structure
    final dadarQRImagePath = 'assets/dadar.png';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Station header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: color.withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Station Code: $code',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      line,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: color,
                  ),
                ],
              ),
            ),

            // QR code section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Scan this QR code at the station',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // QR Code
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: color, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildQRImage(
                          isDadarStation, dadarQRImagePath, context),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Station: $name ($code)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Additional information
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Station Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Line', line, Icons.train),
                    _buildInfoRow('Code', code, Icons.code),
                    if (line.contains('/'))
                      _buildInfoRow(
                          'Type', 'Interchange Station', Icons.swap_horiz),
                    _buildInfoRow('E-Ticket', 'Available', Icons.qr_code),
                  ],
                ),
              ),
            ),

            // Only share QR button at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity, // Make the button full width
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('SHARE QR CODE'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Sharing feature coming soon')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQRImage(
      bool isDadarStation, String dadarQRImagePath, BuildContext context) {
    if (isDadarStation) {
      // For Dadar station, try to load the specific image and handle any errors
      try {
        return Image.asset(
          dadarQRImagePath,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return _buildImageNotAvailable(color);
          },
        );
      } catch (e) {
        print('Exception while loading image: $e');
        return _buildImageNotAvailable(color);
      }
    } else if (qrImagePath != null) {
      // For other stations with qrImagePath
      return Image.asset(
        qrImagePath!,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _buildImageNotAvailable(color);
        },
      );
    } else {
      // Default placeholder
      return _buildPlaceholderQR(color);
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderQR(Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.qr_code_2,
          size: 80,
          color: color.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildImageNotAvailable(Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 60,
            color: color.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Image Not Available',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
