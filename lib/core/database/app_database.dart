import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: <Type>[Products])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Product>> watchAllProducts() {
    return (select(products)
          ..orderBy(<OrderClauseGenerator<Products>>[
            (Products tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .watch();
  }

  Future<int> insertProduct(ProductsCompanion companion) {
    return into(products).insert(companion);
  }

  Future<int> updateProductById(int id, ProductsCompanion companion) {
    return (update(products)..where((Products tbl) => tbl.id.equals(id))).write(companion);
  }

  Future<int> deleteProductById(int id) {
    return (delete(products)..where((Products tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'pantry_scanner.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
