import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate/data/queries/getReportsData.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyPaymentsReportPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const MonthlyPaymentsReportPage({
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _MonthlyPaymentsReportPageState createState() =>
      _MonthlyPaymentsReportPageState();
}

class _MonthlyPaymentsReportPageState extends State<MonthlyPaymentsReportPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  final List<String> _months = [
    'January 2025',
    'February 2025',
    'March 2025',
    'April 2025',
  ];

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await getMonthlyReports();
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load report data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Payments Report'),
        elevation: 0,
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Container(
        color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[100],
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reportData == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 56, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _fetchReportData,
                        icon: Icon(Icons.refresh),
                        label: Text('Try Again'),
                      ),
                    ],
                  ),
                )
                : _buildReportContent(),
      ),
    );
  }

  Widget _buildReportContent() {
    final payments = _reportData!['payments'] as List;
    final totalAmount = _reportData!['total_amount'] as int;
    final currencyFormat = NumberFormat("#,##0.00", "en_US");
    final theme = Theme.of(context);
    final cardBgColor = widget.isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor =
        widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return RefreshIndicator(
      onRefresh: _fetchReportData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(textColor),
              const SizedBox(height: 16),
              _buildSummaryCard(
                cardBgColor!,
                textColor,
                theme,
                totalAmount,
                payments,
                currencyFormat,
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Transactions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentsList(
                payments,
                cardBgColor,
                textColor,
                subTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          _selectedMonth,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const Spacer(),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Show filter options
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Filter options coming soon')));
      },
      icon: Icon(Icons.filter_list, size: 18),
      label: Text('Filter'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSummaryCard(
    Color cardBgColor,
    Color textColor,
    ThemeData theme,
    int totalAmount,
    List payments,
    NumberFormat currencyFormat,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: cardBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 15.0,
                  ),
                ),
                _buildMonthDropdown(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Payments',
                    '₱${currencyFormat.format(totalAmount)}',
                    Icons.payments_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Total Tenants',
                    '${payments.length}',
                    Icons.people_alt_rounded,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDistributionSection(payments),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    final dropdownBorderColor =
        widget.isDarkMode ? Colors.grey[700] : Colors.grey[300];
    final dropdownBgColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: dropdownBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dropdownBorderColor!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonth,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue, size: 16),
          isDense: true,
          items:
              _months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(
                    month,
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedMonth = newValue;
                // In a real app, you'd refetch based on the selected month
                _fetchReportData();
              });
            }
          },
          dropdownColor: dropdownBgColor,
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final cardBgColor =
        widget.isDarkMode ? Colors.grey[700] : color.withOpacity(0.12);
    final titleColor = widget.isDarkMode ? Colors.grey[300] : Colors.grey[700];
    final valueColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            widget.isDarkMode
                ? []
                : [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(widget.isDarkMode ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 13, color: titleColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(List payments) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor =
        widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            'Payment Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Chart takes 60% of the width
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 150, // Reduced height
                child: _buildPaymentDistributionChart(payments),
              ),
            ),
            // Legend takes 40% of the width
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _buildChartLegend(payments),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDistributionChart(List payments) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 25, // Smaller center space
        sections: List.generate(payments.length > 5 ? 5 : payments.length, (
          index,
        ) {
          // Use a more pleasing color palette
          final colors = [
            Color(0xFF4285F4), // Google Blue
            Color(0xFF34A853), // Google Green
            Color(0xFFFBBC05), // Google Yellow
            Color(0xFFEA4335), // Google Red
            Color(0xFF9C27B0), // Purple
          ];

          final payment = payments[index];
          final amount = payment['amount'] as int;

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: amount.toDouble(),
            title: '', // Empty title for cleaner look
            radius: 50, // Smaller radius
            titleStyle: TextStyle(
              fontSize: 0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartLegend(List payments) {
    final colors = [
      Color(0xFF4285F4), // Google Blue
      Color(0xFF34A853), // Google Green
      Color(0xFFFBBC05), // Google Yellow
      Color(0xFFEA4335), // Google Red
      Color(0xFF9C27B0), // Purple
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(payments.length > 5 ? 5 : payments.length, (
        index,
      ) {
        final payment = payments[index];
        final name = payment['name'] as String;
        final amount = payment['amount'] as int;
        final currencyFormat = NumberFormat("#,##0.00", "en_US");
        final displayName = name.split(',')[0];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "₱${currencyFormat.format(amount)}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentsList(
    List payments,
    Color cardBgColor,
    Color textColor,
    Color? subTextColor,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final dateCreated = DateTime.parse(payment['date_created']);
        final formattedDate = DateFormat('MMM dd, yyyy').format(dateCreated);
        final formattedTime = DateFormat('h:mm a').format(dateCreated);
        final amount = payment['amount'] as int;
        final currencyFormat = NumberFormat("#,##0.00", "en_US");

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          color: cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildPaymentStatusIndicator(payment),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'House ${payment['house_no']} • Invoice #${payment['invoice']}',
                            style: TextStyle(fontSize: 12, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₱${currencyFormat.format(amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  color:
                      widget.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: subTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: subTextColor),
                        const SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentStatusIndicator(dynamic payment) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
    );
  }
}
