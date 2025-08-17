import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
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
      child: this,
    );
  }
}

class _JurorVotingQrScannerPageState extends State<JurorVotingQrScannerPage> with WidgetsBindingObserver {
  // to recheck camera permission returning from settings
  bool goneIntoSettings = false;

  // Controller per lo scanner
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  @override
  void initState() {
    super.initState();
    // Aggiunge questo widget come observer del ciclo di vita dell'app.
    WidgetsBinding.instance.addObserver(this);
    // Esegue il check iniziale dei permessi.
    context.read<JurorVotingQrScannerPageBloc>().add(JurorVotingQrScannerPageCheckCameraPermission());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Se l'app torna in primo piano (es. dopo essere stati nelle impostazioni)
    if (goneIntoSettings && state == AppLifecycleState.resumed) {
      goneIntoSettings = false;
      // Esegui di nuovo il check dei permessi.
      context
          .read<JurorVotingQrScannerPageBloc>()
          .add(JurorVotingQrScannerPageCheckCameraPermission());
    }
  }

  @override
  void dispose() {
    // Assicurati di rilasciare il controller quando la pagina viene distrutta
    // e di rimuovere l'observer per evitare memory leak.
    WidgetsBinding.instance.removeObserver(this);
    context.hideLoader();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JurorVotingQrScannerPageBloc, JurorVotingQrScannerPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.sourceEvent is JurorVotingQrScannerPageAccessVotingAsSimpleJuror) {
          context.router
              .replace(JurorVotingProcedureRoute(votingSessionId: state.votingSession!.id!));
        }
      },
      builder: (context, state) {
        switch (state.cameraPermissionStatus) {
          case PermissionStatus.permanentlyDenied:
            return _buildPermissionPermanentlyDeniedView();
          case null:
          case PermissionStatus.restricted:
          case PermissionStatus.limited:
          case PermissionStatus.provisional:
          case PermissionStatus.denied:
            return _buildPermissionDeniedView();
          case PermissionStatus.granted:
            return _buildScannerView();
        }
      },
    );
  }

  // Widget che mostra lo scanner vero e proprio
  Widget _buildScannerView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
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
      appBar: AppBar(title: const Text('Camera Permission')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Camera Access Required',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'To scan the invitation QR code, we need permission to use your camera.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Request Permission'),
                onPressed: () => context
                    .read<JurorVotingQrScannerPageBloc>()
                    .add(JurorVotingQrScannerPageCheckCameraPermission()),
              ),
              // const SizedBox(height: 10),
              // Se l'utente ha negato il permesso permanentemente,
              // mostra un pulsante per aprire le impostazioni dell'app.
              // if (_permissionStatus == PermissionStatus.permanentlyDenied)
              //   TextButton(
              //     child: const Text('Open App Settings'),
              //     onPressed: () {
              //       // Apre le impostazioni dell'app per permettere all'utente
              //       // di abilitare il permesso manualmente.
              //       openAppSettings();
              //     },
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionPermanentlyDeniedView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Permission')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Camera Access Required',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'To scan the invitation QR code, we need permission to use your camera. '
                    'The permission has been permanently denied. Please enable it from app settings.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Open app settings'),
                onPressed: () {
                  openAppSettings();
                  goneIntoSettings = true;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
