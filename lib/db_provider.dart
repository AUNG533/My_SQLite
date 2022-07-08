import 'dart:io';
import 'package:my_sqlite/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  late Database database; // ฐานข้อมูล

  Future<bool> initDB() async {
    try {
      const String databaseName = "MYPOS.db"; // ชื่อฐานข้อมูล
      final String databasePath =
          await getDatabasesPath(); // ที่อยู่ของฐานข้อมูล
      final String path =
          join(databasePath, databaseName); // ตัดสินค้าออกจากฐานข้อมูล

      // ตรวจสอบว่ามีฐานข้อมูลหรือไม่ // ถ้าไม่มี สร้างไดเรกทอรีใหม่
      if (!await Directory(dirname(path)).exists()) {
        await Directory(dirname(path)).create(recursive: true);
      }
      // เปิดฐานข้อมูล
      database = await openDatabase(
        path, // ที่อยู่ของฐานข้อมูล
        version: 1, // รุ่นของฐานข้อมูล
        // ฟังก์ชั่นที่จะทำงานก่อนที่จะสร้างฐานข้อมูล
        onCreate: (Database db, int version) async {
          // String sql = "CREATE TABLE $TABLE_PRODUCT (""$COLUMN_ID INTEGER PRIMARY KEY,""$COLUMN_NAME TEXT,""$COLUMN_PRICE INTEGER,""$COLUMN_STOCK REAL,"")";
          await db.execute('CREATE TABLE $TABLE_PRODUCT ($COLUMN_ID INTEGER PRIMARY KEY, $COLUMN_NAME TEXT, $COLUMN_PRICE REAL, $COLUMN_STOCK INTEGER)');
           // สร้างฐานข้อมูล
        },
        // ฟังก์ชั่นที่จะทำงานก่อนที่จะอัพเดทฐานข้อมูล
        onUpgrade: (Database db, int oldVersion, int newVersion) {
          print("Database upgrade from $oldVersion to $newVersion");
        },
        // ฟังก์ชั่นที่จะทำงานก่อนที่จะเปิดฐานข้อมูล
        onOpen: (Database db) async {
          print("Database version: ${await db.getVersion()}");
        },
      );
      return true; // สร้างฐานข้อมูลแล้ว
    } catch (e) {
      throw Exception(e); // ถ้ามีข้อผิดพลาด
    }
  }

  Future closeDB() async {
    await database.close(); // ปิดฐานข้อมูล
  }

  // get all products
  Future<List<Product>> getAllProduct() async {
    print('getAllProduct');
    final List maps = await database.query(
      TABLE_PRODUCT,
      columns: [COLUMN_ID, COLUMN_NAME, COLUMN_PRICE, COLUMN_STOCK],
    );

    // List<Map> list = await database.rawQuery("SELECT * FROM $TABLE_PRODUCT");

    if (maps.isNotEmpty) {
      return maps.map((p) => Product.fromMap(p)).toList();
    }

    return []; // ถ้าไม่มีข้อมูลจะได้ค่า null
  }

  // get all product by name
  Future<Product?> getProduct(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      TABLE_PRODUCT,
      columns: [COLUMN_ID, COLUMN_NAME, COLUMN_PRICE, COLUMN_STOCK],
      where: "$COLUMN_ID = ?", // คำสั่ง where
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null; // ไม่พบข้อมูล
  }

  // insert product
  Future<Product> insertProduct(Product product) async {
    // เพิ่มข้อมูลลงฐานข้อมูล
    product.id = await database.insert(TABLE_PRODUCT, product.toMap());  // เพิ่มข้อมูลลงฐานข้อมูล
    // product.id = await database.rawInsert("INSERT Into......");
    return product;
  }

  // update product
  Future<int> updateProduct(Product product) async {
    return await database.update(
      TABLE_PRODUCT, // ชื่อตาราง
      product.toMap(), // ข้อมูลที่จะแก้ไข
      where: "$COLUMN_ID = ?", // คำสั่ง where
      whereArgs: [product.id],
    );
  }

  // delete product
  Future<int> deleteProduct(int id) async {
    return await database.delete( // ลบข้อมูลจากตาราง
      TABLE_PRODUCT, // ชื่อตาราง
      where: "$COLUMN_ID = ?", // คำสั่ง where
      whereArgs: [id],
    );
  }

  // delete all product
  Future<int> deleteAllProduct() async {
    String sql = "DELETE FROM $TABLE_PRODUCT"; // ลบข้อมูลทั้งหมดจากตาราง
    return await database.rawDelete(sql);
  }
}
