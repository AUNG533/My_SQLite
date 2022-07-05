// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My SQLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // key for the refresh indicator // สำหรับ refresh indicator
  var _refresh = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // app bar
      body: _buildContent(), // content
      // Add Product Button // ปุ่มเพิ่มสินค้า
      floatingActionButton: _buildFloatingActionButton(), // floating action button
    );
  }

  // Create app bar // สร้าง app bar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('My SQLite'),
      actions: [
        // Delete all data // ลบข้อมูลทั้งหมด
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // todo
          },
        ),
      ],
    );
  }

  // Build content
  _buildContent() {
    return RefreshIndicator(
      key: _refresh,  // refresh indicator key
        child: _buildListView(), // show data in list view
        onRefresh: () async {
          await Future.delayed(
            const Duration(seconds: 1), // delay 1 second
          );
          setState(() {}); // refresh
        });
  }

  // add product button // เพิ่มข้อมูล
  _buildFloatingActionButton() => FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // todo
        },
      );

  // Build list view // สร้าง list view
  _buildListView() => ListView.separated(
      itemBuilder: (context, position) {
        return ListTile(
          // Edit product // แก้ไขข้อมูล
          leading: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // todo
            },
          ),
          title: Text('Item (11111)'), // product name
          subtitle: Text('Subtitle'), // product price
          // delete product // ลบข้อมูล
          trailing: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // todo
            },
          ),
        );
      },
      separatorBuilder: (context, position) {
        return const Divider(); // เส้นแบ่ง
      },
      itemCount: 10); // จำนวนข้อมูล
}
