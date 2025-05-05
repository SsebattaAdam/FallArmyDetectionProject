import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providerformap/providerformap.dart';
import 'mappage.dart';

class MapPageWrapper extends StatelessWidget {
  const MapPageWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapDataProvider(),
      child: const MapScreen(),
    );
  }
}
