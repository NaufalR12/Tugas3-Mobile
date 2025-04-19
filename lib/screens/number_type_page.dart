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

      // Hapus semua titik
      String cleaned = text.replaceAll('.', '');

      // Ganti koma agar tetap koma (biar pengguna bisa ngetik desimal pakai koma)
      List<String> parts = cleaned.split(',');
      String numberPart = parts[0];
      String decimalPart = parts.length > 1 ? ',${parts[1]}' : '';

      // Format angka ribuan
      String newText =
          formatter.format(int.tryParse(numberPart) ?? 0) + decimalPart;

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
    // Bersihkan input (hilangkan titik, ubah koma ke titik)
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
        if (intValue >= 0) {
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
      appBar: AppBar(title: Text('Jenis Bilangan')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: 'Masukkan angka (gunakan koma untuk desimal)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => checkNumberType(_controller.text),
              child: Text('Cek Jenis'),
            ),
            SizedBox(height: 20),
            if (_formattedNumber.isNotEmpty)
              Text('Angka: $_formattedNumber', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(
              _result,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
