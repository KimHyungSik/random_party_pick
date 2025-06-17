import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
      ),
      body: ListView(
        children: [
          _buildLanguageListTile(
            context,
            ref,
            const Locale('en'),
            l10n.english,
            currentLocale,
          ),
          _buildLanguageListTile(
            context,
            ref,
            const Locale('ko'),
            l10n.korean,
            currentLocale,
          ),
          _buildLanguageListTile(
            context,
            ref,
            const Locale('th'),
            l10n.thai,
            currentLocale,
          ),
          _buildLanguageListTile(
            context,
            ref,
            const Locale('fr'),
            l10n.french,
            currentLocale,
          ),
          _buildLanguageListTile(
            context,
            ref,
            const Locale('de'),
            l10n.german,
            currentLocale,
          ),
          _buildLanguageListTile(
            context,
            ref,
            const Locale('es'),
            l10n.spanish,
            currentLocale,
          ),
          _buildLanguageListTile(
            context,
            ref,
            const Locale('ja'),
            l10n.japanese,
            currentLocale,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageListTile(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    String languageName,
    Locale currentLocale,
  ) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return ListTile(
      title: Text(languageName),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }
}