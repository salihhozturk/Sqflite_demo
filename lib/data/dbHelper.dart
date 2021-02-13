import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_demo/models/product.dart';

class DbHelper {
  Database _db;
  //Asenkron dediğimiz mantık sayfasada 2 sn arayla başka bir tıklama yaptığımızda ikiside olsun diyorum.
  Future<Database> get db async {
    if (_db == null) {
      _db =
          await initializeDb(); //asenkron yaptıktan sonra hata vermesin diye await ekledim
    }
    return _db;
  }

//asenkron yaparken future ekleliyiz hata veriyor future yani ilerde oluşanbilecek nesne
  Future<Database> initializeDb() async {
    String dbPath = join(await getDatabasesPath(),
        "etrade.db"); //Artık elimde veritabanı yolu var şimdi veritabanı oluşturcam
    var eTradeDb =
        await openDatabase(dbPath, version: 1, onCreate: createDb); //Await
    return eTradeDb;
  }

  void createDb(Database db, int version) async {
    await db.execute(
        "Create table products(id integer primary key,name text,description text,unitPrice integer )");
  }

  Future<List<Product>> getProducts() async {
    Database db = await this.db;
    var result = await db.query("products");
    return List.generate(result.length, (i) {
      return Product.fromObject(result[i]);
    });
  }

  Future<int> insert(Product product) async {
    Database db = await this.db;
    var result = await db.insert("products", product.toMap());
    //insert işleminde önce tablo adını daha sonra Map İSTEDİ ondan dolayı Products.dart da Map operasyonu yaptım.
  }

  Future<int> delete(int id) async {
    Database db = await this.db;
    var result = await db.rawDelete(
        "delete from products where id=$id"); //silme fonksiyonunu "" içinde yazdım
    return result;
  }

  Future<int> update(Product product) async {
    Database db = await this.db;
    var result = await db.update("products", product.toMap(),
        where: "id=?", whereArgs: [product.id]); //? parametre anlamına gelir
    return result;
  }
}
