// ignore_for_file: prefer_final_fields, deprecated_member_use
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

  late DBProvider dbProvider; // สำหรับเชื่อมต่อกับฐานข้อมูล

  @override
  void initState() {
    dbProvider = DBProvider(); // สร้างตัวแปร dbProvider เพื่อเอาไปใช้งานต่อ
    super.initState();
  }

  @override
  void dispose() {
    dbProvider.closeDB(); // ปิดฐานข้อมูล
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
            _refresh.currentState!.show(); // แสดง refresh indicator
            dbProvider.deleteAllProduct(); // ลบข้อมูลทั้งหมด
            setState(() {}); // อัพเดทหน้าจอ
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
        // setState(() {}); // refresh
      },
      child: FutureBuilder(
        future: dbProvider.getAllProduct(), // get all products
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // ถ้ามีข้อมูล
            List<Product> products =
                snapshot.data as List<Product>; // ข้อมูลที่ได้จากฐานข้อมูล
            if (products.isNotEmpty) {
              return _buildListView(products); // สร้าง list view
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
          createDialog(); // สร้างหน้าต่างสำหรับยืนยันการลบข้อมูล
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
              editDialog(item); // สร้างหน้าต่างสำหรับยืนยันการลบข้อมูล
            },
          ),
          title: Text('${item.name} (${item.stock})'), // product name
          subtitle: Text('price: ${item.price}'), // product price
          // delete product // ลบข้อมูล
          trailing: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () async {
              _refresh.currentState!.show(); // refresh indicator
              dbProvider.deleteProduct(item.id!); // ลบข้อมูลจากฐานข้อมูล
              await Future.delayed(
                const Duration(seconds: 1), // delay 1 second
              );
              setState(() {}); // อัพเดทข้อมูลหน้าจอ
              //Popup เรียกคืนข้อมูล
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Item deleted"),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      _refresh.currentState!.show(); // รีเฟรชข้อมูล
                      // เรียกคืนข้อมูล โดยส่งค่า id ของข้อมูลที่ลบ
                      dbProvider.insertProduct(item).then(
                            (value) {
                          setState(() {}); // อัพเดทข้อมูล
                        },
                      );
                    },
                  ),
                ), // แสดงข้อความว่าลบข้อมูลแล้ว
              );
            },
          ),
        );
      },
      separatorBuilder: (context, position) {
        return const Divider(); // เส้นแบ่ง
      },
      itemCount: product.length);

  _buildBody() => FutureBuilder(
        future: dbProvider.initDB(), // เปิดฐานข้อมูล
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
      );

  // Insert product // เพิ่มข้อมูล
  createDialog() {
    var formKey = GlobalKey<FormState>(); // สำหรับการสร้าง form
    Product product = Product(); // สร้างตัวแปร product เพื่อเอาไปใช้งานต่อ
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            key: formKey, // สำหรับการสร้าง form
            child: Column(
              mainAxisSize: MainAxisSize.min, // ขนาดคอลัมน์ของหน้าต่าง
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Name'),
                  onSaved: (value) {
                    product.name = value; // ชื่อสินค้า
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Price'),
                  onSaved: (value) {
                    product.price = double.parse(value!); // ชื่อสินค้า
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Stock'),
                  onSaved: (value) {
                    product.stock = int.parse(value!); // ชื่อสินค้า
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save(); // บันทึกข้อมูล
                        _refresh.currentState!.show(); // รีเฟรชข้อมูล
                        Navigator.pop(context); // ปิดหน้าต่าง
                        dbProvider.insertProduct(product).then(
                          (value) {
                            print('product: $product');
                            setState(() {}); // อัพเดทข้อมูล
                          },
                        ); // เพิ่มข้อมูล
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } // จำนวนข้อมูล

  // แก้ไขข้อมูล
  editDialog(Product product) {
    var formKey = GlobalKey<FormState>(); // สำหรับการสร้าง form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            key: formKey, // สำหรับการสร้าง form
            child: Column(
              mainAxisSize: MainAxisSize.min, // ขนาดคอลัมน์ของหน้าต่าง
              children: [
                TextFormField(
                  initialValue: product.name, // ชื่อสินค้า
                  decoration: const InputDecoration(hintText: 'Name'),
                  onSaved: (value) {
                    product.name = value; // ชื่อสินค้า
                  },
                ),
                TextFormField(
                  initialValue: product.price.toString(), // ชื่อสินค้า
                  decoration: const InputDecoration(hintText: 'Price'),
                  onSaved: (value) {
                    product.price = double.parse(value!); // ชื่อสินค้า
                  },
                ),
                TextFormField(
                  initialValue: product.stock.toString(), // ชื่อสินค้า
                  decoration: const InputDecoration(hintText: 'Stock'),
                  onSaved: (value) {
                    product.stock = int.parse(value!); // ชื่อสินค้า
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save(); // บันทึกข้อมูล
                        _refresh.currentState!.show(); // รีเฟรชข้อมูล
                        Navigator.pop(context); // ปิดหน้าต่าง
                        dbProvider.updateProduct(product).then(
                          (row) {
                            print(row.toString());
                            setState(() {}); // อัพเดทข้อมูล
                          },
                        ); // เพิ่มข้อมูล
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } // จำนวนข้อมูล
}
