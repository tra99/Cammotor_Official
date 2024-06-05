import 'dart:convert';
import 'package:cammotor_new_version/src/screen/profile/edit_profile.dart';
import 'package:dialog_alert/dialog_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/login.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({Key? key}) : super(key: key);

  @override
  _ProfileInfoScreenState createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  String? name = '';
  String? email = '';
  String? profile='';
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');

    if (authToken != null) {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/auth/user/check'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          name = responseData['test']['name'];
          email = responseData['test']['email'];
          profile=responseData['test']['profile'];
          userId=responseData['test']['id'];
        });
        print(responseData);
      } else {
        print('Failed to fetch user info');
      }
    } else {
      print('Authentication token not found');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
              ),
              if (profile != null && profile!.isNotEmpty) 
                Image.network(
                  "${dotenv.env['BASE_URL']}/storage/$profile",
                  width: 120,
                  height: 120,
                ),
              if (profile == null || profile!.isEmpty) 
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 2, color: Colors.yellow)),
                  child: ClipOval(
                    child: Image.asset('assets/images/f1.jpg',
                        fit: BoxFit.cover),
                  ),
                ),
        
        
              Text(
                '$name',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('$email'),
              Text('$userId'.toString()),
              // const Text('+1234567890'),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const EditProfileScreen()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 66, 54, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              CustomCard(
                title: "My Orders",
                onTap: () {},
              ),
              const SizedBox(
                height: 6,
              ),
              CustomCard(
                title: "My Addresses",
                onTap: () {},
              ),
              const SizedBox(
                height: 6,
              ),
              CustomCard(
                title: "My Favourities",
                onTap: () {},
              ),
              const SizedBox(
                height: 6,
              ),
              CustomCard(
                title: "Coupons",
                onTap: () {},
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Container(
                  width: 200,
                  child: TextButton(
                    autofocus: true,
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('ការជូនដំណឹង'),
                            content: const Text('តើអ្នកពិតជាចង់ចេញពីគណនីរបស់អ្នក?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); 
                                },
                                child: const Text('លុបចោល'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await _logout(context);
                                  print("Logout");
                                },
                                child: const Text('ចាកចេញ'),
                              ),
                              
                            ],
                          );
                        },
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 80, 70, 72),
                      disabledForegroundColor: Colors.grey.withOpacity(0.38),
                      shadowColor: Colors.grey,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      textStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_outlined, size: 24),
                        Text("ចាកចេញ"),
                      ],
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // Send a request to the server to logout (clear token on the server)
      try {
        final response = await http.post(
          // Uri.parse('http://143.198.217.4:1026/api/auth/logout'),
          Uri.parse('${dotenv.env['BASE_URL']}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          // Successful logout from the server, clear token locally and reset status
          await prefs.remove('token');
          // Reset any other indicators of logged-in status here if present

          // Navigate to login screen or perform any other actions
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // Handle logout failure from the server
          print('Failed to logout from the server: ${response.statusCode}');
        }
      } catch (error) {
        // Handle other potential errors during the HTTP request
        print('Error during logout request: $error');
      }
    }
  }

}
class CustomCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const CustomCard({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
