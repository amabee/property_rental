import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/data/queries/getReportsData.dart';

class RentalBalancesReportPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const RentalBalancesReportPage({
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _RentalBalancesReportPageState createState() =>
      _RentalBalancesReportPageState();
}

class _RentalBalancesReportPageState extends State<RentalBalancesReportPage> {
  bool _isLoading = true;
  List<dynamic>? _balancesData;
  String _sortBy = 'name';
  bool _ascending = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBalancesData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBalancesData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await getBalancesReport();
      setState(() {
        _balancesData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load balances data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortData(String field) {
    setState(() {
      if (_sortBy == field) {
        _ascending = !_ascending;
      } else {
        _sortBy = field;
        _ascending = true;
      }

      _balancesData?.sort((a, b) {
        var aValue = a[field];
        var bValue = b[field];

        // Handle numeric values
        if (aValue is num && bValue is num) {
          return _ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }

        // Handle date values
        if (field == 'date_in' || field == 'last_payment') {
          try {
            final aDate =
                field == 'last_payment'
                    ? DateFormat('MMM d, yyyy').parse(aValue.toString())
                    : DateTime.parse(aValue.toString());
            final bDate =
                field == 'last_payment'
                    ? DateFormat('MMM d, yyyy').parse(bValue.toString())
                    : DateTime.parse(bValue.toString());
            return _ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          } catch (e) {
            // If parsing fails, treat as strings
          }
        }

        // Default to string comparison
        return _ascending
            ? aValue.toString().compareTo(bValue.toString())
            : bValue.toString().compareTo(aValue.toString());
      });
    });
  }

  List<dynamic> _getFilteredData() {
    if (_searchQuery.isEmpty) return _balancesData ?? [];

    return _balancesData?.where((item) {
          final name = item['name'].toString().toLowerCase();
          final houseNo = item['house_no'].toString().toLowerCase();
          final query = _searchQuery.toLowerCase();

          return name.contains(query) || houseNo.contains(query);
        }).toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Balances Report'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _balancesData == null || _balancesData!.isEmpty
              ? const Center(child: Text('No balances data available'))
              : _buildReportContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Export or share functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export feature will be implemented here')),
          );
        },
        child: Icon(Icons.ios_share),
      ),
    );
  }

  Widget _buildReportContent() {
    final currencyFormat = NumberFormat("#,##0.00", "en_US");

    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchBalancesData,
            child: _buildBalancesListView(currencyFormat),
          ),
        ),
        _buildSummaryFooter(currencyFormat),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or house number',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color:
              selected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
        ),
        backgroundColor: Colors.grey.shade200,
        selectedColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildBalancesListView(NumberFormat currencyFormat) {
    final filteredData = _getFilteredData();

    return filteredData.isEmpty
        ? Center(child: Text('No results matching "${_searchQuery}"'))
        : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final balance = filteredData[index];
            final hasOutstanding = balance['outstanding'] > 0;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    hasOutstanding
                        ? BorderSide(
                          color: Colors.red.shade100,
                          width: 1,
                        )
                        : BorderSide(color: Colors.green.shade100),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            balance['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            balance['house_no'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hasOutstanding ? 'Outstanding' : 'Paid',
                          style: TextStyle(
                            color: hasOutstanding ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          balance['outstanding'] > 0 ? '₱${currencyFormat.format(balance['outstanding'])}' : "₱0.00",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hasOutstanding ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                children: [
                  const Divider(),
                  _buildDetailRow(
                    'Monthly Rent:',
                    '₱${currencyFormat.format(balance['monthly_rent'])}',
                  ),
                  _buildDetailRow(
                    'Move-in Date:',
                    DateFormat(
                      'MMM dd, yyyy',
                    ).format(DateTime.parse(balance['date_in'])),
                  ),
                  _buildDetailRow('Months as Tenant:', '${balance['months']}'),
                  _buildDetailRow(
                    'Total Payable:',
                    '₱${currencyFormat.format(balance['payable'])}',
                  ),
                  _buildDetailRow(
                    'Total Paid:',
                    '₱${currencyFormat.format(balance['paid'])}',
                  ),
                  _buildDetailRow(
                    'Last Payment:',
                    '${balance['last_payment']}',
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Details'),
                        onPressed: () {
                          // Navigate to detailed view
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text('Record Payment'),
                        onPressed:
                            hasOutstanding
                                ? () {
                                  // Navigate to payment screen
                                }
                                : null,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryFooter(NumberFormat currencyFormat) {
    if (_balancesData == null) return const SizedBox.shrink();

    final totalOutstanding = _balancesData!.fold<double>(
      0,
      (sum, item) => sum + (item['outstanding'] as num).toDouble(),
    );
    final tenantsWithOutstanding =
        _balancesData!.where((item) => item['outstanding'] > 0).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Outstanding',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    '₱${currencyFormat.format(totalOutstanding)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tenants with Outstanding',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    '$tenantsWithOutstanding of ${_balancesData!.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
