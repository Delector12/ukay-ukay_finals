
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color appBrown = Color(0xFF795548);
const Color appCream = Color(0xFFFFF8EE);

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      case 'confirmed':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  int statusStep(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  String formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.month}/${date.day}/${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }
    return 'Date unavailable';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: appCream,
        appBar: AppBar(
          title: const Text('My Orders'),
          backgroundColor: appBrown,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Please log in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: appCream,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: appBrown,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load orders. Please try again.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: appBrown),
            );
          }

          final orders = snapshot.data?.docs.toList() ?? [];

          orders.sort((a, b) {
            final aDate = a.data()['createdAt'];
            final bDate = b.data()['createdAt'];

            final aMillis = aDate is Timestamp
                ? aDate.millisecondsSinceEpoch
                : 0;
            final bMillis = bDate is Timestamp
                ? bDate.millisecondsSinceEpoch
                : 0;

            return bMillis.compareTo(aMillis);
          });

          if (orders.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 72,
                      color: appBrown,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Your orders will appear here.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data();

              final orderId =
                  data['orderId']?.toString() ?? doc.id;
              final status =
                  data['orderStatus']?.toString() ?? 'Pending';
              final paymentStatus =
                  data['paymentStatus']?.toString() ?? 'Pending';
              final paymentMethod =
                  data['paymentMethod']?.toString() ?? 'Not specified';
              final total = (data['totalAmount'] as num?) ?? 0;
              final items = data['items'] is List
                  ? data['items'] as List
                  : [];
              final step = statusStep(status);

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: appBrown,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Order #$orderId',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(status).withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Placed: ${formatDate(data['createdAt'])}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 24),

                      const Text(
                        'Items',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      ...items.map((item) {
                        if (item is! Map) {
                          return const SizedBox.shrink();
                        }

                        final name =
                            item['name']?.toString() ??
                            item['productName']?.toString() ??
                            'Product';
                        final quantity =
                            (item['quantity'] as num?)?.toInt() ?? 1;
                        final price =
                            (item['price'] as num?) ?? 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('$name × $quantity'),
                              ),
                              Text(
                                '₱${(price * quantity).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₱${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: appBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text('Payment Method: $paymentMethod'),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment: '),
                          Expanded(
                            child: Text(
                              paymentStatus,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (status.toLowerCase() != 'cancelled') ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Order Tracking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _TrackingStep(
                              label: 'Pending',
                              icon: Icons.receipt_long,
                              active: step >= 0,
                            ),
                            _trackingLine(step >= 1),
                            _TrackingStep(
                              label: 'Confirmed',
                              icon: Icons.check_circle_outline,
                              active: step >= 1,
                            ),
                            _trackingLine(step >= 2),
                            _TrackingStep(
                              label: 'Shipped',
                              icon: Icons.local_shipping_outlined,
                              active: step >= 2,
                            ),
                            _trackingLine(step >= 3),
                            _TrackingStep(
                              label: 'Delivered',
                              icon: Icons.home_outlined,
                              active: step >= 3,
                            ),
                          ],
                        ),
                      ],

                      if (status.toLowerCase() == 'cancelled') ...[
                        const SizedBox(height: 12),
                        const Text(
                          'This order has been cancelled.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _trackingLine(bool active) {
    return Expanded(
      child: Container(
        height: 3,
        color: active ? appBrown : Colors.grey.shade300,
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;

  const _TrackingStep({
    required this.label,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 57,
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
            color: active ? appBrown : Colors.grey,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: active ? appBrown : Colors.grey,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
