import 'package:candle_ledger/bottomnavbar.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScreenAddTrade extends StatefulWidget {
  const ScreenAddTrade({super.key});

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
    if (accountController.accounts.isNotEmpty) {
      _selectedAccount = accountController.accounts.first;
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
      bottomNavigationBar: GlassBottomNavBar(
        selectedIndex: 2,
        onTap: nav.changeIndex,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Add Trade",
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
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _segments[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
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
            Icons.note_add_outlined,
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
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TradeType>(
          isExpanded: true,
          value: _selectedTradeType,
          dropdownColor: Colors.grey[900],
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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isSelected = _selectedRR == ratios[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedRR = ratios[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.05),
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
          onTap: () => Get.snackbar(
            "No Account",
            "Please create an account in Portfolio first",
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Text(
              "No account found. Create one first!",
              style: GoogleFonts.outfit(color: Colors.redAccent),
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Account>(
            isExpanded: true,
            value: _selectedAccount,
            dropdownColor: Colors.grey[900],
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white30,
            ),
            items: accountController.accounts.map((acc) {
              return DropdownMenuItem(
                value: acc,
                child: Text(
                  acc.name,
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedAccount = val),
          ),
        ),
      );
    });
  }

  Widget _buildSaveButton() {
    return GlassButton(
      onPressed: _saveTrade,
      color: Colors.greenAccent.withOpacity(0.1),
      child: Text(
        "SAVE TRADE",
        style: GoogleFonts.outfit(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _saveTrade() async {
    HapticFeedback.mediumImpact();
    if (_symbolController.text.isEmpty ||
        _buyPriceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedAccount == null) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    final sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final totalCost = buyPrice * quantity;

    if (totalCost > _selectedAccount!.initialBalance) {
      Get.snackbar(
        "Insufficient Funds",
        "Trade amount exceeds initial account balance",
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    final trade = Trade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      symbol: _symbolController.text,
      segment: TradeSegment.values[_selectedSegment],
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      rrRatio: _selectedRR,
      accountId: _selectedAccount!.id,
      note: _noteController.text,
      tradeType: _selectedSegment == 0 ? _selectedTradeType : null,
      script: _selectedSegment == 1 ? _scriptController.text : null,
      optionType: _selectedSegment == 1 ? _selectedOptionType : null,
    );

    await tradeController.addTrade(trade);
    await accountController.updateBalance(
      _selectedAccount!.id,
      trade.pnl,
      false,
    );

    Get.back();
    Get.snackbar(
      "Success",
      "Trade saved successfully",
      backgroundColor: Colors.greenAccent.withOpacity(0.8),
      colorText: Colors.black,
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.white.withOpacity(0.4),
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
    IconData icon, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.3),
            size: 20,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
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
