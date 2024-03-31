import 'package:flutter/material.dart';

class PersistentTabController extends StatefulWidget {
  final int tabCount;
  final Widget child;

  PersistentTabController({required this.tabCount, required this.child});

  @override
  _PersistentTabControllerState createState() => _PersistentTabControllerState();
}

class _PersistentTabControllerState extends State<PersistentTabController> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.tabCount, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
