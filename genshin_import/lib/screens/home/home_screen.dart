import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../models/item_model.dart';
import '../../services/api_service.dart';
import '../../widgets/item_card.dart';
import 'detail_screen.dart';
import '../admin/admin_form_screen.dart';
import '../../services/mora_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String? _selectedType;
  String _searchQuery = '';
  String _userRole = 'user';
  double _userMora = 0;
  final _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Weapon', 'Artifact'];
  final List<String> _weaponTypes = [
    'All Types', 'Sword', 'Claymore', 'Polearm', 'Bow', 'Catalyst'
  ];
  final List<String> _artifactTypes = [
    'All Types', 'Flower', 'Feather', 'Sands', 'Goblet', 'Circlet'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadItems();
    MoraNotifier.instance.addListener(_onMoraChanged);
  }

  void _onMoraChanged() {
    setState(() => _userMora = MoraNotifier.instance.value);
  }

  @override
  void dispose() {
    MoraNotifier.instance.removeListener(_onMoraChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'user';
      _userMora = prefs.getDouble('user_mora') ?? 0;
    });
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await ApiService.getItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _filteredItems = items;
      _isLoading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredItems = _items.where((item) {
        bool categoryMatch = _selectedCategory == 'All' ||
            item.category.toLowerCase() ==
                _selectedCategory.toLowerCase();
        bool typeMatch = _selectedType == null ||
            _selectedType == 'All Types' ||
            item.type.toLowerCase() == _selectedType!.toLowerCase();
        bool searchMatch = _searchQuery.isEmpty ||
            item.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        return categoryMatch && typeMatch && searchMatch;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final types = _selectedCategory == 'Weapon'
                ? _weaponTypes
                : _selectedCategory == 'Artifact'
                    ? _artifactTypes
                    : [];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Category',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label:
                            Text(cat, style: GoogleFonts.poppins()),
                        selected: isSelected,
                        selectedColor: AppColors.gold,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedCategory = cat;
                            _selectedType = null;
                          });
                          setState(() {
                            _selectedCategory = cat;
                            _selectedType = null;
                          });
                          _applyFilter();
                        },
                      );
                    }).toList(),
                  ),
                  if (types.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Type',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (types as List<String>).map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type,
                              style: GoogleFonts.poppins()),
                          selected: isSelected,
                          selectedColor: AppColors.gold,
                          onSelected: (selected) {
                            setModalState(
                                () => _selectedType = type);
                            setState(() => _selectedType = type);
                            _applyFilter();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Apply',
                          style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatMora(double mora) {
    final str = mora.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
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
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
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
                  _formatMora(_userMora),
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
      body: Column(
        children: [
          // Filter kiri + Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _showFilterBottomSheet,
                  icon: Icon(
                    Icons.tune,
                    color: (_selectedCategory != 'All' ||
                            _selectedType != null)
                        ? AppColors.gold
                        : null,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Item Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadItems,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return ItemCard(
                              item: item,
                              isAdmin: _userRole == 'admin',
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(item: item),
                                  ),
                                );
                                _loadUserData();
                                _loadItems();
                              },
                              onEdit: _userRole == 'admin'
                                  ? () async {
                                      final result =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AdminFormScreen(
                                                  item: item),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadItems();
                                      }
                                    }
                                  : null,
                              onDelete: _userRole == 'admin'
                                  ? () async {
                                      final confirm =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (context) =>
                                            AlertDialog(
                                          title: Text('Delete Item',
                                              style:
                                                  GoogleFonts.poppins()),
                                          content: Text(
                                              'Are you sure you want to delete ${item.name}?',
                                              style:
                                                  GoogleFonts.poppins()),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, false),
                                              child: Text('Cancel',
                                                  style: GoogleFonts
                                                      .poppins()),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, true),
                                              child: Text('Delete',
                                                  style:
                                                      GoogleFonts.poppins(
                                                          color: Colors
                                                              .red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await ApiService.deleteItem(
                                            item.id);
                                        _loadItems();
                                      }
                                    }
                                  : null,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminFormScreen(),
                  ),
                );
                if (result == true) _loadItems();
              },
              backgroundColor: AppColors.gold,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }
}