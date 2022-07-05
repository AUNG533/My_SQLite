import 'dart:io';
import 'package:my_sqlite/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  late Database database; // ฐานข้อมูล

  Future<bool> initDB() async {
    try {
      const String databaseName = "MYPOS.db"; // ชื่อฐานข้อมูล
      final String databasePath = await getDatabasesPath(); // ที่อยู่ของฐานข้อมูล
      final String path = join(databasePath, databaseName); // ตัดสินค้าออกจากฐานข้อมูล

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
          String sql = "CREATE TABLE $TABLE_PRODUCT ("
                "$COLUMN_ID INTEGER PRIMARY KEY, "
                "$COLUMN_NAME TEXT, "
                "$COLUMN_PRICE INTEGER"
                "$COLUMN_STOCK REAL, "
                ")";
            await db.execute(sql); // สร้างฐานข้อมูล
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

// if (await databaseExists(path)) {
// print("Database exists");
// } else {
// print("Database does not exist");
// final ByteData data = await rootBundle.load(join("assets", "MYPOS.db"));
// final List<int> bytes =
// data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
// await File(path).writeAsBytes(bytes);
// }
}
