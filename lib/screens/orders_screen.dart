import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_orders')),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(tr('clear_all_orders')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_cancelled',
                child: Row(
                  children: [
                    const Icon(Icons.cancel, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(tr('clear_cancelled_orders')),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                _showClearAllDialog(context);
              } else if (value == 'clear_cancelled') {
                _showClearCancelledDialog(context);
              }
            },
          ),
        ],
      ),
      body: Consumer<CoffeeProvider>(
        builder: (context, coffeeProvider, child) {
          // تصفية الطلبات لإزالة الملغية تلقائياً
          final activeOrders = coffeeProvider.orders
              .where((order) => order.status.toLowerCase() != 'cancelled')
              .toList();

          if (activeOrders.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // إحصائيات الطلبات النشطة فقط
              _buildOrderStats(context, activeOrders, coffeeProvider),
              // قائمة الطلبات النشطة
              Expanded(
                child: _buildOrdersList(activeOrders, coffeeProvider, context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('clear_all_orders_title')),
        content: Text(tr('clear_all_orders_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CoffeeProvider>(context, listen: false)
                  .clearAllOrders();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('all_orders_cleared')),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(tr('clear'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearCancelledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('clear_cancelled_orders_title')),
        content: Text(tr('clear_cancelled_orders_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CoffeeProvider>(context, listen: false)
                  .clearCancelledOrders();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('cancelled_orders_cleared')),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child:
                Text(tr('clear'), style: const TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                tr('no_orders'),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Order coffee to see them here'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStats(
      BuildContext context, List<Order> activeOrders, CoffeeProvider provider) {
    // حساب الإحصائيات من الطلبات النشطة فقط
    final totalOrders = activeOrders.length;
    final activeOrderCount =
        activeOrders.where((order) => order.status == 'Processing').length;
    final totalSpent = activeOrders.fold(
        0.0, (sum, order) => sum + (order.price * order.quantity));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 45),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 8),
            _buildStatItem(
              icon: Icons.shopping_bag,
              label: 'Active Orders'.tr(),
              value: totalOrders.toString(),
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              icon: Icons.pending_actions,
              label: 'Processing'.tr(),
              value: activeOrderCount.toString(),
              color: Colors.orange,
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              icon: Icons.attach_money,
              label: 'Total'.tr(),
              value: '\$${totalSpent.toStringAsFixed(2)}',
              color: Colors.green,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
      List<Order> orders, CoffeeProvider provider, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, provider, context);
      },
    );
  }

  Widget _buildOrderCard(
      Order order, CoffeeProvider provider, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صف العنوان والسعر
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.coffeeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatOrderDate(order.orderDate),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(order.price * order.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // تفاصيل الطلب
            _buildOrderDetails(order),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // أزرار التحكم
            _buildOrderActions(order, provider, context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              order.coffeeImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.coffee, color: Colors.grey, size: 24),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr('size')}: ${order.size}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${tr('quantity')}: ${order.quantity}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (order.isDairyFree) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.local_drink,
                        size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      tr('dairy_free'),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${tr('order_id')}: ${order.id.substring(order.id.length - 6)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderActions(
      Order order, CoffeeProvider provider, BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Row(
      children: [
        Wrap(
          spacing: 5,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            // زر إعادة الطلب
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () {
                  provider.reorder(order.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${order.coffeeName} ${tr('reordered_successfully')}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.replay, size: 14),
                label: isSmallScreen
                    ? const SizedBox.shrink()
                    : Text(tr('reorder'), style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),

            // زر إلغاء الطلب (إذا لم يكن ملغى أو منتهي)
            if (order.status != 'Cancelled' && order.status != 'Delivered')
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCancelDialog(context, order, provider);
                  },
                  icon: const Icon(Icons.cancel, size: 14),
                  label: isSmallScreen
                      ? const SizedBox.shrink()
                      : Text(tr('cancel'),
                          style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            // زر تحديث للحالة التالية
            if (order.status == 'Processing')
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.updateOrderStatus(order.id, 'Preparing');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr('order_status_updated')),
                      ),
                    );
                  },
                  icon: const Icon(Icons.update, size: 14),
                  label: isSmallScreen
                      ? const SizedBox.shrink()
                      : Text(tr('mark_preparing'),
                          style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showCancelDialog(
      BuildContext context, Order order, CoffeeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('cancel_order')),
        content: Text(tr('cancel_order_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('no')),
          ),
          TextButton(
            onPressed: () async {
              // إلغاء الطلب
              provider.cancelOrder(order.id);
              Navigator.pop(context);

              // إظهار رسالة مؤقتة
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('order_cancelled')),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );

              // الانتظار قليلاً ثم تحديث الواجهة
              await Future.delayed(const Duration(milliseconds: 100));
              provider.notifyListeners();
            },
            child: Text(tr('yes_cancel'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${tr('days_ago')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${tr('hours_ago')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${tr('minutes_ago')}';
    } else {
      return tr('just_now');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'on the way':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
