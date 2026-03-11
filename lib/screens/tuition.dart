import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);
const Color _textColor = Color(0xFF1D2939);

class TuitionScreen extends StatefulWidget {
  const TuitionScreen({super.key});

  @override
  State<TuitionScreen> createState() => _TuitionScreenState();
}

class _TuitionScreenState extends State<TuitionScreen> {
  final ApiService _apiService = ApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
  
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getTransactions();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _transactions = (response['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load transactions';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred while fetching data.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePayment(Transaction transaction) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Text('Do you want to pay for "${transaction.title}" via VNPay?\nAmount: ${_currencyFormat.format(transaction.amount)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              child: const Text('Go to VNPay'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Proceed with requesting URL from backend
    setState(() {
      _isLoading = true;
    });

    final response = await _apiService.payTransaction(transaction.id);
    if (!mounted) return;

    if (response['success'] == true) {
      // VNPay Flow
      if (response['paymentUrl'] != null) {
        final String urlStripped = response['paymentUrl'];
        final Uri paymentUri = Uri.parse(urlStripped);
        
        try {
          // Launch the VNPay url in the default browser
          // Need to import 'package:url_launcher/url_launcher.dart'
          // Since url_launcher isn't accessible without developer mode, we must do dynamic check or import at top
          // For now, assume url_launcher has been imported and works
          await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to VNPay... After payment, pull to refresh to update status.'), backgroundColor: Colors.blue),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch VNPay. Make sure Developer Mode & url_launcher are setup. Error: $e'), backgroundColor: Colors.red),
          );
        }
        
        setState(() {
          _isLoading = false;
        });
      } else {
        // Fallback or old mock logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed locally.'), backgroundColor: Colors.green),
        );
        _fetchTransactions();
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Payment API failed'), backgroundColor: Colors.red),
      );
    }
  }

  double _calculateTotalBalance() {
    double total = 0;
    for (var tx in _transactions) {
      if (tx.status.toLowerCase() != 'paid') {
        total += tx.amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Tuition & Fees'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading && _transactions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchTransactions,
              color: _primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildBalanceCard(context),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment History',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: _textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (_isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_transactions.isEmpty && !_isLoading && _errorMessage == null)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No transactions found.'),
                              ),
                            ),
                          ..._transactions.map((tx) => _buildTransactionItem(tx)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final double pendingBalance = _calculateTotalBalance();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Pending Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(pendingBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    bool isCredit = transaction.transactionType.toLowerCase() == 'credit';
    bool isPaid = transaction.status.toLowerCase() == 'paid' || transaction.status.toLowerCase() == 'success';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCredit ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.add : Icons.remove,
                  color: isCredit ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.transactionDate != null
                          ? DateFormat('MMM dd, yyyy').format(transaction.transactionDate!)
                          : 'No Date',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (isCredit ? '+ ' : '- ') + _currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isCredit ? Colors.green : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.status,
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isPaid) ...[
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handlePayment(transaction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Pay Now'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
