import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ExcelFileRenderer extends StatelessWidget {
  final Uint8List blobData;

  ExcelFileRenderer({required this.blobData});

  @override
  Widget build(BuildContext context) {
    // Parse the Excel blob data
    final List<Map<String, dynamic>> excelData = parseExcel(blobData);

    if (excelData.isEmpty) {
      return const Center(
        child: Text("No data found in the Excel file."),
      );
    }

    // Create a data source for SfDataGrid
    final ExcelDataSource dataSource = ExcelDataSource(excelData);

    return SfDataGrid(
      source: dataSource,
      columns: excelData.first.keys
          .map((key) => GridColumn(
        columnName: key,
        label: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ))
          .toList(),
    );
  }

  // Parse Excel data
  List<Map<String, dynamic>> parseExcel(Uint8List data) {
    final Excel excel = Excel.decodeBytes(data);
    final List<Map<String, dynamic>> excelData = [];

    for (var table in excel.tables.keys) {
      final Sheet sheet = excel.tables[table]!;
      if (sheet.maxRows == 0) continue;

      // Extract headers
      final List<String?> headers = sheet.rows.first
          .map((cell) => cell?.value?.toString())
          .toList();

      // Extract data rows
      for (int i = 1; i < sheet.maxRows; i++) {
        final List<Data?> row = sheet.rows[i];
        final Map<String, dynamic> rowData = {};

        for (int j = 0; j < headers.length; j++) {
          final header = headers[j];
          if (header != null) {
            rowData[header] = row[j]?.value?.toString() ?? '';
          }
        }

        excelData.add(rowData);
      }

      break; // Parse only the first sheet
    }

    return excelData;
  }
}

class ExcelDataSource extends DataGridSource {
  final List<Map<String, dynamic>> data;
  late List<DataGridRow> _dataGridRows;

  ExcelDataSource(this.data) {
    _dataGridRows = data.map<DataGridRow>((row) {
      return DataGridRow(
        cells: row.entries.map<DataGridCell>((entry) {
          return DataGridCell(columnName: entry.key, value: entry.value);
        }).toList(),
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }
}