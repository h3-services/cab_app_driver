import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trip.dart';
import '../theme/colors.dart';

class OdometerInputScreen extends StatefulWidget {
  final Trip trip;
  final bool isStarting;

  const OdometerInputScreen({
    super.key,
    required this.trip,
    required this.isStarting,
  });

  @override
  State<OdometerInputScreen> createState() => _OdometerInputScreenState();
}

class _OdometerInputScreenState extends State<OdometerInputScreen> {
  final _kmController = TextEditingController();
  final _tollController = TextEditingController();
  final _allowanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: Text(widget.isStarting ? 'Enter Starting KM' : 'Complete Trip'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
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
                      widget.isStarting ? 'Starting Odometer Reading' : 'Trip Completion Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: widget.isStarting ? 'Starting KM' : 'Ending KM',
                        hintText: 'Enter odometer reading',
                        prefixIcon: Icon(Icons.speed, color: AppColors.blueStart),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.blueStart),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter KM reading';
                        }
                        final km = int.tryParse(value);
                        if (km == null) {
                          return 'Please enter a valid number';
                        }
                        if (!widget.isStarting && widget.trip.startKm != null && km <= widget.trip.startKm!) {
                          return 'Ending KM must be greater than starting KM (${widget.trip.startKm})';
                        }
                        return null;
                      },
                    ),
                    
                    if (!widget.isStarting) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tollController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Toll Amount (₹)',
                          hintText: 'Enter toll charges',
                          prefixIcon: Icon(Icons.toll, color: AppColors.pendingColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.pendingColor),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Please enter a valid amount';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _allowanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Driver Allowance (₹)',
                          hintText: 'Enter driver allowance',
                          prefixIcon: Icon(Icons.account_balance_wallet, color: AppColors.acceptedColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.acceptedColor),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Please enter a valid amount';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.acceptedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isStarting ? 'Start Trip' : 'Calculate Cost',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final km = int.parse(_kmController.text);
      
      if (widget.isStarting) {
        Navigator.pop(context, {'startKm': km});
      } else {
        final tollAmount = double.tryParse(_tollController.text) ?? 0.0;
        final driverAllowance = double.tryParse(_allowanceController.text) ?? 0.0;
        
        Navigator.pop(context, {
          'endKm': km,
          'tollAmount': tollAmount,
          'driverAllowance': driverAllowance,
        });
      }
    }
  }

  @override
  void dispose() {
    _kmController.dispose();
    _tollController.dispose();
    _allowanceController.dispose();
    super.dispose();
  }
}