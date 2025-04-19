import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YearToTimePage extends StatefulWidget {
  const YearToTimePage({super.key});

  @override
  State<YearToTimePage> createState() => _YearToTimePageState();
}

class _YearToTimePageState extends State<YearToTimePage> {
  final TextEditingController _yearController = TextEditingController();
  String _years = "0";
  BigInt _hours = BigInt.zero;
  BigInt _minutes = BigInt.zero;
  BigInt _seconds = BigInt.zero;

  void _convertYearToTime() {
    setState(() {
      try {
        // Sanitize input
        String input = _yearController.text.trim();

        // Replace comma with period for decimal
        input = input.replaceAll(',', '.');

        // Validate input
        if (input.isEmpty) {
          throw Exception('Input tidak boleh kosong');
        }

        // Validate if input is a negative number
        if (input.startsWith('-')) {
          throw Exception('Nilai tidak boleh negatif');
        }

        // Check if input is valid decimal or integer
        if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(input)) {
          throw Exception('Format angka tidak valid');
        }

        // Store the original input as the displayed years
        _years = input;

        // Convert input to double for calculation
        double years = double.parse(input);

        // Calculate total seconds directly using double precision
        // 1 year = 365.25 days * 24 hours * 60 minutes * 60 seconds
        double secondsInYear = 365.25 * 24 * 60 * 60;
        double totalSecondsDouble = years * secondsInYear;

        // Convert to BigInt for display
        BigInt totalSeconds = BigInt.from(totalSecondsDouble);

        // Calculate hours, minutes, seconds
        _seconds = totalSeconds;
        _minutes = totalSeconds ~/ BigInt.from(60);
        _hours =
            totalSeconds ~/ BigInt.from(3600); // 60*60 = 3600 seconds per hour
      } catch (e) {
        // Handle invalid input
        _years = "0";
        _hours = BigInt.zero;
        _minutes = BigInt.zero;
        _seconds = BigInt.zero;

        // Show appropriate error message
        String errorMsg = 'Masukkan angka yang valid';

        if (e.toString().contains('negatif')) {
          errorMsg = 'Nilai tahun tidak boleh negatif';
        } else if (e.toString().contains('kosong')) {
          errorMsg = 'Masukkan nilai tahun terlebih dahulu';
        } else if (e.toString().contains('Format')) {
          errorMsg = 'Format angka tidak valid';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.black54),
        );
      }
    });
  }

  String _formatBigInt(BigInt number) {
    // Convert BigInt to string
    String numString = number.toString();

    // Format with thousand separators
    List<String> parts = [];
    for (int i = numString.length; i > 0; i -= 3) {
      int start = i - 3 < 0 ? 0 : i - 3;
      parts.add(numString.substring(start, i));
    }
    return parts.reversed.join('.');
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Konversi Tahun ke Waktu'),
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
              "Konversi Waktu",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Konversi tahun ke jam, menit, dan detik",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Masukkan Tahun',
                hintText: 'Contoh: 1.5 atau 1000000',
                border: UnderlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                // Allow only numbers and one decimal point
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _convertYearToTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('KONVERSI'),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Hasil Konversi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildResultRow('Input Tahun', _years, 'tahun'),
                        const Divider(height: 24),
                        _buildResultRow('Jam', _formatBigInt(_hours), 'jam'),
                        const Divider(height: 24),
                        _buildResultRow(
                          'Menit',
                          _formatBigInt(_minutes),
                          'menit',
                        ),
                        const Divider(height: 24),
                        _buildResultRow(
                          'Detik',
                          _formatBigInt(_seconds),
                          'detik',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value $unit',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
