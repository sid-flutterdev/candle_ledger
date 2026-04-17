import 'package:flutter/material.dart';

class ScreenAdd extends StatefulWidget {
  const ScreenAdd({super.key});

  @override
  State<ScreenAdd> createState() => _ScreenAddState();
}

class _ScreenAddState extends State<ScreenAdd> {
  int _selectedSegment = 0;

  String? _selectedTradeType;
  String? _selectedRRRatio;
  String? _selectedRuleFollowed;
  String? _selectedAccount;

  final List<String> _tradeTypes = ['Intraday', 'Swing', 'Longterm'];
  final List<String> _rrRatios = ['1:1', '1:2', '1:3', '1:4', '1:5'];
  final List<String> _rulesFollowed = ['Yes', 'No'];
  final List<String> _accounts = ['Zerodha', 'Angel One']; // Placeholder for portfolio accounts

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Trade",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        // Assuming close behavior or back
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Segment Control (Equity, Options, Futures)
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton(0, "Equity"),
                    _buildSegmentButton(1, "Options"),
                    _buildSegmentButton(2, "Futures"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      "DATE",
                      _selectedDate == null 
                          ? "Select" 
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      Icons.calendar_today,
                      () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateTimeField(
                      "TIME",
                      _selectedTime == null 
                          ? "Select" 
                          : _selectedTime!.format(context),
                      Icons.access_time,
                      () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Fields
              _buildTextField("SYMBOL", "e.g., NIFTY 50"),
              const SizedBox(height: 20),
              
              _buildTextField("BUY ₹", "0.00", isNumber: true),
              const SizedBox(height: 20),
              
              _buildTextField("SELL ₹", "0.00", isNumber: true),
              const SizedBox(height: 20),
              
              _buildTextField("QTY", "0", isNumber: true),
              const SizedBox(height: 20),

              _buildDropdownField("TRADE TYPE", "Select", _selectedTradeType, _tradeTypes, (val) {
                setState(() => _selectedTradeType = val);
              }),
              const SizedBox(height: 20),

              _buildDropdownField("R:R RATIO", "Select", _selectedRRRatio, _rrRatios, (val) {
                setState(() => _selectedRRRatio = val);
              }),
              const SizedBox(height: 20),

              _buildDropdownField("RULE FOLLOWED", "Select", _selectedRuleFollowed, _rulesFollowed, (val) {
                setState(() => _selectedRuleFollowed = val);
              }),
              const SizedBox(height: 20),

              _buildDropdownField("ACCOUNT", "Select", _selectedAccount, _accounts, (val) {
                setState(() => _selectedAccount = val);
              }),
              const SizedBox(height: 20),

              // Note
              const Text("NOTE", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: const TextField(
                  maxLines: 4,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Add a note about this trade...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Screenshot
              const Text("SCREENSHOT", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Handle upload
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.upload_file, color: Colors.grey, size: 32),
                      SizedBox(height: 12),
                      Text("Tap to upload", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Save action
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 100), // padding for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton(int index, String title) {
    bool isSelected = _selectedSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSegment = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(String label, String value, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(color: value == "Select" ? Colors.grey : Colors.white, fontSize: 16)),
                Icon(icon, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 16),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              value: value,
              dropdownColor: const Color(0xFF1E2230),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
