import 'package:digimon_meta_site_flutter/widget/header_widget.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final Widget bodyWidget;
  const MainPage({super.key, required this.bodyWidget});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: CustomHeader(),),
      body: widget.bodyWidget,
    );
  }
}
