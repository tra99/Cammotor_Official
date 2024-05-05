// import 'package:cammotor_new_version/src/providers/pagination.dart';
// import 'package:cammotor_new_version/src/providers/sub_categ.dart';
// import 'package:cammotor_new_version/src/screen/authentication/login.dart';
// import 'package:cammotor_new_version/src/screen/homepage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:provider/provider.dart';

// void main() {
//   dotenv.load(fileName: ".env");
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => StudentProvider()),
//         ChangeNotifierProvider(create: (_) => CopyProvider()),
//         ChangeNotifierProvider(create: (_) => SubCategoryProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
  
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//         snackBarTheme: const SnackBarThemeData(
//           backgroundColor: Colors.white
//         )
//       ), 
//       home: 
//       const HomePage(),

//       // TestCardProduct(key: UniqueKey(),),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }


import 'package:cammotor_new_version/src/model/property.dart';
import 'package:cammotor_new_version/src/providers/pagination.dart';
import 'package:cammotor_new_version/src/providers/real_product.dart';
import 'package:cammotor_new_version/src/providers/sub_categ.dart';
import 'package:cammotor_new_version/src/services/property.dart';
import 'package:cammotor_new_version/src/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/screen/authentication/login.dart';
import 'src/screen/homepage.dart';

void main() async {
  dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? showIntroScreen = prefs.getBool('showIntroScreen');
  String? token = prefs.getString('token'); // Retrieve token here

  if (showIntroScreen == null) {
    showIntroScreen = true;
    await prefs.setBool('showIntroScreen', false);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => CopyProvider()),
        ChangeNotifierProvider(create: (_) => SubCategoryProvider()),
        ChangeNotifierProvider(create: (_) => RealProductProvider()),
      ],
      child: MyApp(token: token, showIntroScreen: showIntroScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? token;
  final bool showIntroScreen;

  const MyApp({Key? key, required this.token, required this.showIntroScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = token != null && token!.isNotEmpty;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      // home: isLoggedIn ? const HomePage() : (showIntroScreen ?  const SplashPage() : const LoginScreen()),
      // home: RealProduct(subcategoryID: 4,),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class PropertyWidget extends StatefulWidget {
  const PropertyWidget({Key? key}) : super(key: key); // Fixed constructor super call

  @override
  State<PropertyWidget> createState() => _PropertyWidgetState();
}

class _PropertyWidgetState extends State<PropertyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar content
      ),
      body: FutureBuilder<List<PropertyModel>>(
        future: fetchPropertyModel(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final List<PropertyModel> propertyData = snapshot.data!;

            return ListView.builder(
              itemCount: propertyData.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Text(propertyData[index].id.toString());
              },
            );
          }
        },
      ),
    );
  }
}






