import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/item_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_form_screen.dart';
import '../../services/mora_notifier.dart';

class DetailScreen extends StatefulWidget {
  final ItemModel item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = false;
  int _quantity = 1;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'user';
    });
  }

  // ── FORMAT ANGKA ───────────────────────────────────────────
  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  // ── USER: Buy ──────────────────────────────────────────────
  void _showBuyConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.item.price * _quantity;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Purchase',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Quantity: $_quantity',
                style: GoogleFonts.poppins(fontSize: 13)),
            Row(
              children: [
                Text('Total: ', style: GoogleFonts.poppins(fontSize: 13)),
                Image.asset(
                  'assets/images/mora_icon.png',
                  height: 14,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.monetization_on,
                      color: AppColors.gold,
                      size: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatPrice(total),
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _doBuy();
            },
            child: Text('Buy',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _doBuy() async {
  setState(() => _isLoading = true);
  final result = await ApiService.buyItem(widget.item.id, _quantity);
  setState(() => _isLoading = false);

  if (!mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final success = result['success'] == true;

  if (success) {
    final newMora = result['data']?['mora'];
    if (newMora != null) {
      final moraValue = double.parse(newMora.toString());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_mora', moraValue);
      MoraNotifier.instance.update(moraValue); // ← tambah ini
    }
  }

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        success
          ? (result['message'] ?? 'Purchase successful!')
          : (result['message']?.toString().toLowerCase().contains('mora') == true
              ? 'Not enough mora'
              : (result['message'] ?? 'Purchase failed')),
        style: GoogleFonts.poppins()),
      backgroundColor: success ? Colors.green : AppColors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );

  if (success && mounted) Navigator.pop(context);
}

  // ── ADMIN: Delete ──────────────────────────────────────────
  void _showDeleteConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to delete ${widget.item.name}?',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _doDelete();
            },
            child: Text('Delete',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _doDelete() async {
    setState(() => _isLoading = true);
    await ApiService.deleteItem(widget.item.id);
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} deleted.',
            style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  // ── ADMIN: Edit ────────────────────────────────────────────
  Future<void> _goToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminFormScreen(item: widget.item),
      ),
    );
    if (result == true && mounted) Navigator.pop(context, true);
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final isAdmin = _userRole == 'admin';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            Container(
              width: double.infinity,
              height: 280,
              color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
              child: Image.network(
                ApiService.buildImageUrl(item.image),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey),
                  ),
                ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  // Type + Category chips
                  Row(
                    children: [
                      _chip(item.type, AppColors.gold, Colors.black),
                      const SizedBox(width: 8),
                      _chip(
                        item.category,
                        isDark
                            ? AppColors.darkHeader
                            : AppColors.lightBorder,
                        isDark
                            ? AppColors.lightBackground
                            : AppColors.darkBackground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  _infoRow(
                    'Stock',
                    '${item.stock} available',
                    isDark,
                    valueColor:
                        item.stock > 0 ? Colors.green : AppColors.red,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('Description',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mora icon + price
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/mora_icon.png',
                            height: 22,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.monetization_on,
                              color: AppColors.gold,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatPrice(item.price),
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold),
                          ),
                        ],
                      ),

                      // Quantity selector — hanya untuk user
                      if (!isAdmin)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 36, minHeight: 36),
                              ),
                              Text(
                                '$_quantity',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: _quantity < item.stock
                                    ? () => setState(() => _quantity++)
                                    : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 36, minHeight: 36),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Tombol Admin: Edit + Delete ──
                  if (isAdmin) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading ? null : _goToEdit,
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text('Edit',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : _showDeleteConfirmation,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.delete, size: 18),
                              label: Text('Delete',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // ── Tombol User: Buy ──
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              item.stock > 0 ? AppColors.gold : Colors.grey,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: item.stock > 0 && !_isLoading
                            ? _showBuyConfirmation
                            : null,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black),
                              )
                            : Text(
                                item.stock > 0 ? 'Buy' : 'Out of Stock',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }

  Widget _infoRow(String label, String value, bool isDark,
      {Color? valueColor}) {
    return Row(
      children: [
        Text('$label: ',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 13)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: valueColor ??
                    (isDark ? Colors.white70 : Colors.black87))),
      ],
    );
  }
}