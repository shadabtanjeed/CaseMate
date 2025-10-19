import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

// Provider to fetch wallet balance for earnings screen (no auth)
final earningsWalletProvider = FutureProvider.family<double?, String>((ref, email) async {
  if (email.isEmpty) return null;
  final api = ApiClient();
  final dynamic resp = await api.get('/wallet/$email');

  dynamic val;
  if (resp is Map && resp.containsKey('balance')) {
    val = resp['balance'];
  } else if (resp is Map && resp.containsKey('data') && resp['data'] is Map && resp['data'].containsKey('balance')) {
    val = resp['data']['balance'];
  } else if (resp is Map && resp.containsKey('wallet') && resp['wallet'] is Map && resp['wallet'].containsKey('balance')) {
    val = resp['wallet']['balance'];
  }

  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
});

// New: full wallet provider returns WalletOut map
final walletProviderFull = FutureProvider.family<Map<String, dynamic>?, String>((ref, email) async {
  if (email.isEmpty) return null;
  final api = ApiClient();
  final dynamic resp = await api.get('/wallet/$email');
  if (resp is Map) return Map<String, dynamic>.from(resp);
  return null;
});

// Earnings summary provider: /transactions/lawyer/{email}/earnings
final lawyerEarningsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, email) async {
  if (email.isEmpty) return null;
  final api = ApiClient();
  final dynamic resp = await api.get('/transactions/lawyer/$email/earnings');
  if (resp is Map) return Map<String, dynamic>.from(resp);
  return null;
});

// Transactions provider for a lawyer: /transactions/lawyer/{email}
final lawyerTransactionsProvider = FutureProvider.family<List<Map<String, dynamic>>?, String>((ref, email) async {
  if (email.isEmpty) return null;
  final api = ApiClient();
  final dynamic resp = await api.get('/transactions/lawyer/$email?limit=50');
  if (resp is List) {
    // resp may be List<dynamic> where each element is a Map
    return (resp as List).map<Map<String, dynamic>>((e) {
      if (e is Map) return Map<String, dynamic>.from(e.cast<String, dynamic>());
      return <String, dynamic>{};
    }).toList();
  }
  return null;
});

// Withdrawals for the user - we'll map recent withdrawal bank details as payment methods for display
final walletWithdrawalsProvider = FutureProvider.family<List<Map<String, dynamic>>?, String>((ref, email) async {
  if (email.isEmpty) return null;
  final api = ApiClient();
  final dynamic resp = await api.get('/wallet/withdrawals/$email');
  if (resp is List) {
    return (resp as List).map<Map<String, dynamic>>((e) {
      if (e is Map) return Map<String, dynamic>.from(e.cast<String, dynamic>());
      return <String, dynamic>{};
    }).toList();
  }
  return null;
});

class LawyerEarningsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const LawyerEarningsScreen({super.key, required this.onBack});

  @override
  ConsumerState<LawyerEarningsScreen> createState() => _LawyerEarningsScreenState();
}

class _LawyerEarningsScreenState extends ConsumerState<LawyerEarningsScreen> {
  String _selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    // Get lawyer email from auth provider
    final authState = ref.watch(authProvider);
    final lawyerEmail = authState.user?.email ?? '';

    // Use full wallet, earnings summary, transactions and withdrawals providers
    final walletAsync = lawyerEmail.isNotEmpty ? ref.watch(walletProviderFull(lawyerEmail)) : const AsyncValue.data(null);
    final earningsSummaryAsync = lawyerEmail.isNotEmpty ? ref.watch(lawyerEarningsProvider(lawyerEmail)) : const AsyncValue.data(null);
    final transactionsAsync = lawyerEmail.isNotEmpty ? ref.watch(lawyerTransactionsProvider(lawyerEmail)) : const AsyncValue.data(null);
    final withdrawalsAsync = lawyerEmail.isNotEmpty ? ref.watch(walletWithdrawalsProvider(lawyerEmail)) : const AsyncValue.data(null);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(walletAsync, earningsSummaryAsync),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEarningsSummary(earningsSummaryAsync),
                    const SizedBox(height: 24),
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    _buildEarningsChart(transactionsAsync),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(transactionsAsync),
                    const SizedBox(height: 24),
                    _buildPaymentMethods(withdrawalsAsync),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Map<String, dynamic>?> walletAsync, AsyncValue<Map<String, dynamic>?> earningsSummaryAsync) {
    String totalDisplay = '৳0.00';
    String subtitle = '';
    String trend = '+0.0% from last month';

    // Use wallet if available
    if (walletAsync is AsyncData<Map<String, dynamic>?>) {
      final w = walletAsync.value;
      if (w != null) {
        final curr = w['current_balance'] ?? w['balance'] ?? w['currentBalance'];
        double? bal;
        if (curr is num) bal = curr.toDouble();
        if (curr is String) bal = double.tryParse(curr);
        if (bal != null) totalDisplay = '৳${bal.toStringAsFixed(2)}';
        subtitle = 'Current Balance';
      }
    }

    // If earnings summary available, show total earned and platform fee info
    if (earningsSummaryAsync is AsyncData<Map<String, dynamic>?>) {
      final s = earningsSummaryAsync.value;
      if (s != null) {
        final total = s['total_earned'] ?? s['totalEarned'] ?? s['total'] ?? s['total_earned_amount'];
        if (total is num) {
          totalDisplay = '৳${(total).toDouble().toStringAsFixed(2)}';
        }
        final platformFee = s['platform_fee_paid'] ?? s['platform_fee'] ?? s['platformFeePaid'];
        if (platformFee != null) {
          // show as subtitle
          subtitle = 'Platform fees paid: ৳${(platformFee is num ? platformFee.toDouble().toStringAsFixed(2) : platformFee.toString())}';
        }
        // optional percent if provided
        if (s.containsKey('growth_percentage')) {
          final g = s['growth_percentage'];
          if (g != null) trend = '${g.toString()}% from last month';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
              const Expanded(
                child: Text(
                  'Earnings & Revenue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  subtitle.isNotEmpty ? subtitle : 'Total Earnings',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  totalDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, color: Colors.green[200], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: Colors.green[200],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary(AsyncValue<Map<String, dynamic>?> earningsSummaryAsync) {
    String pending = '৳0.00';
    String thisMonth = '৳0.00';
    String pendingSubtitle = '0 payments';
    String monthSubtitle = '0 sessions';

    if (earningsSummaryAsync is AsyncData<Map<String, dynamic>?>) {
      final s = earningsSummaryAsync.value;
      if (s != null) {
        final pend = s['pending_amount'] ?? s['pending'] ?? 0;
        final month = s['this_month'] ?? s['month_total'] ?? s['total_this_month'] ?? s['total_earned_this_month'];
        final pendCount = s['pending_count'] ?? s['pending_payments'] ?? 0;
        final monthCount = s['sessions_this_month'] ?? s['transactions_this_month'] ?? 0;
        double p = 0, m = 0;
        if (pend is num) p = pend.toDouble();
        if (pend is String) p = double.tryParse(pend) ?? 0;
        if (month is num) m = month.toDouble();
        if (month is String) m = double.tryParse(month) ?? 0;
        pending = '৳${p.toStringAsFixed(2)}';
        thisMonth = '৳${m.toStringAsFixed(2)}';
        pendingSubtitle = '${pendCount ?? 0} payments';
        monthSubtitle = '${monthCount ?? 0} sessions';
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Pending',
            pending,
            Icons.hourglass_empty,
            Colors.orange,
            pendingSubtitle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'This Month',
            thisMonth,
            Icons.calendar_today,
            AppTheme.primaryBlue,
            monthSubtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String amount, IconData icon,
      Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodButton('Week', 'week'),
        const SizedBox(width: 8),
        _buildPeriodButton('Month', 'month'),
        const SizedBox(width: 8),
        _buildPeriodButton('Year', 'year'),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPeriod = value;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryBlue : Colors.white,
          foregroundColor: isSelected ? Colors.white : AppTheme.textPrimary,
          elevation: 0,
          side: BorderSide(
              color: isSelected ? AppTheme.primaryBlue : AppTheme.borderColor),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildEarningsChart(AsyncValue<List<Map<String, dynamic>>?> transactionsAsync) {
    // Prepare labels Mon..Sun
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // default placeholder heights and amounts
    List<double> heights = List.filled(7, 0.4);
    List<String> amounts = List.filled(7, '৳0');

    if (transactionsAsync is AsyncData<List<Map<String, dynamic>>?>) {
      final txs = transactionsAsync.value ?? [];
      // compute totals per weekday (Monday=1 .. Sunday=7)
      final totals = List<double>.filled(7, 0.0);
      for (final tx in txs) {
        dynamic dateRaw = tx['transaction_date'] ?? tx['transactionDate'] ?? tx['transaction_date'];
        DateTime? dt;
        try {
          if (dateRaw is String) dt = DateTime.parse(dateRaw);
        } catch (_) {}
        if (dt == null) continue;
        final dayIndex = (dt.weekday - 1); // 0-based
        final amountRaw = tx['lawyer_received_amount'] ?? tx['lawyerReceivedAmount'] ?? tx['user_paid_amount'] ?? tx['userPaidAmount'];
        double amt = 0;
        if (amountRaw is num) amt = amountRaw.toDouble();
        if (amountRaw is String) amt = double.tryParse(amountRaw) ?? 0;
        totals[dayIndex] += amt;
      }
      final maxTotal = totals.reduce((a, b) => a > b ? a : b);
      for (int i = 0; i < 7; i++) {
        final t = totals[i];
        heights[i] = (maxTotal > 0) ? (t / maxTotal).clamp(0.05, 1.0) : 0.05;
        amounts[i] = '৳${t.toStringAsFixed(0)}';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) => _buildChartBar(labels[i], heights[i], amounts[i])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double height, String amount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 140 * height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(AsyncValue<List<Map<String, dynamic>>?> transactionsAsync) {
    if (transactionsAsync is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final txs = (transactionsAsync is AsyncData<List<Map<String, dynamic>>?>) ? (transactionsAsync.value ?? []) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // map transactions to items
        if (txs.isEmpty) ...[
          const Text('No recent transactions'),
        ] else ...txs.take(6).map((tx) {
          final client = tx['client_name'] ?? tx['client'] ?? tx['user_name'] ?? 'Client';
          final description = tx['transaction_type'] ?? tx['description'] ?? tx['appointment_type'] ?? 'Session';
          final amountRaw = tx['lawyer_received_amount'] ?? tx['lawyerReceivedAmount'] ?? tx['user_paid_amount'] ?? tx['userPaidAmount'] ?? 0;
          String amount = '';
          if (amountRaw is num) amount = '৳${amountRaw.toStringAsFixed(0)}';
          if (amountRaw is String) amount = '৳${amountRaw}';
          final date = tx['transaction_date'] ?? tx['transactionDate'] ?? '';
          final status = tx['status'] ?? 'completed';
          final statusIcon = status == 'pending' ? Icons.hourglass_empty : Icons.check_circle;
          final statusColor = status == 'pending' ? Colors.orange : Colors.green;
          return _buildTransactionItem(
            client,
            description,
            amount,
            date.toString(),
            status,
            statusIcon,
            statusColor,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(
    String client,
    String description,
    String amount,
    String date,
    String status,
    IconData statusIcon,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(AsyncValue<List<Map<String, dynamic>>?> withdrawalsAsync) {
    // derive payment methods from recent withdrawals (bank details)
    List<Widget> cards = [];
    if (withdrawalsAsync is AsyncLoading) {
      cards.add(const Center(child: CircularProgressIndicator()));
    } else if (withdrawalsAsync is AsyncData<List<Map<String, dynamic>>?>) {
      final items = withdrawalsAsync.value ?? [];
      if (items.isEmpty) {
        // fallback sample method
        cards.add(_buildPaymentMethodCard('Bank Account', 'Wells Fargo •••• 4532', Icons.account_balance, true));
      } else {
        // use unique bank account entries
        final seen = <String>{};
        for (final w in items) {
          final bank = w['bank_name'] ?? 'Bank';
          final acc = w['bank_account'] ?? w['bankAccount'] ?? '••••';
          final holder = w['account_holder_name'] ?? w['accountHolderName'] ?? '';
          final key = '$bank|$acc';
          if (seen.contains(key)) continue;
          seen.add(key);
          final title = bank.toString();
          final subtitle = '$holder • ${acc.toString().length > 4 ? '•••• ${acc.toString().substring(acc.toString().length - 4)}' : acc}';
          final isPrimary = seen.length == 1;
          cards.add(_buildPaymentMethodCard(title, subtitle, Icons.account_balance, isPrimary));
        }
      }
    } else {
      // error / empty
      cards.add(_buildPaymentMethodCard('Bank Account', 'Wells Fargo •••• 4532', Icons.account_balance, true));
      cards.add(_buildPaymentMethodCard('PayPal', 'user@example.com', Icons.payment, false));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Methods',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...cards,
      ],
    );
  }

  Widget _buildPaymentMethodCard(
      String title, String subtitle, IconData icon, bool isPrimary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? AppTheme.primaryBlue : AppTheme.borderColor,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
