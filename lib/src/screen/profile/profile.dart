import 'dart:convert';
import 'package:cammotor_new_version/src/screen/profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({Key? key}) : super(key: key);

  @override
  _ProfileInfoScreenState createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  String? name = '';
  String? email = '';
  String? profile='';

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
      body: Center(
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
            //   Icon(
            //     Icons.account_box_outlined,
            //     size: 120,
            //     color: Colors.grey[700],
            // ),
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
          ],
        ),
      ),
    );
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


// Transform.rotate(
//               angle: -10 * 3.1415926535 / 180, // Convert degrees to radians
//               child: ClipPath(
//                 clipper: DiagonalClipper(),
//                 child: Container(
//                   width: double.infinity,
//                   height: 120,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
// class DiagonalClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.moveTo(0, 0);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height); // Adjust to modify the cut size
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
