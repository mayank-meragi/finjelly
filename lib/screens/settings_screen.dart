import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _autoSyncEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('tmdb_api_key') ?? '';
    final autoSync = prefs.getBool('auto_sync_metadata') ?? true;
    setState(() {
      _apiKeyController.text = apiKey;
      _autoSyncEnabled = autoSync;
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tmdb_api_key', _apiKeyController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TMDB Configuration',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _apiKeyController,
            decoration: InputDecoration(
              labelText: 'TMDB API Key',
              hintText: 'Enter your TMDB API key',
              helperText: 'Get a free key at themoviedb.org/settings/api',
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
              suffixIcon: _isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            obscureText: true,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveApiKey,
            icon: const Icon(Icons.save),
            label: const Text('Save API Key'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto-sync metadata'),
            subtitle: const Text(
              'Automatically sync metadata when viewing libraries',
            ),
            value: _autoSyncEnabled,
            onChanged: (value) async {
              setState(() => _autoSyncEnabled = value);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('auto_sync_metadata', value);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Auto-sync enabled' : 'Auto-sync disabled',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About TMDB Integration'),
            subtitle: const Text(
              'The Movie Database (TMDB) is used to fetch additional metadata like budget, revenue, cast, and crew information for your media.',
            ),
          ),
        ],
      ),
    );
  }
}
