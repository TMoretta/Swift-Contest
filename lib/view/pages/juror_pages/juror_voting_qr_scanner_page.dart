import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_qr_scanner_page_bloc/juror_voting_qr_scanner_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class JurorVotingQrScannerPage extends StatefulWidget implements AutoRouteWrapper {
  const JurorVotingQrScannerPage({super.key});

  @override
  State<JurorVotingQrScannerPage> createState() => _JurorVotingQrScannerPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<JurorVotingQrScannerPageBloc>(
      create: (context) => JurorVotingQrScannerPageBloc(
        jurorRepository: context.read(),
      ),
      child: BlocConsumer<JurorVotingQrScannerPageBloc, JurorVotingQrScannerPageState>(
        listener: (context, state) {
          if (state.status.isSuccess &&
              state.sourceEvent is JurorVotingQrScannerPageAccessVotingAsSimpleJuror) {
            context.router
                .replace(JurorVotingProcedureRoute(votingSessionId: state.votingSession!.id!));
          }
        },
        builder: (context, state) {
          return this;
        },
      ),
    );
  }
}

class _JurorVotingQrScannerPageState extends State<JurorVotingQrScannerPage> {
  // Controller per lo scanner
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  // Variabile per tenere traccia dello stato del permesso
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    // Controlla lo stato del permesso all'avvio della pagina
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status != _permissionStatus) {
      setState(() {
        _permissionStatus = status;
      });
    }
  }

  @override
  void dispose() {
    // Assicurati di rilasciare il controller quando la pagina viene distrutta
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostra un indicatore di caricamento mentre controlliamo i permessi
    if (_permissionStatus == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Se il permesso è stato concesso, mostra lo scanner
    if (_permissionStatus == PermissionStatus.granted) {
      return _buildScannerView();
    }

    // Altrimenti, mostra una schermata che spiega perché serve il permesso
    return _buildPermissionDeniedView();
  }

  // Widget che mostra lo scanner vero e proprio
  Widget _buildScannerView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scansiona QR Code'),
        actions: [
          // Pulsante per la torcia
          ValueListenableBuilder(
            // 1. ASCOLTA L'INTERO CONTROLLER
            valueListenable: _scannerController,
            builder: (context, state, child) {
              // 3. CREA L'ICONA IN BASE ALLO STATO
              return IconButton(
                color: Colors.white,
                icon: Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off),
                onPressed: () => _scannerController.toggleTorch(),
              );
            },
          ),
          // Pulsante per cambiare fotocamera
          ValueListenableBuilder(
            // 1. ASCOLTA L'INTERO CONTROLLER
            valueListenable: _scannerController,
            builder: (context, state, child) {
              // 3. CREA L'ICONA
              return IconButton(
                color: Colors.white,
                icon: const Icon(Icons.flip_camera_ios),
                onPressed: () => _scannerController.switchCamera(),
              );
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: (capture) {
          final String? token = capture.barcodes.first.rawValue;
          if (token != null && token.isNotEmpty) {
            context
                .read<JurorVotingQrScannerPageBloc>()
                .add(JurorVotingQrScannerPageAccessVotingAsSimpleJuror(token: token));
          }
        },
      ),
    );
  }

  // Widget mostrato quando il permesso non è concesso
  Widget _buildPermissionDeniedView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Permesso Fotocamera')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Accesso alla fotocamera necessario',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Per scansionare il QR code di invito, abbiamo bisogno del permesso di usare la fotocamera.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Richiedi Permesso'),
                onPressed: () async {
                  // Richiede il permesso. Se l'utente lo nega permanentemente,
                  // lo stato diventerà `PermissionStatus.permanentlyDenied`.
                  final status = await Permission.camera.request();
                  setState(() {
                    _permissionStatus = status;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Se l'utente ha negato il permesso permanentemente,
              // mostra un pulsante per aprire le impostazioni dell'app.
              if (_permissionStatus == PermissionStatus.permanentlyDenied)
                TextButton(
                  child: const Text('Apri Impostazioni App'),
                  onPressed: () {
                    // Apre le impostazioni dell'app per permettere all'utente
                    // di abilitare il permesso manualmente.
                    openAppSettings();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
