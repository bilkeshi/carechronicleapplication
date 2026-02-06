import 'package:care_chronicle_app/Screens/main%20screens/login_screen.dart';
import 'package:care_chronicle_app/Screens/main%20screens/signup_screen.dart';
import 'package:care_chronicle_app/widgets/navbar_roots.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFB3E5FC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavBarRoots(),
                      ),
                    );
                  },
                  child: Text(
                    "SKIP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.all(5),
                child: Image.asset("images/appname.png"),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(5),
                child: Image.asset("images/vision.png"),
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.all(5),
                child: Image.asset("images/logo.png"),
              ),
              SizedBox(height: 10),
              Text(
                "Chronic Wound Care",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  wordSpacing: 2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Keep Track with Care Chronicle",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Material(
                    color: Colors.cyan,
                    //(0xFF7165D6),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
