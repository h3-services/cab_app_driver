import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../theme/colors.dart';

class TripCostBreakdownScreen extends StatelessWidget {
  final Trip trip;
  final int endKm;
  final double tollAmount;
  final double driverAllowance;

  const TripCostBreakdownScreen({
    super.key,
    required this.trip,
    required this.endKm,
    required this.tollAmount,
    required this.driverAllowance,
  });

  @override
  Widget build(BuildContext context) {
    final distanceTraveled = endKm - (trip.startKm ?? 0);
    final kmRate = _getKmRate(trip.vehicleType);
    final kmCost = distanceTraveled * kmRate;
    final totalCost = kmCost + tollAmount + driverAllowance;
    final walletFee = kmCost * 0.02; // 2% of KM cost
    final netEarnings = totalCost - walletFee;

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Trip Cost Breakdown'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Trip Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow('Distance Traveled', '$distanceTraveled km'),
                          _buildSummaryRow('Vehicle Type', trip.vehicleType),
                          _buildSummaryRow('Rate per KM', '₹${kmRate.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cost Breakdown Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cost Breakdown',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildHighlightedCostRow('KM Cost', kmCost, AppColors.blueStart),
                          _buildHighlightedCostRow('Toll Amount', tollAmount, AppColors.pendingColor),
                          _buildCostRow('Driver Allowance', driverAllowance, AppColors.acceptedColor),
                          const Divider(height: 24),
                          _buildCostRow('Total Cost', totalCost, AppColors.primaryText, isTotal: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fee Deduction Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.rejectedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.rejectedColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.rejectedColor),
                              const SizedBox(width: 8),
                              Text(
                                'Wallet Fee Deduction',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.rejectedColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Wallet Fee (2% of KM cost): ₹${walletFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.rejectedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Net Earnings Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.acceptedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.acceptedColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet, 
                               color: AppColors.acceptedColor, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Net Earnings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.acceptedColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${netEarnings.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.acceptedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _downloadPdfReceipt(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 18),
                        SizedBox(width: 8),
                        Text('Download PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _closeTrip(context, netEarnings, walletFee),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.acceptedColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close Trip',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.grayText,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, Color color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? color : AppColors.grayText,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedCostRow(String label, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _downloadPdfReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF Receipt downloaded successfully!'),
        backgroundColor: AppColors.acceptedColor,
      ),
    );
  }

  double _getKmRate(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'sedan':
        return 12.0;
      case 'suv':
        return 15.0;
      case 'hatchback':
        return 10.0;
      default:
        return 12.0;
    }
  }

  void _closeTrip(BuildContext context, double netEarnings, double walletFee) {
    Navigator.pop(context, {
      'netEarnings': netEarnings,
      'walletFee': walletFee,
      'endKm': endKm,
      'tollAmount': tollAmount,
      'driverAllowance': driverAllowance,
    });
  }
}