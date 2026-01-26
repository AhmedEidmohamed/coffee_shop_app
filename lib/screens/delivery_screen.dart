import 'package:coffee_shop_app/providers/coffee_provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../models/coffee_model.dart';
import 'order_confirmation_screen.dart';

class DeliveryScreen extends StatelessWidget {
  final Coffee coffee;
  final String size;
  final int quantity;
  final bool isDairyFree;

  const DeliveryScreen({
    super.key,
    required this.coffee,
    required this.size,
    required this.quantity,
    required this.isDairyFree,
  });

  @override
  Widget build(BuildContext context) {
    final double deliveryFee = 2.0;
    final double coffeePrice = coffee.price * quantity;
    final double dairyFreeExtra = isDairyFree ? 0.50 * quantity : 0;
    final double total = coffeePrice + deliveryFee + dairyFreeExtra;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          tr('deliver'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliverySection(context),
            const SizedBox(height: 30),
            _buildOrderSection(coffeePrice, deliveryFee, dairyFreeExtra, total),
            const SizedBox(height: 30),
            _buildPaymentMethod(context),
            const Spacer(),
            _buildProceedButton(context, total),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.delivery_dining, color: Color(0xFF6F4E37)),
              const SizedBox(width: 10),
              Text(
                tr('deliver'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            tr('delivery_address'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jl. Keg Sutoyo\nKeg, Sutoyo Plus 600, Bitsen, Tanjungbaiu.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                tr('edit_address'),
                style: const TextStyle(
                  color: Color(0xFF6F4E37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(double coffeePrice, double deliveryFee,
      double dairyFreeExtra, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('payment_summary'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildSummaryRow(tr('price'), '\$${coffeePrice.toStringAsFixed(2)}'),
        const SizedBox(height: 10),
        if (isDairyFree)
          Column(
            children: [
              _buildSummaryRow(
                  tr('dairy_free'), '\$${dairyFreeExtra.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
            ],
          ),
        _buildSummaryRow(
            tr('delivery_fee'), '\$${deliveryFee.toStringAsFixed(2)}'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[400]!, width: 0.5),
              bottom: BorderSide(color: Colors.grey[400]!, width: 0.5),
            ),
          ),
          child: _buildSummaryRow(tr('total'), '\$${total.toStringAsFixed(2)}'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('payment_method'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6F4E37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wallet,
                  color: Color(0xFF6F4E37),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  tr('cash_wallet'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProceedButton(BuildContext context, double total) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // إنشاء الطلب باستخدام Provider
          final order =
              Provider.of<CoffeeProvider>(context, listen: false).createOrder(
            coffee: coffee,
            size: size,
            quantity: quantity,
            isDairyFree: isDairyFree,
          );

          // إضافة الطلب
          Provider.of<CoffeeProvider>(context, listen: false).addOrder(order);

          // الانتقال لشاشة التأكيد
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(
                coffee: coffee,
                total: total,
                order: order,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6F4E37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          tr('proceed_to_payment'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
