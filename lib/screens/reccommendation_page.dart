import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final List<Map<String, dynamic>> _websites = [
    {
      'title': 'Flutter',
      'url': 'https://flutter.dev',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
      'favorite': false,
    },
    {
      'title': 'Dart',
      'url': 'https://dart.dev',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/f/fe/Dart_programming_language_logo.svg',
      'favorite': false,
    },
    {
      'title': 'Stack Overflow',
      'url': 'https://stackoverflow.com',
      'image':
          'https://cdn.sstatic.net/Sites/stackoverflow/company/img/logos/so/so-logo.png',
      'favorite': false,
    },
    {
      'title': 'GitHub',
      'url': 'https://github.com',
      'image':
          'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
      'favorite': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Load favorite status from SharedPreferences
  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < _websites.length; i++) {
        String key = 'favorite_${_websites[i]['title']}';
        _websites[i]['favorite'] = prefs.getBool(key) ?? false;
      }
    });
  }

  // Save favorite status to SharedPreferences
  Future<void> _saveFavorite(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'favorite_${_websites[index]['title']}';
    await prefs.setBool(key, _websites[index]['favorite']);
  }

  void _toggleFavorite(int index) {
    setState(() {
      _websites[index]['favorite'] = !_websites[index]['favorite'];
      _saveFavorite(index);
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (!await canLaunchUrl(uri)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka URL')),
          );
        }
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rekomendasi Website'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daftar Website",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Kumpulan website yang direkomendasikan untuk kamu!",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: _websites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final site = _websites[index];
                  return _buildWebsiteCard(site, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteCard(Map<String, dynamic> site, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _launchURL(site['url']),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container - Now takes full width with proper height
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  site['image'],
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(Icons.public, size: 80, color: Colors.grey),
                      ),
                ),
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          site['url'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      site['favorite'] ? Icons.favorite : Icons.favorite_border,
                      color: site['favorite'] ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () => _toggleFavorite(index),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
