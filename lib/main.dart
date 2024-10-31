import 'package:flutter/material.dart';
import 'package:android_dynamic_icon/android_dynamic_icon.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: dotenv.env["apiKey"] ?? "",
        appId: dotenv.env["appId"] ?? "",
        messagingSenderId: dotenv.env["messagingSenderId"] ?? "",
        projectId: dotenv.env["projectId"] ?? "",
        storageBucket: dotenv.env["storageBucket"] ?? ""),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Remote Config Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Firebase Remote Config Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final _androidDynamicIconPlugin = AndroidDynamicIcon();
  String _message = 'Fetching data...';

  @override
  void initState() {
    super.initState();
    AndroidDynamicIcon.initialize(
      classNames: ['MainActivity', 'IconOne', 'IconTwo'],
    );
    _fetchRemoteConfig();
  }

  Future<void> _fetchRemoteConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 3),
    ));

    try {
      await _remoteConfig.setDefaults(<String, dynamic>{
        'icon_number': 1,
      });
      await _remoteConfig.fetchAndActivate();

      final iconNumber = _remoteConfig.getInt('icon_number');
      setState(() {
        _message = 'Icon number from Remote Config: $iconNumber';
      });
      if (iconNumber == 1) {
        _changeIcon('IconOne');
      } else if (iconNumber == 2) {
        _changeIcon('IconTwo');
      }
    } catch (e) {
      setState(() {
        _message = 'Failed to fetch remote config: $e';
      });
    }
  }

  void _changeIcon(String iconClassName) async {
    await _androidDynamicIconPlugin.changeIcon(classNames: [iconClassName, '']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _message,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
