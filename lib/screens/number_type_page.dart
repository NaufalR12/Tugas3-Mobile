import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberTypePage extends StatefulWidget {
  const NumberTypePage({super.key});

  @override
  _NumberTypePageState createState() => _NumberTypePageState();
}

class _NumberTypePageState extends State<NumberTypePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _formattedNumber = '';

  final formatter = NumberFormat.decimalPattern('id_ID');

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      String text = _controller.text;

      if (text == '-' || text.isEmpty) {
        // Kalau cuma '-' atau kosong, jangan format apa-apa
        return;
      }

      // Hapus semua titik
      String cleaned = text.replaceAll('.', '');

      // Pisahkan angka dan desimal
      List<String> parts = cleaned.split(',');
      String numberPart = parts[0];
      String decimalPart = parts.length > 1 ? ',${parts[1]}' : '';

      // Cek apakah ada tanda minus di depan
      bool isNegative = numberPart.startsWith('-');
      String digitsOnly = numberPart.replaceAll('-', '');

      if (digitsOnly.isEmpty) {
        digitsOnly = '0';
      }

      String formattedNumber = formatter.format(int.parse(digitsOnly));
      String newText = (isNegative ? '-' : '') + formattedNumber + decimalPart;

      if (newText != text) {
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    });
  }

  bool isPrime(int number) {
    if (number <= 1) return false;
    for (int i = 2; i <= number ~/ 2; i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  void checkNumberType(String input) {
    String normalized = input.replaceAll('.', '').replaceAll(',', '.');
    final num? value = num.tryParse(normalized);

    if (value == null) {
      setState(() {
        _result = 'Bukan angka';
        _formattedNumber = '';
      });
    } else {
      _formattedNumber = formatter.format(value);

      String type = '';
      if (value is int || value == value.toInt()) {
        int intValue = value.toInt();
        if (isPrime(intValue)) type += 'Prima, ';
        if (intValue == 0) {
          type += 'Bulat, Cacah, ';
        } else if (intValue > 0) {
          type += 'Bulat Positif, Cacah, ';
        } else {
          type += 'Bulat Negatif, ';
        }
      } else {
        type += 'Desimal, ';
      }
      setState(() {
        _result = type.trim().replaceAll(RegExp(r',\s*$'), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jenis Bilangan')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Masukkan angka (gunakan koma untuk desimal)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => checkNumberType(_controller.text),
              child: const Text('Cek Jenis'),
            ),
            const SizedBox(height: 20),
            if (_formattedNumber.isNotEmpty)
              Text(
                'Angka: $_formattedNumber',
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 10),
            Text(
              _result,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
