import 'package:intl/intl.dart';

/// Formats a numeric value as localized currency using the current locale.
String formatCurrency(num value, {String? locale}) {
  final formatter = NumberFormat.simpleCurrency(locale: locale);
  return formatter.format(value);
}

/// Formats a [DateTime] using the provided pattern (defaults to `MM/dd/yyyy`).
String formatDate(
  DateTime date, {
  String pattern = 'MM/dd/yyyy',
  String? locale,
}) {
  return DateFormat(pattern, locale).format(date);
}

/// Formats a nullable [DateTime], falling back to [placeholder] when null.
String formatDateOrPlaceholder(
  DateTime? date, {
  String placeholder = '—',
  String pattern = 'MM/dd/yyyy',
  String? locale,
}) {
  if (date == null) {
    return placeholder;
  }
  return formatDate(date, pattern: pattern, locale: locale);
}
