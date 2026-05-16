import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/coffee_model.dart';
import '../providers/coffee_provider.dart';
import 'order_confirmation_screen.dart';

class DeliveryScreen extends StatefulWidget {
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
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String _address = 'Jl. Keg Sutoyo\nKeg, Sutoyo Plus 600, Bitsen, Tanjungbaiu.';
  bool _isLoadingAddress = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(tr('location_disabled'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(tr('location_denied'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(tr('location_permanently_denied'));
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address = '${place.street}\n${place.subLocality}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deliveryFee = 2.0;
    final double coffeePrice = widget.coffee.price * widget.quantity;
    final double dairyFreeExtra = widget.isDairyFree ? 0.50 * widget.quantity : 0;
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
          Text(
            _address,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _isLoadingAddress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _getCurrentLocation,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.my_location, size: 16, color: Color(0xFF6F4E37)),
                        const SizedBox(width: 4),
                        Text(
                          tr('edit_address'),
                          style: const TextStyle(
                            color: Color(0xFF6F4E37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
        if (widget.isDairyFree)
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
          final order =
              Provider.of<CoffeeProvider>(context, listen: false).createOrder(
            coffee: widget.coffee,
            size: widget.size,
            quantity: widget.quantity,
            isDairyFree: widget.isDairyFree,
          );

          Provider.of<CoffeeProvider>(context, listen: false).addOrder(order);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(
                coffee: widget.coffee,
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
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
