import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../logger.dart';
import '../services/currency_service.dart';
import 'custom_button.dart';

class CurrencyPicker extends StatelessWidget {
  final String selectedCurrencyCode;
  final ValueChanged<String> onCurrencyCodeSelected;

  const CurrencyPicker({
    super.key,
    required this.selectedCurrencyCode,
    required this.onCurrencyCodeSelected,
  });

  Future<List<String>> fetchCurrencyCodes() async {
    try {
      return await CurrencyService.fetchCurrencyCodes();
    } catch (e) {
      logger.e('Failed to fetch available currencies: $e');
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchCurrencyCodes(),
      builder: (context, snapshot) {
        final List<String> defaultCodelist = [
          'AED',
          'AFN',
          'ALL',
          'AMD',
          'ANG',
          'AOA',
          'ARS',
          'AUD',
          'AWG',
          'AZN',
          'BAM',
          'BBD',
          'BDT',
          'BGN',
          'BHD',
          'BIF',
          'BMD',
          'BND',
          'BOB',
          'BRL',
          'BSD',
          'BTC',
          'BTN',
          'BWP',
          'BYN',
          'BZD',
          'CAD',
          'CDF',
          'CHF',
          'CLF',
          'CLP',
          'CNH',
          'CNY',
          'COP',
          'CRC',
          'CUC',
          'CUP',
          'CVE',
          'CZK',
          'DJF',
          'DKK',
          'DOP',
          'DZD',
          'EGP',
          'ERN',
          'ETB',
          'EUR',
          'FJD',
          'FKP',
          'GBP',
          'GEL',
          'GGP',
          'GHS',
          'GIP',
          'GMD',
          'GNF',
          'GTQ',
          'GYD',
          'HKD',
          'HNL',
          'HRK',
          'HTG',
          'HUF',
          'IDR',
          'ILS',
          'IMP',
          'INR',
          'IQD',
          'IRR',
          'ISK',
          'JEP',
          'JMD',
          'JOD',
          'JPY',
          'KES',
          'KGS',
          'KHR',
          'KMF',
          'KPW',
          'KRW',
          'KWD',
          'KYD',
          'KZT',
          'LAK',
          'LBP',
          'LKR',
          'LRD',
          'LSL',
          'LYD',
          'MAD',
          'MDL',
          'MGA',
          'MKD',
          'MMK',
          'MNT',
          'MOP',
          'MRU',
          'MUR',
          'MVR',
          'MWK',
          'MXN',
          'MYR',
          'MZN',
          'NAD',
          'NGN',
          'NIO',
          'NOK',
          'NPR',
          'NZD',
          'OMR',
          'PAB',
          'PEN',
          'PGK',
          'PHP',
          'PKR',
          'PLN',
          'PYG',
          'QAR',
          'RON',
          'RSD',
          'RUB',
          'RWF',
          'SAR',
          'SBD',
          'SCR',
          'SDG',
          'SEK',
          'SGD',
          'SHP',
          'SLL',
          'SOS',
          'SRD',
          'SSP',
          'STD',
          'STN',
          'SVC',
          'SYP',
          'SZL',
          'THB',
          'TJS',
          'TMT',
          'TND',
          'TOP',
          'TRY',
          'TTD',
          'TWD',
          'TZS',
          'UAH',
          'UGX',
          'USD',
          'UYU',
          'UZS',
          'VEF',
          'VES',
          'VND',
          'VUV',
          'WST',
          'XAF',
          'XAG',
          'XAU',
          'XCD',
          'XDR',
          'XOF',
          'XPD',
          'XPF',
          'XPT',
          'YER',
          'ZAR',
          'ZMW',
          'ZWL'
        ];

        // Use a default list until data loads
        final List<String> currencyList =
            snapshot.hasData && snapshot.data!.isNotEmpty
                ? snapshot.data!
                : defaultCodelist; // Default currencies

        int initialIndex = currencyList.indexOf(selectedCurrencyCode);
        if (initialIndex == -1) initialIndex = 0;

        // Track the selected currency locally
        String currentSelectedCurrency = currencyList[initialIndex];

        return Container(
          padding: EdgeInsets.all(16),
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                thickness: 3,
                color: purple40,
                endIndent: 165,
                indent: 165,
              ),
              SizedBox(height: 8),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: initialIndex == -1 ? 0 : initialIndex,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          currentSelectedCurrency = currencyList[index];
                        },
                        children: currencyList
                            .map((currency) => Center(
                                  child: Text(
                                    currency,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: "Confirm",
                      backgroundColor: purple100,
                      textColor: light80,
                      onPressed: () {
                        onCurrencyCodeSelected(currentSelectedCurrency);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
