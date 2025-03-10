import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:poc_metamask/modal.dart';
import 'package:poc_metamask/wallet_connect.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Modal modal = GetIt.I.get<Modal>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: () => createInstance(context), child: Text("createInstance")),
            ElevatedButton(
              onPressed: () => connectMetamask(context),
              child: Text("Connect metamask"),
            ),
          ],
        ),
      ),
    );
  }

  void createInstance(BuildContext context) async {
    modal.createInstance(context);
  }

  void connectMetamask(BuildContext context) async {
    modal.connect(context);
  }
}
