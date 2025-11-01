import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Header(),
          SizedBox(height: 24),
          _BadgeSection(),
          SizedBox(height: 24),
          _SettingsSection(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 32, child: Icon(Icons.person)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('ليان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('المستوى: مبتدئ'),
          ],
        ),
      ],
    );
  }
}

class _BadgeSection extends StatelessWidget {
  const _BadgeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الشارات', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: const [
            Chip(label: Text('مواظب')), 
            Chip(label: Text('مستكشف')), 
            Chip(label: Text('صديق المشي')),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(leading: Icon(Icons.lock), title: Text('الخصوصية')), 
          Divider(height: 1),
          ListTile(leading: Icon(Icons.language), title: Text('اللغة')), 
          Divider(height: 1),
          ListTile(leading: Icon(Icons.notifications), title: Text('الإشعارات')),
        ],
      ),
    );
  }
}
