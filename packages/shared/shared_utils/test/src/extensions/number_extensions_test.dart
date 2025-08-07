import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_utils/src/extensions/number_extensions.dart';

void main() {
  group('CurrencyExt', () {
    testWidgets('formats currency with context locale (currency codes)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
          ],
          home: Builder(
            builder: (context) {
              const price = 1234.56;
              final formatted = price.toCurrency(context);

              expect(formatted, contains('BRL'));
              expect(formatted, contains('1.234,56'));

              return Container();
            },
          ),
        ),
      );
    });

    testWidgets(
      'formats simple currency with context locale (currency symbols)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('pt', 'BR'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'),
              Locale('en', 'US'),
            ],
            home: Builder(
              builder: (context) {
                const price = 1234.56;
                final formatted = price.toSimpleCurrency(context);

                expect(formatted, contains('R\$'));
                expect(formatted, contains('1.234,56'));

                return Container();
              },
            ),
          ),
        );
      },
    );

    test('formats currency with custom locale (currency codes)', () {
      const price = 1234.56;

      final ptBR = price.toCurrencyWithLocale('pt_BR');
      expect(ptBR, contains('BRL'));
      expect(ptBR, contains('1.234,56'));

      final enUS = price.toCurrencyWithLocale('en_US');
      expect(enUS, contains('USD'));
      expect(enUS, contains('1,234.56'));
    });

    test('formats simple currency with custom locale (currency symbols)', () {
      const price = 1234.56;

      final ptBR = price.toSimpleCurrencyWithLocale('pt_BR');
      expect(ptBR, contains('R\$'));
      expect(ptBR, contains('1.234,56'));

      final enUS = price.toSimpleCurrencyWithLocale('en_US');
      expect(enUS, contains('\$'));
      expect(enUS, contains('1,234.56'));
    });

    test('formats compact currency with symbols', () {
      const price = 1234.56;

      final ptBRCompact = price.toCompactCurrencyWithLocale('pt_BR');
      expect(ptBRCompact, contains('BRL'));

      final enUSCompact = price.toCompactCurrencyWithLocale('en_US');
      expect(enUSCompact, contains('USD'));
    });

    test('handles large numbers in compact format', () {
      const bigPrice = 1500000.0;

      // Formato regular com código
      final regular = bigPrice.toCurrencyWithLocale('pt_BR');
      expect(regular, contains('BRL'));
      expect(regular, contains('1.500.000,00'));

      // Formato simples com símbolo
      final simple = bigPrice.toSimpleCurrencyWithLocale('pt_BR');
      expect(simple, contains(r'R$'));
      expect(simple, contains('1.500.000,00'));

      // Formato compacto com símbolo
      final compact = bigPrice.toCompactCurrencyWithLocale('pt_BR');
      expect(compact, contains('BRL'));
      expect(compact.length, lessThan(regular.length));
      expect(compact.length, lessThan(simple.length));
    });
  });
}
