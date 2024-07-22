import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.top]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    var currentBrightness = 0.0.obs;

    return Scaffold(
      body: FutureBuilder(
        future: ScreenBrightness().current,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            currentBrightness(snapshot.data);
            if (snapshot.data != null) {
              currentBrightness.value = snapshot.data!;
            } else {
              currentBrightness.value = 0.5;
            }
          }

          return GestureDetector(
            onVerticalDragUpdate: (dragDetails) async {
              currentBrightness.value += -dragDetails.delta.dy * 0.00075;
              if (currentBrightness.value >= 1.0) {
                currentBrightness.value = 1.0;
              }
              if (currentBrightness.value <= 0) {
                currentBrightness.value = 0;
              }
              await ScreenBrightness()
                  .setScreenBrightness(currentBrightness.value);
            },
            child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: Center(child: Obx(()=>Text("${(currentBrightness.value * 100).round()}")))),
          );
        },
      ),
      extendBody: true,
    );
  }
}
