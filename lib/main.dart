// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import 'package:my_sqlite/db_provider.dart';

import 'models/product.dart';

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

  DBProvider? dbProvider; // สำหรับเชื่อมต่อกับฐานข้อมูล

  @override
  void initState() {
    dbProvider = DBProvider(); // สร้างตัวแปร dbProvider เพื่อเอาไปใช้งานต่อ
    super.initState();
  }

  @override
  void dispose() {
    dbProvider?.closeDB(); // ปิดฐานข้อมูล
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // app bar
      body: _buildBody(), // content
      // Add Product Button // ปุ่มเพิ่มสินค้า
      floatingActionButton:
          _buildFloatingActionButton(), // floating action button
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
      key: _refresh, // refresh indicator key
      onRefresh: () async {
        await Future.delayed(
          const Duration(seconds: 1), // delay 1 second
        );
        setState(() {}); // refresh
      },
      child: FutureBuilder(
        future: dbProvider!.getAllProduct(), // get all products
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // ถ้ามีข้อมูล
            List<Product> products =
                snapshot.data as List<Product>; // ข้อมูลที่ได้จากฐานข้อมูล
            if (products.length > 0) {
              return _buildListView(
                  products.reversed.toList()); // สร้าง list view
            } else {
              return const Center(
                child: Text('No data'), // แสดงข้อความ No data
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(), // แสดง progress indicator
          );
        },
      ),
    );
  }

  // add product button // เพิ่มข้อมูล
  _buildFloatingActionButton() => FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // todo
        },
      );

  // Build list view // สร้าง list view
  _buildListView(List<Product> product) => ListView.separated(
      itemBuilder: (context, position) {
        Product item = product[position]; // item List Product
        return ListTile(
          // Edit product // แก้ไขข้อมูล
          leading: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // edit product
            },
          ),
          title: Text('${item.name} (${item.stock})'), // product name
          subtitle: Text('price: ${item.price}'), // product price
          // delete product // ลบข้อมูล
          trailing: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // delete product
            },
          ),
        );
      },
      separatorBuilder: (context, position) {
        return const Divider(); // เส้นแบ่ง
      },
      itemCount: product.length);

  _buildBody() => FutureBuilder(
        future: dbProvider!.initDB(), // เปิดฐานข้อมูล
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // ถ้ามีข้อมูล
            return _buildContent(); // build content
          }
          return Center(
            child: snapshot.hasError
                ? Text(snapshot.error.toString()) // แสดงข้อความ error
                : const CircularProgressIndicator(), // แสดง progress indicator
          );
        },
      ); // จำนวนข้อมูล
}
