import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<void> writeData(String filename, String data) async {
    final file = await _localFile(filename);
    await file.writeAsString(data);
  }

  Future<String?> readData(String filename) async {
    try {
      final file = await _localFile(filename);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteData(String filename) async {
    try {
      final file = await _localFile(filename);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore error
    }
  }
}
