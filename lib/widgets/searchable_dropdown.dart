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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
    final border = borderColor ?? Colors.grey[300]!;
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
                  color: value != null ? Colors.black : Colors.grey[400],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
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
  State<_SearchableDropdownSheet> createState() => _SearchableDropdownSheetState();
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
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
                style: TextStyle(fontSize: widget.fontSize, color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: widget.fontSize),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
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
                              color: isSelected ? AppTheme.primaryNavy : Colors.black,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: AppTheme.primaryNavy, size: 18)
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
