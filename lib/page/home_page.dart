import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:flutter/material.dart';
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Column(
          children: [
            IconButton(onPressed: () {
              context.router.push(ToyBoxRoute());


            }, icon: const Icon(Icons.create_new_folder),),
            IconButton(onPressed: () {
              context.router.push(LoginRoute());


            }, icon: const Icon(Icons.account_box),),
          ],
        ),
      ),
    );
  }
}
