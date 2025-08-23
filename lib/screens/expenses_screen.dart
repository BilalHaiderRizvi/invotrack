import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_view_model.dart';
import '../widgets/expense_form.dart';
import '../widgets/charts/expense_pie_chart.dart';
// import 'package:invotrack/widgets/charts/monthly_bar_chart.dart';
// import '../widgets/charts/monthly_line_chart.dart';
import 'invoice_screen.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();
    final df = DateFormat.yMMMM();

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses — ${df.format(vm.currentMonth)}'),
        actions: [
          IconButton(
            tooltip: 'Previous Month',
            onPressed: vm.goToPrevMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next Month',
            onPressed: vm.goToNextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            tooltip: 'Export CSV',
            onPressed: () async {
              final path = await vm.exportCsv();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV saved at: $path')),
                );
              }
            },
            icon: const Icon(Icons.table_view),
          ),
          IconButton(
            tooltip: 'Invoice',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceScreen()));
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      floatingActionButton: Opacity(
        opacity: 0.8, // Adjust transparency level (0.0 to 1.0)
        child: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Add'),
          onPressed: () => showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ExpenseForm(onSubmit: ({
                required title,
                required amount,
                required category,
                required date,
                String? notes,
              }) async {
                await vm.addExpense(title: title, amount: amount, category: category, date: date, notes: notes);
              }),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('₹ ${vm.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: ExpensePieChart(byCategory: vm.byCategory),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vm.expenses.length,
              itemBuilder: (ctx, i) {
                final e = vm.expenses[i];
                return Dismissible(
                  key: ValueKey(e.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) => vm.deleteExpense(e.id),
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text('${DateFormat.yMMMd().format(e.date)} • ${e.category}'),
                    trailing: Text('₹ ${e.amount.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),
          // SizedBox(
          //   height: 200, 
          //   child: Card(
          //     child: Padding(
          //       padding: const EdgeInsets.all(8),
          //       child: MonthlyBarChart(expenses: vm.expenses),
          //     ),
          //   ),
          // ),
          SizedBox(height: 35)
        ],
      ),
    );
  }
}
