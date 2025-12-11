import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../models/transaction.dart';
import '../theme/colors.dart';

class WalletScreen extends StatefulWidget {
  final Driver driver;

  const WalletScreen({super.key, required this.driver});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<Transaction> _transactions = [
    Transaction(
      id: '1',
      amount: 250.0,
      type: 'trip_earning',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      tripId: 'TRIP001',
      description: 'Trip Earning - TRIP001',
    ),
    Transaction(
      id: '2',
      amount: -5.0,
      type: 'trip_fee',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      tripId: 'TRIP001',
      description: 'Trip Fee - TRIP001',
    ),
    Transaction(
      id: '3',
      amount: 180.0,
      type: 'trip_earning',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      tripId: 'TRIP002',
      description: 'Trip Earning - TRIP002',
    ),
    Transaction(
      id: '4',
      amount: -3.6,
      type: 'trip_fee',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 5)),
      tripId: 'TRIP002',
      description: 'Trip Fee - TRIP002',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [AppColors.emeraldStart, AppColors.emeraldEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Wallet Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${(widget.driver.walletBalance < 0 ? 0.0 : widget.driver.walletBalance).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Today\'s Earnings',
                    '₹430',
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Trips',
                    '3',
                    Icons.directions_car,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._transactions.map((transaction) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTransactionColor(transaction.type),
                  child: Icon(
                    _getTransactionIcon(transaction.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(_getTransactionTitle(transaction.type)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(transaction.timestamp)),
                    if (transaction.description != null)
                      Text(
                        transaction.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grayText,
                        ),
                      ),
                  ],
                ),
                trailing: Text(
                  '${transaction.amount >= 0 ? '+' : ''}₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.amount >= 0 ? AppColors.acceptedColor : AppColors.rejectedColor,
                  ),
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.grayText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'trip_earning':
        return AppColors.acceptedColor;
      case 'trip_fee':
        return AppColors.rejectedColor;
      case 'topup':
        return AppColors.blueStart;
      default:
        return AppColors.grayText;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'trip_earning':
        return Icons.directions_car;
      case 'trip_fee':
        return Icons.remove_circle;
      case 'topup':
        return Icons.add_circle;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getTransactionTitle(String type) {
    switch (type) {
      case 'trip_earning':
        return 'Trip Earning';
      case 'trip_fee':
        return 'Trip Fee';
      case 'topup':
        return 'Wallet Top-up';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}