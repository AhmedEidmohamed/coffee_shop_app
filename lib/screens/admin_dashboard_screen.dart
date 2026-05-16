import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_model.dart';
import '../blocs/auth_cubit.dart';
import 'main_screen.dart';
import 'login_screen.dart';
import 'detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Reload orders and coffees when entering dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoffeeProvider>().refreshCoffees();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront, color: Color(0xFF6F4E37)),
            tooltip: 'View Store',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6F4E37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6F4E37),
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
            Tab(icon: Icon(Icons.inventory), text: 'Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(context),
          _buildOrdersTab(context),
          _buildProductsTab(context),
        ],
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton(
              onPressed: _addCoffee,
              backgroundColor: const Color(0xFF6F4E37),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _addCoffee() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageController = TextEditingController();
    String selectedCategory = 'Latte'; // Default category

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            tr('add_coffee'),
            style: const TextStyle(
              color: Color(0xFF6F4E37),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: tr('name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon:
                          const Icon(Icons.coffee, color: Color(0xFF6F4E37)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('name_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: tr('description'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description,
                          color: Color(0xFF6F4E37)),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('description_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: tr('price'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money,
                          color: Color(0xFF6F4E37)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('price_required');
                      }
                      if (double.tryParse(value) == null) {
                        return tr('invalid_price');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imageController,
                    decoration: InputDecoration(
                      labelText: tr('image_url'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon:
                          const Icon(Icons.image, color: Color(0xFF6F4E37)),
                    ),
                    onChanged: (value) {
                      setDialogState(() {}); // Rebuild to update preview
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('image_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  // Image Preview
                  if (imageController.text.isNotEmpty)
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageController.text,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.red),
                              Text('Invalid Image URL',
                                  style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: tr('category'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon:
                          const Icon(Icons.category, color: Color(0xFF6F4E37)),
                    ),
                    onChanged: (value) {
                      selectedCategory = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('category_required');
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newCoffee = Coffee(
                    id: '${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    imageUrl: imageController.text,
                    rating: 4.5,
                    reviewCount: 100,
                    category: selectedCategory,
                  );
                  final provider =
                      Provider.of<CoffeeProvider>(context, listen: false);
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(ctx).pop();
                  
                  final success = await provider.addCoffee(newCoffee);
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(tr('coffee_added'))),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(tr('add_failed'))),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F4E37),
                foregroundColor: Colors.white,
              ),
              child: Text(tr('add')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        final stats = provider.orderStatistics;
        final totalSales = provider.totalSales;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFF6F4E37),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Sales',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        '\$${totalSales.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard('Total Orders', stats['total']?.toString() ?? '0', Icons.list),
                    _buildStatCard('Pending', stats['processing']?.toString() ?? '0', Icons.hourglass_empty),
                    _buildStatCard('Delivered', stats['delivered']?.toString() ?? '0', Icons.check_circle),
                    _buildStatCard('Cancelled', stats['cancelled']?.toString() ?? '0', Icons.cancel),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF6F4E37)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        final orders = provider.orders;
        
        if (orders.isEmpty) {
          return const Center(child: Text('No orders yet.'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(order.coffeeImage),
                ),
                title: Text('Order #${order.id.substring(0, 5)}... - ${order.coffeeName}'),
                subtitle: Text('Status: ${order.status} | \$${order.totalPrice.toStringAsFixed(2)}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${order.quantity}'),
                        Text('Size: ${order.size}'),
                        Text('Dairy Free: ${order.isDairyFree ? "Yes" : "No"}'),
                        const SizedBox(height: 16),
                        const Text('Change Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildStatusButton(context, provider, order.id, 'Pending', Colors.orange),
                            _buildStatusButton(context, provider, order.id, 'Accepted', Colors.blue),
                            _buildStatusButton(context, provider, order.id, 'Preparing', Colors.purple),
                            _buildStatusButton(context, provider, order.id, 'Ready', Colors.teal),
                            _buildStatusButton(context, provider, order.id, 'Delivered', Colors.green),
                            _buildStatusButton(context, provider, order.id, 'Cancelled', Colors.red),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusButton(BuildContext context, CoffeeProvider provider, String orderId, String status, Color color) {
    return ActionChip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      onPressed: () {
        provider.updateOrderStatus(orderId, status);
      },
    );
  }

  final List<String> _categories = [
    'All Coffee',
    'Machisto',
    'Latte',
    'Americano'
  ];

  Widget _buildProductsTab(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.coffees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final coffees = provider.coffees;

        if (coffees.isEmpty) {
          return const Center(child: Text('No products yet. Add one!'));
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Space for FAB
              itemCount: coffees.length,
              itemBuilder: (context, index) {
                final coffee = coffees[index];
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: CachedNetworkImage(
                      imageUrl: coffee.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  title: Text(coffee.name),
                  subtitle: Text('\$${coffee.price.toStringAsFixed(2)} | ${coffee.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editCoffee(context, provider, coffee),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCoffee(context, provider, coffee),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _editCoffee(BuildContext context, CoffeeProvider provider, Coffee coffee) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: coffee.name);
    final descriptionController = TextEditingController(text: coffee.description);
    final priceController = TextEditingController(text: coffee.price.toString());
    final imageController = TextEditingController(text: coffee.imageUrl);
    String selectedCategory = coffee.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text(
            'Edit Coffee',
            style: TextStyle(
              color: Color(0xFF6F4E37),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.coffee, color: Color(0xFF6F4E37)),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.description, color: Color(0xFF6F4E37)),
                    ),
                    maxLines: 3,
                    validator: (value) => (value == null || value.isEmpty) ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF6F4E37)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Price is required';
                      if (double.tryParse(value) == null) return 'Invalid price';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imageController,
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.image, color: Color(0xFF6F4E37)),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Image URL is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categories.contains(selectedCategory) ? selectedCategory : _categories[0],
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category, color: Color(0xFF6F4E37)),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedCoffee = coffee.copyWith(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    imageUrl: imageController.text,
                    category: selectedCategory,
                  );
                  final success = await provider.updateCoffee(coffee.id, updatedCoffee);
                  Navigator.pop(ctx);
                  if (success) await provider.refreshCoffees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Coffee updated successfully!' : 'Failed to update coffee'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F4E37),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCoffee(BuildContext context, CoffeeProvider provider, Coffee coffee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${coffee.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.deleteCoffee(coffee.id);
              Navigator.pop(ctx);
              if (success) await provider.refreshCoffees();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '${coffee.name} deleted successfully!' : 'Failed to delete coffee'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

