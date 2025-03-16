import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import 'admin_dashboard.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Add a static variable to track the current security key
  // static String currentSecurityKey = "lucifer";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.isDarkMode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with settings title
          SliverAppBar(
            backgroundColor: colorScheme.primary,
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main settings content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme mode toggle
                _buildThemeToggleCard(isDarkMode, themeManager),

                // Admin section
                _buildSectionHeader('Admin'),
                _buildAdminSection(isDarkMode),

                // About section
                _buildSectionHeader('About'),
                _buildAboutSection(isDarkMode),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleCard(bool isDarkMode, ThemeManager themeManager) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Use Flexible to allow text to shrink if needed
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        size: 24,
                        color: isDarkMode ? Colors.amber : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isDarkMode ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeManager.toggleTheme(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${value ? 'Dark' : 'Light'} mode activated'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAdminSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Administrator login
          _buildOptionTile(
            icon: Icons.admin_panel_settings,
            title: 'Administrator Login',
            subtitle: 'Login to access admin features',
            isDarkMode: isDarkMode,
            onTap: () {
              _showLoginDialog();
            },
          ),
          const Divider(height: 1),

          // Security Key Management (combined option)
          _buildOptionTile(
            icon: Icons.security,
            title: 'Security Key Management',
            subtitle: 'Update or reset your security key',
            isDarkMode: isDarkMode,
            onTap: () {
              _showSecurityKeyOptions();
            },
          ),
        ],
      ),
    );
  }

  // Show a bottom sheet with security key management options
  void _showSecurityKeyOptions() {
    final isDarkMode =
        Provider.of<ThemeManager>(context, listen: false).isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.4, // Take up 40% of the screen
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    children: [
                      Icon(Icons.security,
                          color: colorScheme.primary, size: 28),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Security Key Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Security key options - Use ListView instead of Column to handle overflow
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Update Security Key option
                      _buildSecurityOptionCard(
                        icon: Icons.security_update,
                        title: 'Update Security Key',
                        description: 'Change your current admin security key',
                        buttonText: 'UPDATE KEY',
                        onTap: () {
                          Navigator.pop(context);
                          _showUpdateSecurityKeyDialog();
                        },
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 16),

                      // Forgot Security Key option
                      _buildSecurityOptionCard(
                        icon: Icons.help_outline,
                        title: 'Forgot Security Key',
                        description:
                            'Reset your security key with verification question',
                        buttonText: 'RESET KEY',
                        onTap: () {
                          Navigator.pop(context);
                          _showForgotSecurityKeyDialog();
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget for security option cards - Fixed to prevent overflow
  Widget _buildSecurityOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Text content with constraints - Wrap in Flexible
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Button - Use constraints
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 60),
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(40, 36),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(buttonText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App version
          _buildOptionTile(
            icon: Icons.info_outline,
            title: 'App Version',
            isDarkMode: isDarkMode,
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
            onTap: () => _showAppVersionInfo(),
          ),
          const Divider(height: 1),

          // Terms of service
          _buildOptionTile(
            icon: Icons.gavel,
            title: 'Terms of Service',
            isDarkMode: isDarkMode,
            onTap: () => _showTermsOfService(),
          ),
          const Divider(height: 1),

          // Privacy policy
          _buildOptionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            isDarkMode: isDarkMode,
            onTap: () => _showPrivacyPolicy(),
          ),
          const Divider(height: 1),

          // Contact support
          _buildOptionTile(
            icon: Icons.support_agent,
            title: 'Contact Support',
            isDarkMode: isDarkMode,
            onTap: () => _showContactSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 22),
      onTap: onTap,
    );
  }

  void _showLoginDialog() {
    final securityKeyController = TextEditingController();
    bool isLoading = false;
    bool isError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.security,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Authentication',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter the security key to access admin features',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: securityKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Security Key',
                      prefixIcon: const Icon(Icons.vpn_key),
                      errorText: isError ? 'Invalid security key' : null,
                      border: const OutlineInputBorder(),
                      hintText: '••••••••',
                    ),
                    onChanged: (_) {
                      if (isError) {
                        setState(() {
                          isError = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.lock_open),
                            label: const Text('AUTHENTICATE'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                isError = false;
                              });

                              // Verify the security key
                              Future.delayed(const Duration(seconds: 1), () {
                                final securityKey = securityKeyController.text;

                                if (securityKey == "lucifer") {
                                  Navigator.of(context).pop();
                                  _navigateToAdminDashboard();
                                } else {
                                  setState(() {
                                    isLoading = false;
                                    isError = true;
                                  });
                                }
                              });
                            },
                          ),
                        ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _navigateToAdminDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminDashboard(),
      ),
    );
  }

  // New methods for showing bottom sheets with content
  void _showAppVersionInfo() {
    _showBottomSheet(
      title: 'App Version Details',
      icon: Icons.info_outline,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Version', '1.0.0'),
          _infoRow('Build Number', '2023112501'),
          _infoRow('Release Date', 'March 16, 2025'),
          _infoRow('Platform', 'Android & iOS'),
          const SizedBox(height: 16),
          const Text('Release Notes:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('• Initial release with core functionality'),
          const Text('• Basic admin dashboard features'),
          const Text('• User authentication system'),
          const Text('• Light and dark theme support'),
          const SizedBox(height: 16),
          const Text('Upcoming Features:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('• Enhanced reporting system'),
          const Text('• User management improvements'),
          const Text('• Advanced analytics dashboard'),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    _showBottomSheet(
      title: 'Terms of Service',
      icon: Icons.gavel,
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. Acceptance of Terms',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'By accessing or using our app, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not use our services.',
          ),
          SizedBox(height: 16),
          Text(
            '2. User Accounts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Users are responsible for maintaining the confidentiality of their accounts and passwords. Please notify us immediately of any unauthorized use of your account.',
          ),
          SizedBox(height: 16),
          Text(
            '3. Content Guidelines',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Users agree not to use the platform for any unlawful purposes or to conduct any unlawful activity, including harassment, defamation, or spreading harmful content.',
          ),
          SizedBox(height: 16),
          Text(
            '4. Limitation of Liability',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'The app and its services are provided "as is" without warranties of any kind. In no event shall we be liable for any damages resulting from the use of our platform.',
          ),
          SizedBox(height: 16),
          Text(
            '5. Changes to Terms',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'We reserve the right to modify these terms at any time. We will notify users of significant changes through the app or by other means.',
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    _showBottomSheet(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. Data Collection',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'We collect personal information that you voluntarily provide when using our app, including but not limited to your name, email address, and usage data.',
          ),
          SizedBox(height: 16),
          Text(
            '2. Use of Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'We use collected information to provide and improve our services, personalize user experience, and communicate with users about updates or support.',
          ),
          SizedBox(height: 16),
          Text(
            '3. Data Security',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'We implement industry-standard security measures to protect your personal data from unauthorized access, disclosure, or destruction.',
          ),
          SizedBox(height: 16),
          Text(
            '4. Third-Party Services',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices or content of these third parties.',
          ),
          SizedBox(height: 16),
          Text(
            '5. Your Rights',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'You have the right to access, correct, or delete your personal data. Contact our support team to exercise these rights.',
          ),
        ],
      ),
    );
  }

  void _showContactSupport() {
    _showBottomSheet(
      title: 'Contact Support',
      icon: Icons.support_agent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We\'re here to help! Choose your preferred contact method:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          _contactMethod(
            icon: Icons.email_outlined,
            title: 'Email Support',
            details: 'support@utsapp.com',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening email client...')),
              );
              // Add email launcher code here
            },
          ),
          const SizedBox(height: 16),
          _contactMethod(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            details: '+1 (555) 123-4567',
            subtitle: 'Available Mon-Fri, 9AM-5PM EST',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening phone dialer...')),
              );
              // Add phone dialer code here
            },
          ),
          const SizedBox(height: 16),
          _contactMethod(
            icon: Icons.chat_outlined,
            title: 'Live Chat',
            details: 'Start a conversation now',
            subtitle: 'Typically replies within minutes',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening live chat...')),
              );
              // Add chat launcher code here
            },
          ),
          const SizedBox(height: 16),
          _contactMethod(
            icon: Icons.help_outline,
            title: 'FAQ & Help Center',
            details: 'Browse common questions and answers',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening help center...')),
              );
              // Add help center navigation code here
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Support Ticket',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'For complex issues, please submit a support ticket and our team will get back to you within 24 hours.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.new_label_outlined),
              label: const Text('CREATE SUPPORT TICKET'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating support ticket...')),
                );
                // Add ticket creation logic here
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for contact methods
  Widget _contactMethod({
    required IconData icon,
    required String title,
    required String details,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  // Helper widget for version info rows
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // Reusable bottom sheet that covers 75% of screen from bottom
  void _showBottomSheet({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    final isDarkMode =
        Provider.of<ThemeManager>(context, listen: false).isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important to allow custom sizing
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // This makes the bottom sheet take up 75% of the screen height
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar for drag
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header with icon and title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Icon(icon, color: colorScheme.primary, size: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateSecurityKeyDialog() {
    final currentKeyController = TextEditingController();
    final newKeyController = TextEditingController();
    final confirmKeyController = TextEditingController();
    bool isLoading = false;
    bool isError = false;
    String errorText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.security_update,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'Update Security Key',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your current security key and set a new one',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current security key
                  TextField(
                    controller: currentKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Security Key',
                      prefixIcon: Icon(Icons.vpn_key),
                      border: OutlineInputBorder(),
                      hintText: '••••••••',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New security key
                  TextField(
                    controller: newKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Security Key',
                      prefixIcon: Icon(Icons.key),
                      border: OutlineInputBorder(),
                      hintText: '••••••••',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm new security key
                  TextField(
                    controller: confirmKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Security Key',
                      prefixIcon: Icon(Icons.key),
                      border: OutlineInputBorder(),
                      hintText: '••••••••',
                    ),
                  ),

                  if (isError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        errorText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.update),
                            label: const Text('UPDATE KEY'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                isError = false;
                              });

                              // Verify and update the security key
                              Future.delayed(const Duration(seconds: 1), () {
                                final currentKey = currentKeyController.text;
                                final newKey = newKeyController.text;
                                final confirmKey = confirmKeyController.text;

                                // Verify current key
                                if (currentKey != "lucifer") {
                                  setState(() {
                                    isLoading = false;
                                    isError = true;
                                    errorText =
                                        'Current security key is incorrect';
                                  });
                                  return;
                                }

                                // Verify new keys match
                                if (newKey != confirmKey) {
                                  setState(() {
                                    isLoading = false;
                                    isError = true;
                                    errorText = 'New keys do not match';
                                  });
                                  return;
                                }

                                // Verify new key is not empty
                                if (newKey.isEmpty) {
                                  setState(() {
                                    isLoading = false;
                                    isError = true;
                                    errorText =
                                        'New security key cannot be empty';
                                  });
                                  return;
                                }

                                // Here you would update the security key in your database
                                // For this example, we'll just show a success message

                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Security key updated successfully'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showForgotSecurityKeyDialog() {
    final securityQuestionController = TextEditingController();
    final newKeyController = TextEditingController();
    final confirmKeyController = TextEditingController();
    bool isLoading = false;
    bool isError = false;
    String errorText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.help_outline,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'Reset Security Key',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answer the security question to reset your key',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Security question
                  const Text(
                    'Security Question:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'What is the name of your favorite teacher?',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),

                  // Answer to security question
                  TextField(
                    controller: securityQuestionController,
                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      prefixIcon: Icon(Icons.question_answer),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New security key (shown only after verification)
                  AnimatedOpacity(
                    opacity: isLoading ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: newKeyController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'New Security Key',
                            prefixIcon: Icon(Icons.key),
                            border: OutlineInputBorder(),
                            hintText: '••••••••',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm new security key
                        TextField(
                          controller: confirmKeyController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm New Security Key',
                            prefixIcon: Icon(Icons.key),
                            border: OutlineInputBorder(),
                            hintText: '••••••••',
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        errorText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.restore),
                            label: const Text('RESET SECURITY KEY'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                isError = false;
                              });

                              // Verify security answer and reset the key
                              Future.delayed(const Duration(seconds: 1), () {
                                final securityAnswer =
                                    securityQuestionController.text.trim();
                                final newKey = newKeyController.text;
                                final confirmKey = confirmKeyController.text;

                                // Verify security answer
                                if (securityAnswer.toLowerCase() !=
                                    "ramdhari pathak".toLowerCase()) {
                                  setState(() {
                                    isLoading = false;
                                    isError = true;
                                    errorText = 'Incorrect security answer';
                                  });
                                  return;
                                }

                                // Verify new keys match
                                if (newKey != confirmKey) {
                                  setState(() {
                                    isLoading = false;
                                    isError = true;
                                    errorText = 'New keys do not match';
                                  });
                                  return;
                                }

                                // Verify new key is not empty
                                if (newKey.isEmpty) {
                                  setState(() {
                                    isLoading = false;
                                    isError = true;
                                    errorText =
                                        'New security key cannot be empty';
                                  });
                                  return;
                                }

                                // Here you would update the security key in your database
                                // For this example, we'll just show a success message

                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Security key reset successfully'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
