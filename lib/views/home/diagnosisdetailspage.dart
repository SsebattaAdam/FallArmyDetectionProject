import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'newpage.dart'; // Assuming this is your detailed view page

class DiagnosisDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> diagnoses;

  const DiagnosisDetailPage({
    Key? key,
    required this.diagnoses,
  }) : super(key: key);

  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd – kk:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis History"),
        backgroundColor: Colors.green[700],
      ),
      body: diagnoses.isEmpty
          ? const Center(
        child: Text(
          "No diagnoses available.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diagnoses.length,
        itemBuilder: (context, index) {
          final item = diagnoses[index];
          final date = item['date'] is String
              ? DateTime.parse(item['date'])
              : item['date'] as DateTime;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                item['disease'] ?? 'Fall Armyworm',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${formatDate(date)}\nStage: ${item['stage'] ?? 'Unknown'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Newpagetobedefined(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
