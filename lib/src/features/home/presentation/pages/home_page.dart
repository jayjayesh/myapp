import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_project_base/flutter_project_base.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLoading = false;
  late TreeViewController _treeViewController;

  // Sample JSON structure
  final String jsonData = '''
  {
    "comment_nodes": [
      {
        "name": "root",
        "child": [
          {
            "name": "child"
          },
          {
            "name": "child"
          }
        ]
      },
      {
        "name": "root",
        "child": [
          {
            "name": "child",
            "child": [
              {
                "name": "subchild"
              }
            ]
          },
          {
            "name": "child",
            "child": [
              {
                "name": "subchild"
              },
              {
                "name": "subchild"
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
          actions: [
            SizedBox(
              height: 50,
              width: 150,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await Future.delayed(const Duration(seconds: 2));
                  // expand all node
                  setState(() {
                    isLoading = false;
                    _treeViewController =
                        _treeViewController.copyWith(selectedKey: 'non');
                  });
                },
                child: const Text('Clear Selection'),
              ).withLoading(isLoading),
            ),
          ],
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

  // * Auto add node index (for node_key purpose)
  // * child to child.1.2
  // * subchild to subchild.1.2.1

  List<Node> _convertJsonToNodes(List<dynamic> list, [String parentKey = '']) {
    int index = 1;
    return list.map((item) {
      String nodeKey = parentKey.isNotEmpty ? '$parentKey.$index' : '.$index';
      index++;
      List<Node> children = [];
      if (item['child'] != null && item['child'].isNotEmpty) {
        // If there are child nodes, recursively convert them
        children = _convertJsonToNodes(item['child'], nodeKey);
      }
      return Node(
        label: item['name'] + nodeKey,
        key: item['name'] + nodeKey, // You can assign a unique key
        children: children,
      );
    }).toList();
  }
}
