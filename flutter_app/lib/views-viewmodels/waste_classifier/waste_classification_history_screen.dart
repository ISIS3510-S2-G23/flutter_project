import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ecosphere/models/classification_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class WasteClassificationHistoryScreen extends StatelessWidget {
  const WasteClassificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ClassificationEntry>('classifications');
    final entries = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Más recientes primero

    return Scaffold(
      appBar: AppBar(
        title: const Text("Classification History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear History",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Deletion"),
                  content: const Text(
                      "Are you sure you want to clear the entire history?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      child: const Text("Delete"),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await box.clear();

                // Ignoramos errores si hay imágenes huérfanas
                try {
                  final tempDir = Directory.systemTemp;
                  for (var entry in entries) {
                    final file = File(p.join(tempDir.path, entry.hash));
                    if (file.existsSync()) file.deleteSync();
                  }
                } catch (_) {}

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("History cleared successfully")),
                );

                (context as Element).reassemble(); // Forzar redibujo
              }
            },
          )
        ],
      ),
      body: entries.isEmpty
          ? const Center(child: Text("No classifications saved yet."))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

                final tempDir = Directory.systemTemp;
                final file = File(p.join(tempDir.path, entry.hash));

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: file.existsSync()
                        ? Image.file(file,
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
                    title: Text(entry.classification),
                    subtitle: Text(
                      'Date: ${entry.date.toLocal().toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
