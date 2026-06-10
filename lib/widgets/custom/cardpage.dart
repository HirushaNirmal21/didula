import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Cardpage extends StatelessWidget {
  const Cardpage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 1, 4, 39),
        // ignore: sized_box_for_whitespace
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 1, 4, 39),
              borderRadius: BorderRadius.circular(100),
            ),

            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    child: Image.asset("assets/logos.jpeg", fit: BoxFit.cover),
                  ),
                  Text(
                    "MORE THAN A TOURNAMENT",
                    style: TextStyle(
                      letterSpacing: 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 17, 145),
                      ),
                      onPressed: () {
                        GoRouter.of(context).push("/Register");
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                fontSize: 20,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
