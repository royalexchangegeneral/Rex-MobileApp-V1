import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// A searchable dropdown that opens a bottom sheet with a search field
/// and a filtered list of items. Matches the app's existing input styling.
class SearchableDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double fontSize;
  final Color? borderColor;

  const SearchableDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.fontSize = 13,
    this.borderColor,
  });

  void _openSearch(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SearchableDropdownSheet(
        hint: hint,
        items: items,
        selectedValue: value,
        fontSize: fontSize,
        onSelected: (val) {
          onChanged(val);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border =
        borderColor ?? (isDark ? const Color(0xFF3A455A) : Colors.grey[300]!);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final iconColor = isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

    return GestureDetector(
      onTap: () => _openSearch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: fontSize,
                  color: value != null ? textColor : hintColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SearchableDropdownSheet extends StatefulWidget {
  final String hint;
  final List<String> items;
  final String? selectedValue;
  final double fontSize;
  final ValueChanged<String> onSelected;

  const _SearchableDropdownSheet({
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.fontSize,
    required this.onSelected,
  });

  @override
  State<_SearchableDropdownSheet> createState() =>
      _SearchableDropdownSheetState();
}

class _SearchableDropdownSheetState extends State<_SearchableDropdownSheet> {
  final _searchController = TextEditingController();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.items;
      } else {
        _filtered = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF111827) : Colors.white;
    final fieldColor = isDark ? const Color(0xFF1F2937) : Colors.grey[100]!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final iconColor = isDark ? const Color(0xFFCBD5E1) : Colors.grey;
    final selectedColor =
        isDark ? const Color(0xFFFFB86C) : AppTheme.primaryNavy;
    final handleColor = isDark ? const Color(0xFF4B5563) : Colors.grey[300]!;
    final emptyColor = isDark ? const Color(0xFFCBD5E1) : Colors.grey[500]!;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        color: sheetColor,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                cursorColor: selectedColor,
                style: TextStyle(fontSize: widget.fontSize, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle:
                      TextStyle(color: hintColor, fontSize: widget.fontSize),
                  prefixIcon: Icon(Icons.search, size: 20, color: iconColor),
                  filled: true,
                  fillColor: fieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onChanged: _filter,
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: emptyColor, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        final isSelected = item == widget.selectedValue;
                        return ListTile(
                          dense: true,
                          title: Text(
                            item,
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              color: isSelected ? selectedColor : textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check,
                                  color: selectedColor, size: 18)
                              : null,
                          onTap: () => widget.onSelected(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
