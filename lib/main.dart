import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fingerprint Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FingerprintPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class FingerprintPage extends StatefulWidget {
  const FingerprintPage({super.key});

  @override
  State<FingerprintPage> createState() => _FingerprintPageState();
}

class _FingerprintPageState extends State<FingerprintPage> {
  final LocalAuthentication auth = LocalAuthentication();
  
  bool canAuthenticateWithBiometrics = false;
  bool canAuthenticate = false;
  bool didAuthenticate = false;
  List<BiometricType>? biometricsList;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }
  
  Future<void> _checkBiometrics() async {
    try {
      canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _getBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {biometricsList = availableBiometrics;});
  }

  Future<void> _authenticate() async {
    try {
      didAuthenticate = await auth.authenticate(
      localizedReason: 'Authenticate to access the app',
      );
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!canAuthenticate)
              const Text('This device is not supported',
                style: TextStyle(fontSize: 18),
              ),

            const SizedBox(height: 20),

            Text('Available biometrics: $biometricsList\n',
            textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: _getBiometrics,
              child: const Text('Get available biometrics'),
            ),

            const SizedBox(height: 20),

            if (canAuthenticate && !didAuthenticate)
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Authenticate with Fingerprint'),
              ),
              
            if (didAuthenticate)
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage())
                ),
                child: const Text('Next Page'),
              ),
          ],
        ),
      ),
    );
  }
}