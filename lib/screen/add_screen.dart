import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenAdd extends StatefulWidget {
  const ScreenAdd({super.key});

  @override
  State<ScreenAdd> createState() => _ScreenAddState();
}

class _ScreenAddState extends State<ScreenAdd> {
  int _selectedSegment = 0;
  final List<String> _segments = ["Equity", "Options", "Futures"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                ),
                const SizedBox(height: 30),
                _buildSegmentSelector(),
                const SizedBox(height: 30),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildInputLabel("SYMBOL"),
                      _buildTextField("e.g. NIFTY 50", Icons.search_rounded),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("BUY PRICE"),
                                _buildTextField("0.00", Icons.add_circle_outline_rounded, isNumber: true),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("SELL PRICE"),
                                _buildTextField("0.00", Icons.remove_circle_outline_rounded, isNumber: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputLabel("QUANTITY"),
                      _buildTextField("0", Icons.layers_outlined, isNumber: true),
                      const SizedBox(height: 20),
                      _buildInputLabel("TRADE TYPE"),
                      _buildDropdownField(["Intraday", "Swing", "Longterm"]),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                GlassButton(
                  onPressed: () {},
                  color: Colors.greenAccent.withOpacity(0.1),
                  child: Text(
                    "SAVE TRADE",
                    style: GoogleFonts.outfit(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
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
                  color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _segments[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
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

  Widget _buildTextField(String hint, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField(List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text("Select Type", style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2))),
          dropdownColor: Colors.grey[900],
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white30),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.outfit(color: Colors.white)),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}
