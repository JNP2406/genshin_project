import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transaction_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../services/mora_notifier.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  DateTime _selectedMonth = DateTime.now();
  bool _showCalendar = false;
  int? _selectedDay;
  double _mora = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    MoraNotifier.instance.addListener(_onMoraChanged);
  }

  void _onMoraChanged() {
    setState(() => _mora = MoraNotifier.instance.value);
  }

  @override
  void dispose() {
    MoraNotifier.instance.removeListener(_onMoraChanged);
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    final mora = MoraNotifier.instance.value > 0
        ? MoraNotifier.instance.value
        : prefs.getDouble('user_mora') ?? 0;

    if (!mounted) return; // ← tambah ini
  setState(() {
    _isAdmin = role == 'admin';
    _mora = mora;
    });

    final data = role == 'admin'
        ? await ApiService.getAllTransactions()
        : await ApiService.getMyTransactions();

    if (!mounted) return; // ← tambah ini
  setState(() {
    _transactions = data;
    _isLoading = false;
  });
  }

  List<TransactionModel> get _monthTransactions {
    return _transactions.where((t) {
      final date = DateTime.tryParse(t.createdAt);
      if (date == null) return false;
      return date.month == _selectedMonth.month &&
          date.year == _selectedMonth.year;
    }).toList();
  }

  List<TransactionModel> get _filtered {
    if (_selectedDay == null) return _monthTransactions;
    return _monthTransactions.where((t) {
      final date = DateTime.tryParse(t.createdAt);
      return date != null && date.day == _selectedDay;
    }).toList();
  }

  double get _totalAmount =>
      _filtered.fold(0, (sum, t) => sum + t.totalPrice);

  Map<int, List<TransactionModel>> get _groupedByUser {
    final map = <int, List<TransactionModel>>{};
    for (final t in _filtered) {
      map.putIfAbsent(t.userId, () => []).add(t);
    }
    return map;
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatMonth(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

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

  void _prevMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkHeader : AppColors.lightHeader,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          isDark
              ? 'assets/images/logo_light.png'
              : 'assets/images/logo_dark.png',
          height: 36,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mora_icon.png',
                  height: 18,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.monetization_on,
                    color: AppColors.gold,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatPrice(_mora),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                              () => _showCalendar = !_showCalendar),
                          child: Icon(
                            Icons.calendar_month,
                            size: 22,
                            color: _showCalendar
                                ? AppColors.gold
                                : (isDark
                                    ? Colors.white54
                                    : Colors.black45),
                          ),
                        ),
                        if (_selectedDay != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            '${_selectedDay.toString().padLeft(2, '0')} ${_formatMonth(_selectedMonth)}',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDay = null),
                            child: const Icon(Icons.close,
                                size: 14, color: AppColors.gold),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _isAdmin ? 'Total Income' : 'Total Outcome',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/mora_icon.png',
                                height: 18,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.monetization_on,
                                        color: Colors.black87,
                                        size: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatPrice(_totalAmount),
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedDay != null
                              ? '${_selectedDay.toString().padLeft(2, '0')} ${_formatMonth(_selectedMonth)}'
                              : _formatMonth(_selectedMonth),
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  if (_showCalendar) _buildCalendar(isDark),

                  const SizedBox(height: 12),

                  _filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey
                                      .withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text(
                                _selectedDay != null
                                    ? 'No transactions on this day'
                                    : 'No transactions this month',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : _isAdmin
                          ? _buildAdminList(isDark)
                          : _buildUserList(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildCalendar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _prevMonth,
              ),
              Text(
                _formatMonth(_selectedMonth),
                style:
                    GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Text(d,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey)))
                .toList(),
          ),
          const SizedBox(height: 8),
          _buildDaysGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildDaysGrid(bool isDark) {
    final firstDay =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    final activeDates = _monthTransactions
        .map((t) => DateTime.tryParse(t.createdAt)?.day)
        .whereType<int>()
        .toSet();

    final totalCells = startWeekday + lastDay.day;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: rows * 7,
      itemBuilder: (_, index) {
        final dayNum = index - startWeekday + 1;
        if (dayNum < 1 || dayNum > lastDay.day) {
          return const SizedBox();
        }

        final hasTransaction = activeDates.contains(dayNum);
        final isToday = DateTime.now().day == dayNum &&
            DateTime.now().month == _selectedMonth.month &&
            DateTime.now().year == _selectedMonth.year;
        final isSelected = _selectedDay == dayNum;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay =
                  (_selectedDay == dayNum) ? null : dayNum;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gold
                  : hasTransaction
                      ? AppColors.gold.withValues(alpha: 0.25)
                      : isToday
                          ? AppColors.gold.withValues(alpha: 0.1)
                          : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.gold, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                '$dayNum',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: (hasTransaction || isSelected)
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isSelected
                      ? Colors.black
                      : hasTransaction
                          ? AppColors.gold
                          : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserList(bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final t = _filtered[index];
        return _transactionTile(t, isDark);
      },
    );
  }

  Widget _buildAdminList(bool isDark) {
    final grouped = _groupedByUser;
    final userIds = grouped.keys.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: userIds.length,
      itemBuilder: (_, index) {
        final userId = userIds[index];
        final userTransactions = grouped[userId]!;
        final firstTx = userTransactions.first;
        final userName = firstTx.userName ?? 'User #$userId';
        final userEmail = firstTx.userEmail ?? '';
        bool isExpanded = false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkHeader
                    : AppColors.lightHeader,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setLocalState(
                        () => isExpanded = !isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            child: Icon(Icons.person_outline,
                                color: Colors.grey[600], size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                Text(
                                  userEmail,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    ...userTransactions.map((t) => Padding(
                          padding: const EdgeInsets.fromLTRB(
                              12, 0, 12, 12),
                          child: _transactionTile(t, isDark,
                              isAdminChild: true),
                        )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _transactionTile(TransactionModel t, bool isDark,
      {bool isAdminChild = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAdminChild
            ? (isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground)
            : (isDark ? AppColors.darkHeader : AppColors.lightHeader),
        borderRadius: BorderRadius.circular(10),
        border: isAdminChild
            ? null
            : Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ApiService.buildImageUrl(t.itemImage), // ← fix di sini
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported,
                    size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.itemName,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  t.itemType,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(t.createdAt),
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                _isAdmin
                    ? '+${_formatPrice(t.totalPrice)}'
                    : '-${_formatPrice(t.totalPrice)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _isAdmin ? Colors.green : AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}