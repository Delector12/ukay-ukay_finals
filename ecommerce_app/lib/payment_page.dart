import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color appBrown = Color(0xFF795548);
const Color appCream = Color(0xFFFFF8E7);
const Color appDarkBrown = Color(0xFF4E342E);
const Color appLightBrown = Color(0xFFD7B899);

// PALITAN NG SARILI MONG PAYMENT DETAILS
const String gcashNumber = '09XXXXXXXXX';
const String gcashAccountName = 'YOUR GCASH NAME';
const String mayaNumber = '09XXXXXXXXX';
const String mayaAccountName = 'YOUR MAYA NAME';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalAmount;

  const PaymentPage({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _referenceController = TextEditingController();

  String _paymentMethod = '';
  bool _isSaving = false;

  bool get _isEwallet =>
      _paymentMethod == 'GCash' || _paymentMethod == 'Maya';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  InputDecoration _decoration(
    String label, {
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, color: appBrown),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: appLightBrown),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: appBrown, width: 2),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: appBrown, size: 25),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: appDarkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPaymentMethod() async {
    final selectedMethod = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: appCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appDarkBrown,
                  ),
                ),
                const SizedBox(height: 12),
                _paymentChoice(
                  context: sheetContext,
                  value: 'Cash on Delivery',
                  subtitle: 'Pay when your order arrives',
                  icon: Icons.payments_outlined,
                  iconColor: appBrown,
                ),
                _paymentChoice(
                  context: sheetContext,
                  value: 'GCash',
                  subtitle: 'Pay using your GCash account',
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.blue,
                ),
                _paymentChoice(
                  context: sheetContext,
                  value: 'Maya',
                  subtitle: 'Pay using your Maya account',
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.green,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMethod != null && mounted) {
      setState(() {
        _paymentMethod = selectedMethod;
        _referenceController.clear();
      });
    }
  }

  Widget _paymentChoice({
    required BuildContext context,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        value,
        style: const TextStyle(
          color: appDarkBrown,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: _paymentMethod == value
          ? const Icon(Icons.check_circle, color: appBrown)
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => Navigator.pop(context, value),
    );
  }

  Widget _paymentMethodRow() {
    return InkWell(
      onTap: _selectPaymentMethod,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appLightBrown),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              color: appBrown,
              size: 25,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Payment Option',
                style: TextStyle(fontSize: 15, color: appDarkBrown),
              ),
            ),
            Flexible(
              child: Text(
                _paymentMethod.isEmpty
                    ? 'Select payment method'
                    : _paymentMethod,
                textAlign: TextAlign.end,
                style: const TextStyle(color: appBrown, fontSize: 13),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _ewalletInstructions() {
    final isGcash = _paymentMethod == 'GCash';
    final accountNumber = isGcash ? gcashNumber : mayaNumber;
    final accountName = isGcash ? gcashAccountName : mayaAccountName;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appLightBrown),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: appBrown,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$_paymentMethod Payment',
                  style: const TextStyle(
                    color: appDarkBrown,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Payment Instructions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Open your e-wallet app.\n'
            '2. Send the exact total to the account below.\n'
            '3. Copy the transaction reference number.\n'
            '4.Enter the reference number before placing an order.',
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appCream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Name',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  accountName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Account Number',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  accountNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Amount to Send',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  '₱${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: appBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _referenceController,
            decoration: _decoration(
              'Transaction Reference Number',
              hint: 'Enter reference number',
              icon: Icons.receipt_long,
            ),
            validator: (value) {
              if (!_isEwallet) return null;
              final ref = value?.trim() ?? '';
              if (ref.isEmpty) {
                return 'Enter your transaction reference number';
              }
              if (ref.length < 5) {
                return 'Please check your reference number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'Your payment will remain pending until verified by the '
            'seller/admin. Entering a reference number does not '
            'automatically confirm payment.',
            style: TextStyle(fontSize: 12, color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();

    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_paymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in before ordering.'),
        ),
      );
      return;
    }

    if (widget.items.isEmpty || widget.totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty or invalid.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final safeItems = widget.items.map((item) {
        return <String, dynamic>{
          'productId': item['productId']?.toString() ?? '',
          'name': item['name']?.toString() ?? 'Product',
          'category': item['category']?.toString() ?? '',
          'price': (item['price'] as num?)?.toDouble() ?? 0.0,
          'image': item['image']?.toString() ?? '',
          'quantity': (item['quantity'] as num?)?.toInt() ?? 1,
        };
      }).toList();

      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc();

      final orderData = <String, dynamic>{
        'orderId': orderRef.id,
        'userId': user.uid,
        'customerName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'items': safeItems,
        'totalAmount': widget.totalAmount,
        'paymentMethod': _paymentMethod,
        'paymentReference':
            _isEwallet ? _referenceController.text.trim() : null,
        'paymentStatus': _paymentMethod == 'Cash on Delivery'
            ? 'Pending - COD'
            : 'Pending Verification',
        'orderStatus': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: appCream,
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 55,
          ),
          title: const Text(
            'Order Placed Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appDarkBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your order has been saved to Firebase.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  'Order ID:\n${orderRef.id}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment Method: $_paymentMethod',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEwallet
                      ? 'Payment Status: Pending Verification'
                      : 'Payment Status: Pending - COD',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ₱${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBrown,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCream,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBrown,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appBrown,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.items.length} item(s) in your order',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _sectionTitle(
              'Delivery Information',
              Icons.local_shipping_outlined,
            ),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration(
                'Full Name',
                icon: Icons.person_outline,
              ),
              validator: (value) => _requiredField(value, 'Full name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _decoration(
                'Phone Number',
                hint: '09XXXXXXXXX',
                icon: Icons.phone_outlined,
              ),
              validator: (value) {
                final error = _requiredField(value, 'Phone number');
                if (error != null) return error;
                final digits =
                    (value ?? '').replaceAll(RegExp(r'\D'), '');
                if (digits.length < 10 || digits.length > 13) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: _decoration(
                'Complete Delivery Address',
                hint: 'House no., street, barangay, city, province',
                icon: Icons.location_on_outlined,
              ),
              validator: (value) =>
                  _requiredField(value, 'Delivery address'),
            ),
            const SizedBox(height: 28),
            _sectionTitle('Payment Method', Icons.payment),
            _paymentMethodRow(),
            if (_isEwallet) _ewalletInstructions(),
            const SizedBox(height: 28),
            _sectionTitle(
              'Order Summary',
              Icons.shopping_bag_outlined,
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appLightBrown),
              ),
              child: Column(
                children: [
                  ...widget.items.map((item) {
                    final name = item['name']?.toString() ?? 'Product';
                    final price =
                        (item['price'] as num?)?.toDouble() ?? 0;
                    final quantity =
                        (item['quantity'] as num?)?.toInt() ?? 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text('$name × $quantity')),
                          Text(
                            '₱${(price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'TOTAL',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: appDarkBrown,
                          ),
                        ),
                      ),
                      Text(
                        '₱${widget.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: appBrown,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBrown,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSaving ? 'Placing Order...' : 'PLACE ORDER',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
