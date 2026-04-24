import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScreenAddTrade extends StatefulWidget {
  final Trade? tradeToEdit;
  const ScreenAddTrade({super.key, this.tradeToEdit});

  @override
  State<ScreenAddTrade> createState() => _ScreenAddTradeState();
}

class _ScreenAddTradeState extends State<ScreenAddTrade> {
  final AccountController accountController = Get.find<AccountController>();
  final TradeController tradeController = Get.find<TradeController>();
  final NavigationController nav = Get.find<NavigationController>();

  int _selectedSegment = 0;
  final List<String> _segments = ["Equity", "Options", "Futures"];

  // Form Controllers
  final _symbolController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  final _scriptController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TradeType _selectedTradeType = TradeType.intraday;
  OptionType _selectedOptionType = OptionType.ce;
  String _selectedRR = "1:1";
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    if (widget.tradeToEdit != null) {
      final t = widget.tradeToEdit!;
      _selectedSegment = t.segment.index;
      _symbolController.text = t.symbol;
      _buyPriceController.text = t.buyPrice.toString();
      _sellPriceController.text = t.sellPrice.toString();
      _quantityController.text = t.quantity.toString();
      _noteController.text = t.note ?? "";
      _scriptController.text = t.script ?? "";
      _selectedDate = t.date;
      _selectedRR = t.rrRatio;
      if (t.tradeType != null) _selectedTradeType = t.tradeType!;
      if (t.optionType != null) _selectedOptionType = t.optionType!;
      final accounts = accountController.accounts;
      _selectedAccount = accounts.firstWhere(
        (acc) => acc.id == t.accountId,
        orElse: () => accounts.isNotEmpty
            ? accounts.first
            : throw "No accounts available",
      );
    } else {
      if (accountController.accounts.isNotEmpty) {
        _selectedAccount = accountController.accounts.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildSegmentSelector(),
                const SizedBox(height: 30),
                _buildForm(),
                const SizedBox(height: 30),
                _buildSaveButton(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.tradeToEdit != null ? "Edit Trade" : "Add Trade",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: GlassContainer(
        width: 44,
        height: 44,
        borderRadius: 12,
        padding: EdgeInsets.zero,
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildSegmentSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(6),
      borderRadius: 16,
      child: Row(
        children: List.generate(_segments.length, (index) {
          bool isSelected = _selectedSegment == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _segments[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildInputLabel("SYMBOL"),
          _buildTextField(
            _symbolController,
            "e.g. NIFTY 50",
            Icons.search_rounded,
          ),

          if (_selectedSegment == 1) ...[
            // Options
            const SizedBox(height: 20),
            _buildInputLabel("SCRIPT (STRIKE)"),
            _buildTextField(
              _scriptController,
              "e.g. 24600",
              Icons.numbers_rounded,
              isNumber: true,
            ),
            const SizedBox(height: 20),
            _buildOptionTypeSelector(),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel("BUY PRICE"),
                    _buildTextField(
                      _buyPriceController,
                      "0.00",
                      Icons.add_circle_outline_rounded,
                      isNumber: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel("SELL PRICE"),
                    _buildTextField(
                      _sellPriceController,
                      "0.00",
                      Icons.remove_circle_outline_rounded,
                      isNumber: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputLabel("QUANTITY"),
          _buildTextField(
            _quantityController,
            "0",
            Icons.layers_outlined,
            isNumber: true,
          ),

          if (_selectedSegment == 0) ...[
            // Equity
            const SizedBox(height: 20),
            _buildInputLabel("TRADE TYPE"),
            _buildTradeTypeDropdown(),
          ],

          const SizedBox(height: 20),
          _buildInputLabel("R:R RATIO"),
          _buildRRSelector(),

          const SizedBox(height: 20),
          _buildInputLabel("SELECT ACCOUNT"),
          _buildAccountDropdown(),

          const SizedBox(height: 20),
          _buildInputLabel("NOTES"),
          _buildTextField(
            _noteController,
            "Add a note...",
            null, // No icon
            maxLines: 3, // Decreased height
            textAlign: TextAlign.center, // Center text
          ),

          const SizedBox(height: 30),
          _buildInputLabel("SCREENSHOTS"),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              color: Colors.white.withValues(alpha: 0.03),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orangeAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Visual Journaling",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "Attach charts & proofs with Premium",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Pro",
                      style: GoogleFonts.outfit(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Colors.blueAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM, yyyy').format(_selectedDate),
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTypeSelector() {
    return Row(
      children: [
        _buildSegmentButton(
          "CE",
          _selectedOptionType == OptionType.ce,
          () => setState(() => _selectedOptionType = OptionType.ce),
        ),
        const SizedBox(width: 12),
        _buildSegmentButton(
          "PE",
          _selectedOptionType == OptionType.pe,
          () => setState(() => _selectedOptionType = OptionType.pe),
        ),
      ],
    );
  }

  Widget _buildSegmentButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTradeTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TradeType>(
          isExpanded: true,
          value: _selectedTradeType,
          dropdownColor: const Color(0xFF0D0D0D).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white30,
          ),
          items: TradeType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type.name.capitalizeFirst!,
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedTradeType = val!),
        ),
      ),
    );
  }

  Widget _buildRRSelector() {
    final ratios = ["1:1", "1:2", "1:3", "1:4", "1:5"];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ratios.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isSelected = _selectedRR == ratios[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedRR = ratios[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                ratios[index],
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountDropdown() {
    return Obx(() {
      if (accountController.accounts.isEmpty) {
        return GestureDetector(
          onTap: () => AppSnackbar.error(
            "No Account",
            "Please create an account in Portfolio first",
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              "No account found. Create one first!",
              style: GoogleFonts.outfit(color: Colors.redAccent),
            ),
          ),
        );
      }
      // Safety: Check if the currently selected account exists in the list
      // This prevents the 'Failed assertion: items.where(...).length == 1' crash
      final currentAccounts = accountController.accounts;
      Account? safeValue = _selectedAccount;
      if (safeValue != null) {
        final bool exists = currentAccounts.any(
          (acc) => acc.id == safeValue!.id,
        );
        if (!exists) {
          safeValue = currentAccounts.isNotEmpty ? currentAccounts.first : null;
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Account>(
            isExpanded: true,
            value: safeValue,
            dropdownColor: const Color(0xFF0D0D0D).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white30,
            ),
            items: currentAccounts.map((acc) {
              return DropdownMenuItem(
                value: acc,
                child: Text(
                  acc.name,
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedAccount = val);
            },
          ),
        ),
      );
    });
  }

  Widget _buildSaveButton() {
    final isEdit = widget.tradeToEdit != null;
    return GlassButton(
      onPressed: _saveTrade,
      color: isEdit
          ? AppColors.secondary.withValues(alpha: 0.1)
          : AppColors.profitGreen.withValues(alpha: 0.1),
      child: Text(
        isEdit ? "SAVE CHANGES" : "SAVE TRADE",
        style: GoogleFonts.outfit(
          color: isEdit ? AppColors.secondary : AppColors.profitGreen,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _saveTrade() async {
    HapticFeedback.mediumImpact();
    final isEdit = widget.tradeToEdit != null;
    if (_symbolController.text.isEmpty ||
        _buyPriceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedAccount == null) {
      AppSnackbar.error("Error", "Please fill all required fields");
      return;
    }

    final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    final sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final totalCost = buyPrice * quantity;

    if (_selectedAccount != null &&
        totalCost > _selectedAccount!.liquidBalance) {
      AppSnackbar.error(
        "Insufficient Funds",
        "Trade cost (₹$totalCost) exceeds your available liquid balance (₹${_selectedAccount!.liquidBalance})",
      );
      return;
    }

    final trade = Trade(
      id:
          widget.tradeToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      symbol: _symbolController.text.trim(),
      segment: TradeSegment.values[_selectedSegment],
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      rrRatio: _selectedRR,
      accountId: _selectedAccount!.id,
      note: _noteController.text.trim(),
      tradeType: _selectedSegment == 0 ? _selectedTradeType : null,
      script: _selectedSegment == 1 ? _scriptController.text.trim() : null,
      optionType: _selectedSegment == 1 ? _selectedOptionType : null,
    );

    try {
      if (widget.tradeToEdit != null) {
        // 1. Revert balance of original account
        await accountController.updateBalance(
          widget.tradeToEdit!.accountId,
          widget.tradeToEdit!.pnl,
          true, // Removal
        );
        // 2. Update trade in Hive & Firestore
        await tradeController.updateTrade(trade);
        // 3. Apply balance to current (possibly new) account
        await accountController.updateBalance(
          _selectedAccount!.id,
          trade.pnl,
          false, // Addition
        );
      } else {
        await tradeController.addTrade(trade);
        await accountController.updateBalance(
          _selectedAccount!.id,
          trade.pnl,
          false,
        );
      }

      Get.back();
      AppSnackbar.success(
        isEdit ? "Trade Updated" : "Trade Added",
        "${trade.symbol} trade ${isEdit ? 'updated' : 'added'} successfully",
      );
    } catch (e) {
      AppSnackbar.error("Save Failed", "An error occurred while saving: $e");
    }
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData? icon, {
    bool isNumber = false,
    int? maxLines = 1,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        maxLines: maxLines,
        textAlign: textAlign,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 20,
                )
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.2),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
