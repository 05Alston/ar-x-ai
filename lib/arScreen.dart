
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArScreen extends StatefulWidget {
  // const NextPage({Key? key}) : super(key: key);

  @override
  _ArScreenState createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  late ArCoreController arCoreController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AR Screen'),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addCuboid(arCoreController);
  }

  // void _addSphere(ArCoreController controller) {
  //   final material = ArCoreMaterial(
  //       color: Color.fromARGB(120, 66, 134, 244));
  //   final sphere = ArCoreSphere(
  //     materials: [material],
  //     radius: 0.1,
  //   );
  //   final node = ArCoreNode(
  //     shape: sphere,
  //     position: vector.Vector3(0, 0, -1.5),
  //   );
  //   controller.addArCoreNode(node);
  // }

  // void _addCylindre(ArCoreController controller) {
  //   final material = ArCoreMaterial(
  //     color: Colors.red,
  //     reflectance: 1.0,
  //   );
  //   final cylindre = ArCoreCylinder(
  //     materials: [material],
  //     radius: 0.5,
  //     height: 0.3,
  //   );
  //   final node = ArCoreNode(
  //     shape: cylindre,
  //     position: vector.Vector3(0.0, -0.5, -2.0),
  //   );
  //   controller.addArCoreNode(node);
  // }

  void _addCube(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.5, 0.5, 0.5),
    );
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(-0.5, 0.5, -3.5),
    );
    controller.addArCoreNode(node);
  }
  void _addCuboid(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Color.fromARGB(200, 209, 213, 219),
      metallic: 1.0,
    );

    final cuboid = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.5, 0.5, 0.05),
    );
    final node = ArCoreNode(
      shape: cuboid,
      position: vector.Vector3(0, 0, -1.5),
    );
    controller.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}