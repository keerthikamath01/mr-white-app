import 'package:flutter/material.dart';
import '../view_models/game_view_model.dart';
import 'setup_view.dart';
import 'package:provider/provider.dart';

class InitView extends StatelessWidget {
  const InitView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      appBar: AppBar(
        title: const Text("Init Page"),
        automaticallyImplyLeading: false,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: '/setup'),
                    builder: (context) => SetupView(),
                  ),
                );;
              },
              child: const Text("Play"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
              },
              child: const Text("Instructions"),
            )
          ]
        )
      )
    );
  }
}