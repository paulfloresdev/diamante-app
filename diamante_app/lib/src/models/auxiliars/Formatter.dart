import 'package:intl/intl.dart';

class Formatter {
  static String money(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US', // Cambia a 'es_MX' si prefieres el formato mexicano
      symbol: '\$',   // Símbolo de moneda
      decimalDigits: 2, // Cantidad de decimales
    );

    return formatter.format(amount);
  }

  static String phoneNumber(String phone) {
  // Asegúrate de que el teléfono tenga 10 dígitos
  if (phone.length == 10) {
    // Formatear el número de teléfono en el formato (XXX) XXX-XXXX
    return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
  } else {
    return 'Número inválido';
  }
}

}
