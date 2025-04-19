import 'package:flutter/material.dart';
import '../database/session_manager.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String _username = '';

  // Daftar bantuan penggunaan aplikasi
  final List<Map<String, dynamic>> _helpItems = [
    {
      'title': 'Cara Menggunakan Stopwatch',
      'description':
          'Panduan langkah demi langkah untuk menggunakan fitur stopwatch',
      'icon': Icons.watch,
      'steps': [
        'Tap tombol "Stopwatch" pada halaman Beranda',
        'Tekan tombol "Start" untuk memulai stopwatch',
        'Tekan tombol "Stop" untuk menghentikan stopwatch',
        'Gunakan tombol "Lap" untuk menandai waktu',
        'Tekan tombol "Reset" untuk mengatur ulang stopwatch ke 00:00:00',
      ],
    },
    {
      'title': 'Memeriksa Jenis Bilangan',
      'description': 'Cara menggunakan fitur pengecekan jenis bilangan',
      'icon': Icons.calculate,
      'steps': [
        'Tap tombol "Jenis Bilangan" pada halaman Beranda',
        'Masukkan angka yang ingin diperiksa pada kolom input',
        'Gunakan koma (,) jika ingin memasukkan angka desimal',
        'Tekan tombol "Cek Jenis" untuk melihat hasil',
        'Hasil akan menampilkan jenis bilangan seperti Prima, Bulat Positif, Cacah, atau Desimal',
      ],
    },
    {
      'title': 'Menggunakan Tracking LBS',
      'description': 'Panduan menggunakan fitur location based service',
      'icon': Icons.gps_fixed,
      'steps': [
        'Tap tombol "Tracking LBS" pada halaman Beranda',
        'Izinkan aplikasi mengakses lokasi Anda jika diminta',
        'Tunggu sistem mendapatkan lokasi Anda',
        'Lihat informasi lokasi sekarang dengan menekan tombol "Tracking"',
        'Gunakan fitur navigasi "Search" untuk mencari tempat dan "Marker" untuk menandainya',
      ],
    },
    {
      'title': 'Konversi Tahun ke Waktu',
      'description': 'Cara mengonversi tahun ke jam, menit, dan detik',
      'icon': Icons.access_time,
      'steps': [
        'Tap tombol "Konversi Tahun ke Waktu" pada halaman Beranda',
        'Masukkan jumlah tahun pada kolom input (bisa berupa angka desimal)',
        'Tekan tombol "KONVERSI" untuk memproses',
        'Lihat hasil konversi dalam jam, menit, dan detik',
        'Untuk input besar, hasil akan ditampilkan dengan pemisah ribuan',
      ],
    },
    {
      'title': 'Mengakses Rekomendasi Situs',
      'description': 'Cara melihat dan menggunakan rekomendasi situs',
      'icon': Icons.web,
      'steps': [
        'Tap tombol "Rekomendasi Situs" pada halaman Beranda',
        'Lihat daftar situs yang direkomendasikan',
        'Tap kartu situs untuk membuka situs dalam browser dalam aplikasi',
        'Gunakan tombol favorit (ikon hati) untuk menandai situs favorit',
        'Situs favorit akan disimpan meskipun aplikasi ditutup',
      ],
    },
    {
      'title': 'Manajemen Akun',
      'description': 'Cara mengelola akun pada aplikasi',
      'icon': Icons.person,
      'steps': [
        'Untuk mendaftar: Tekan "Belum punya akun? Daftar Sekarang" pada halaman login',
        'Isi username dan password yang diinginkan, lalu konfirmasi password',
        'Untuk login: Masukkan username dan password yang sudah terdaftar',
        'Untuk keluar: Tekan tombol logout (ikon keluar) pada pojok kanan bawah',
        'Konfirmasi pilihan saat dialog logout muncul',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await SessionManager.getLoggedInUserData();
    setState(() {
      _username = userData['username'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bantuan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        _username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bantuan Penggunaan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _helpItems.length,
                itemBuilder: (context, index) {
                  final item = _helpItems[index];
                  return _buildFeatureCard(
                    context: context,
                    title: item['title'],
                    description: item['description'],
                    icon: item['icon'],
                    onTap: () {
                      _showHelpDetails(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item['icon'], size: 24, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['title'],
                      style: const TextStyle(
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
              const SizedBox(height: 24),
              const Text(
                'Langkah-langkah Penggunaan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: item['steps'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item['steps'][index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: Colors.black),
              ),
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
