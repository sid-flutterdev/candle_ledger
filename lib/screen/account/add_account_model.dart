import 'dart:ui';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAccountModal extends StatefulWidget {
  final Account? accountToEdit;
  const AddAccountModal({super.key, this.accountToEdit});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedBroker = 'Zerodha';
  // int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.accountToEdit != null) {
      final acc = widget.accountToEdit!;
      _selectedBroker = acc.broker;
      _nameController.text = acc.name.replaceFirst('${acc.broker} - ', '');
      if (_nameController.text == acc.broker) _nameController.text = '';
      _balanceController.text = acc.initialBalance.toString();
      _selectedColorIndex = _colors.indexWhere((c) => c.toARGB32() == acc.colorHex);
      if (_selectedColorIndex == -1) _selectedColorIndex = 0;
    }
  }

  final List<String> _brokers = [
    'Zerodha',
    'Angel One',
    'Upstox',
    'Groww',
    'Dhan',
    'Fyers',
    'Kotak Neo',
    'HDFC Sky',
    'ICICI Direct',
    'Forex',
    'Others',
  ];
  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
    Colors.amberAccent,
    Colors.indigoAccent,
    Colors.limeAccent,
    Colors.deepOrangeAccent,
    Colors.deepPurpleAccent,
    Colors.yellowAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.accountToEdit != null
                    ? "Edit Account"
                    : "Add New Account",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Select Broker",
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _brokers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedBroker == _brokers[index];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedBroker = _brokers[index]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _brokers[index],
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                "Account Name (Optional)",
                _nameController,
                "Defaults to broker name",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Initial Balance",
                _balanceController,
                "₹ 0.00",
                isNumber: true,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GlassButton(
      onPressed: () async {
        if (_balanceController.text.isEmpty) {
          AppSnackbar.error("Error", "Please enter initial balance");
          return;
        }

        HapticFeedback.mediumImpact();
        final balance = double.tryParse(_balanceController.text) ?? 0.0;
        final controller = Get.find<AccountController>();
        final name = _nameController.text.isEmpty
            ? _selectedBroker
            : '$_selectedBroker - ${_nameController.text}';

        if (widget.accountToEdit != null) {
          await controller.editAccount(
            widget.accountToEdit!.id,
            name: name,
            broker: _selectedBroker,
            colorHex: _colors[_selectedColorIndex].toARGB32(),
            initialBalance: balance,
          );
        } else {
          final account = Account(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            broker: _selectedBroker,
            initialBalance: balance,
            liquidBalance: balance,
            investedBalance: 0,
            iconIndex: 0,
            colorHex: _colors[_selectedColorIndex].toARGB32(),
          );
          await controller.addAccount(account);
        }
        Get.back();
      },
      color: widget.accountToEdit != null
          ? Colors.blueAccent.withValues(alpha: 0.1)
          : Colors.greenAccent.withValues(alpha: 0.1),
      child: Text(
        widget.accountToEdit != null ? "SAVE CHANGES" : "CREATE ACCOUNT",
        style: GoogleFonts.outfit(
          color: widget.accountToEdit != null
              ? Colors.blueAccent
              : Colors.greenAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
