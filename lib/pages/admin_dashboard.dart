import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import 'station_management_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Admin welcome card
          Card(
            elevation: 4,
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        radius: 24,
                        child: const Icon(Icons.admin_panel_settings, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome, Admin',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Last login: ${DateTime.now().toString().substring(0, 16)}',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    'System Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusItem('Servers', 'Online', Colors.green),
                  _buildStatusItem('Database', 'Online', Colors.green),
                  _buildStatusItem('API', 'Online', Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Admin tools section
          Text(
            'Admin Tools',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _buildAdminToolCard(
            context,
            'Station Management',
            Icons.edit_location_alt,
            'Add, edit or remove stations',
            colorScheme.primary,
            isDarkMode,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StationManagementPage()),
              );
            },
          ),
          _buildAdminToolCard(
            context,
            'User Management',
            Icons.people,
            'Manage app users and permissions',
            colorScheme.secondary,
            isDarkMode,
          ),
          _buildAdminToolCard(
            context,
            'System Logs',
            Icons.analytics,
            'View app analytics and error logs',
            Colors.orange,
            isDarkMode,
          ),
          _buildAdminToolCard(
            context,
            'App Settings',
            Icons.settings,
            'Configure application settings',
            Colors.purple,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String name, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor,
                radius: 5,
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminToolCard(BuildContext context, String title, IconData icon,
      String description, Color color, bool isDarkMode,
      {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          radius: 24,
          child: Icon(icon, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $title')),
              );
            },
      ),
    );
  }
}
