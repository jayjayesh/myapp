import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TreeViewController _treeViewController;

  // Sample JSON structure
  final String jsonData = '''
  {
    "comment_nodes": [
      {
        "name": "root.1",
        "child": [
          {
            "name": "child.1.1"
          },
          {
            "name": "child.1.2"
          }
        ]
      },
      {
        "name": "root.2",
        "child": [
          {
            "name": "child.2.1",
            "child": [
              {
                "name": "subchild.2.1.1"
              }
            ]
          },
          {
            "name": "child.2.2",
            "child": [
              {
                "name": "subchild.2.2.1"
              },
              {
                "name": "subchild.2.2.2"
              }
            ]
          }
        ]
      }
    ]
  }
  ''';

  @override
  void initState() {
    super.initState();

    // Parse JSON
    final Map<String, dynamic> jsonMap = jsonDecode(jsonData);
    final List<dynamic> commentNodes = jsonMap['comment_nodes'];

    // Convert JSON to Nodes
    List<Node> nodes = _convertJsonToNodes(commentNodes);

    _treeViewController = TreeViewController(
      children: nodes,
      // selectedKey: 'child.1.2',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: TreeView(
          controller: _treeViewController,
          allowParentSelect: true,
          supportParentDoubleTap: true,
          onNodeTap: (nodeKey) {
            log('Node tapped: $nodeKey');
            // Highlight the tapped node
            setState(() {
              _treeViewController =
                  _treeViewController.copyWith(selectedKey: nodeKey);
            });
          },
        ));
  }

  // TODO: Auto add node index like (for node_key purpose)
  // * child to child.1.2
  // * subchild to subchild.1.2.1

  List<Node> _convertJsonToNodes(List<dynamic> list) {
    return list.map((item) {
      List<Node> children = [];
      if (item['child'] != null && item['child'].isNotEmpty) {
        // If there are child nodes, recursively convert them
        children = _convertJsonToNodes(item['child']);
      }
      return Node(
        label: item['name'],
        key: item['name'], // You can assign a unique key
        children: children,
      );
    }).toList();
  }
}
