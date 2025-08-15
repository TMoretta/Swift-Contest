import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: const [
              TextSpan(
                text: 'Termini e Condizioni d\'Uso\n\n',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextSpan(
                text: 'Ultimo aggiornamento: 31 Luglio 2024\n\n',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              TextSpan(
                  text: 'Utilizzando l\'applicazione Swift Contest, accetti di rispettare i seguenti termini e condizioni...\n\n'
                      '1. Uso Consentito\n'
                      'L\'utente si impegna a non utilizzare l\'app per scopi illegali o non autorizzati...\n\n'
                // ... continua con il resto del testo ...
              ),
            ],
          ),
        ),
      ),
    );
  }
}