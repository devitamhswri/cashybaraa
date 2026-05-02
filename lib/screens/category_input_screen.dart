import 'package:flutter/material.dart';
import 'app_state.dart';

class CategoryInputScreen extends StatefulWidget {
  final CategoryData category;
  final int totalSaldo;
  final void Function(int amount) onSave;

  const CategoryInputScreen({
    super.key,
    required this.category,
    required this.totalSaldo,
    required this.onSave,
  });

  @override
  State<CategoryInputScreen> createState() => _CategoryInputScreenState();
}

class _CategoryInputScreenState extends State<CategoryInputScreen> {
  String _input = '0';

  int get _amount {
    final clean = _input.replaceAll(',', '.');
    return (double.tryParse(clean) ?? 0).round();
  }

  double get _pct {
    if (widget.totalSaldo == 0) return 0;
    return (_amount / widget.totalSaldo) * 100;
  }

  int get _sisa => widget.totalSaldo - _amount;

  void _onKey(String key) {
    setState(() {
      if (key == 'DEL') {
        if (_input.length <= 1) {
          _input = '0';
        } else {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (key == ',') {
        if (!_input.contains(',')) _input += ',';
      } else if (key == '0' && _input == '0') {
        // jangan tambah 0 di depan
      } else {
        if (_input == '0') {
          _input = key;
        } else {
          // batasi 12 digit
          if (_input.replaceAll(',', '').length < 12) {
            _input += key;
          }
        }
      }
    });
  }

  String _formatRp(int num) {
    final s = num.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp$s';
  }

  String get _displayAmount {
    // Format input dengan titik ribuan
    final parts = _input.split(',');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    if (parts.length > 1) return 'Rp$intPart,${parts[1]}';
    return 'Rp$intPart';
  }

  @override
  Widget build(BuildContext context) {
    final pct = _pct;
    final sisa = _sisa;
    final Color progressColor = pct > 100
        ? const Color(0xFFEF5350)
        : pct > 75
            ? const Color(0xFFFFA726)
            : widget.category.color;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24, color: Color(0xFF2D2218)),
                  ),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF2D2218)),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),

          // ── DISPLAY AMOUNT ──────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: Text(
                _displayAmount,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF2D2218),
                  letterSpacing: -1,
                ),
              ),
            ),
          ),

          // ── PROGRESS BAR ────────────────────────────────────────────────────
          Container(
            color: progressColor.withOpacity(0.12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatRp(_amount),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: progressColor)),
                        Text('${pct.toStringAsFixed(1)}% Digunakan',
                            style: TextStyle(fontSize: 11, color: progressColor.withOpacity(0.8))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_formatRp(sisa < 0 ? 0 : sisa),
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: sisa < 0 ? const Color(0xFFEF5350) : const Color(0xFF4A3728),
                            )),
                        Text(sisa < 0 ? 'Melebihi saldo!' : '${(100 - pct).clamp(0, 100).toStringAsFixed(1)}% Tersisa',
                            style: TextStyle(
                              fontSize: 11,
                              color: sisa < 0 ? const Color(0xFFEF5350) : const Color(0xFF9E8F82),
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ],
            ),
          ),

          // ── NUMPAD ──────────────────────────────────────────────────────────
          Container(
            color: const Color(0xFFF8F6F3),
            child: Column(
              children: [
                _buildNumRow(['7', '8', '9', 'DEL']),
                _buildNumRow(['4', '5', '6', '+/-']),
                _buildNumRow(['1', '2', '3', '']),
                _buildBottomRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumRow(List<String> keys) {
    return Row(
      children: keys.map((k) {
        if (k == '') {
          // Tombol kosong
          return Expanded(child: SizedBox(height: 72));
        }
        final isDel = k == 'DEL';
        final isOp = k == '+/-';
        return Expanded(
          child: GestureDetector(
            onTap: isDel ? () => _onKey('DEL') : isOp ? null : () => _onKey(k),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEE8E2), width: 0.5),
              ),
              child: Center(
                child: isDel
                    ? const Icon(Icons.backspace_outlined, size: 22, color: Color(0xFF4A3728))
                    : Text(k,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: isOp ? const Color(0xFF9E8F82) : const Color(0xFF2D2218),
                        )),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Rp / IDR label
        Expanded(
          child: Container(
            height: 72,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEEE8E2), width: 0.5)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Rp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2218))),
                  Text('IDR', style: TextStyle(fontSize: 10, color: Color(0xFF9E8F82))),
                ],
              ),
            ),
          ),
        ),
        // 0
        Expanded(
          child: GestureDetector(
            onTap: () => _onKey('0'),
            child: Container(
              height: 72,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEEE8E2), width: 0.5),
                  left: BorderSide(color: Color(0xFFEEE8E2), width: 0.5),
                ),
              ),
              child: const Center(
                child: Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFF2D2218))),
              ),
            ),
          ),
        ),
        // Koma
        Expanded(
          child: GestureDetector(
            onTap: () => _onKey(','),
            child: Container(
              height: 72,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEEE8E2), width: 0.5),
                  left: BorderSide(color: Color(0xFFEEE8E2), width: 0.5),
                ),
              ),
              child: const Center(
                child: Text(',', style: TextStyle(fontSize: 24, color: Color(0xFF2D2218))),
              ),
            ),
          ),
        ),
        // Tombol centang / simpan
        Expanded(
          child: GestureDetector(
            onTap: () {
              widget.onSave(_amount);
              Navigator.pop(context);
            },
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3728),
                border: Border.all(color: const Color(0xFFEEE8E2), width: 0.5),
              ),
              child: const Center(
                child: Icon(Icons.check_rounded, size: 28, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}