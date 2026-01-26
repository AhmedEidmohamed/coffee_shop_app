import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('profile')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 30),
            _buildSettingsSection(context, themeProvider, languageProvider),
            const SizedBox(height: 30),
            _buildOtherOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: const Color(0xFF6F4E37), width: 3),
              ),
              child: profileProvider.profileImage != null
                  ? ClipOval(
                      child: Image.network(
                        profileProvider.profileImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              profileProvider.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              profileProvider.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F4E37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                child: Text(tr('edit_profile')),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('settings'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: tr('dark_mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              activeColor: const Color(0xFF6F4E37),
            ),
          ),
          const Divider(height: 30),
          _buildSettingItem(
            icon: Icons.language,
            title: tr('language'),
            trailing: DropdownButton<String>(
              value: languageProvider.isArabic ? 'ar' : 'en',
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(tr('english')),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text(tr('arabic')),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  languageProvider.changeLanguage(value);
                  // استخدم context.setLocale بدلاً من EasyLocalization.of(context)
                  context.setLocale(Locale(value));
                }
              },
              underline: const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6F4E37)),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildOtherOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionItem(
            icon: Icons.payment,
            title: tr('payment_methods'),
            onTap: () {},
          ),
          const Divider(),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: tr('help'),
            onTap: () {},
          ),
          const Divider(),
          _buildOptionItem(
            icon: Icons.logout,
            title: tr('logout'),
            onTap: () {},
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF6F4E37)),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}