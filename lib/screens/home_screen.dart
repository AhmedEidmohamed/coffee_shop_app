import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_model.dart';
import 'detail_screen.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  List<String> _categories = ['All Coffee'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoffees();
    });
  }

  Future<void> _loadCoffees() async {
    final provider = Provider.of<CoffeeProvider>(context, listen: false);
    await provider.loadCoffees();
  }


  void _editCoffee(Coffee coffee) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: coffee.name);
    final descriptionController =
        TextEditingController(text: coffee.description);
    final priceController =
        TextEditingController(text: coffee.price.toString());
    final imageController = TextEditingController(text: coffee.imageUrl);
    String selectedCategory = coffee.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            tr('edit_coffee'),
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
                  final updatedCoffee = coffee.copyWith(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    imageUrl: imageController.text,
                    category: selectedCategory,
                  );
                  final provider =
                      Provider.of<CoffeeProvider>(context, listen: false);
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(ctx).pop();
                  
                  final success =
                      await provider.updateCoffee(coffee.id, updatedCoffee);
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(tr('coffee_updated'))),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(tr('update_failed'))),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F4E37),
                foregroundColor: Colors.white,
              ),
              child: Text(tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCoffee(Coffee coffee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('delete_coffee')),
        content: Text(tr('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<CoffeeProvider>(context, listen: false);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              
              final success = await provider.deleteCoffee(coffee.id);
              if (success) {
                messenger.showSnackBar(
                  SnackBar(content: Text(tr('coffee_deleted'))),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(content: Text(tr('delete_failed'))),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.coffees.isEmpty) {
            return _buildLoading();
          }

          if (provider.error.isNotEmpty && provider.coffees.isEmpty) {
            return _buildError(provider);
          }

          // تحديث الأقسام ديناميكياً
          final uniqueCategories = provider.coffees
              .map((c) => c.category)
              .where((cat) => cat.isNotEmpty && cat != 'All Coffee')
              .toSet()
              .toList();
          
          // ندمج "All Coffee" مع الأقسام القادمة من الداتا
          final newCategories = ['All Coffee', ...uniqueCategories];
          
          // تحديث القائمة إذا كانت مختلفة لتجنب اللوب اللانهائي
          if (newCategories.length != _categories.length || 
              !newCategories.every((cat) => _categories.contains(cat))) {
            Future.delayed(Duration.zero, () {
              if (mounted) {
                setState(() {
                  _categories = newCategories;
                });
              }
            });
          }

          final filteredCoffees = _filterCoffees(provider.coffees);

          return RefreshIndicator(
            onRefresh: () async {
              await provider.refreshCoffees();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromoBanner(),
                    const SizedBox(height: 24),
                    _buildCategoryTabs(),
                    const SizedBox(height: 24),
                    if (filteredCoffees.isEmpty)
                      _buildNoResults()
                    else
                      _buildCoffeeGrid(filteredCoffees),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF6F4E37),
      ),
    );
  }

  Widget _buildError(CoffeeProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 60, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            tr('error'),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            provider.error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadCoffees,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F4E37),
            ),
            child: Text(tr('retry')),
          ),
        ],
      ),
    );
  }

  List<Coffee> _filterCoffees(List<Coffee> coffees) {
    List<Coffee> filtered = coffees;

    if (_selectedCategory > 0) {
      final category = _categories[_selectedCategory].toLowerCase();
      filtered = filtered
          .where((coffee) => coffee.category.toLowerCase() == category)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((coffee) =>
              coffee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              coffee.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            tr('no_results'),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr('welcome')}, ${user?.name ?? user?.email?.split('@')[0] ?? tr('user')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                'Coffee Shop',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state.user?.isAdmin ?? false) {
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF6F4E37)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // Notifications logic here
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: tr('search_coffees'),
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6F4E37), Color(0xFF8B7355)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('by_one_get_one_free'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'FREE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tr('order_now'),
                    style: const TextStyle(
                      color: Color(0xFF6F4E37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/2935/2935413.png',
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _selectedCategory == index
                    ? const Color(0xFF6F4E37)
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tr(_categories[index].toLowerCase().replaceAll(' ', '_')),
                style: TextStyle(
                  color: _selectedCategory == index
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoffeeGrid(List<Coffee> coffees) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.7,
      ),
      itemCount: coffees.length,
      itemBuilder: (context, index) {
        final coffee = coffees[index];
        final provider = Provider.of<CoffeeProvider>(context);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(coffee: coffee),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصورة
                    Expanded(
                      child: Stack(
                        children: [
                          _buildCoffeeImage(coffee.imageUrl),
                          // أيقونة القلب داخل الصورة
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                provider.toggleFavorite(coffee.id);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  coffee.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: coffee.isFavorite
                                      ? Colors.red
                                      : Colors.grey[600],
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // تفاصيل المنتج
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  coffee.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${coffee.rating}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Text(
                                      'Price',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '\$${coffee.price.toStringAsFixed(2)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF6F4E37),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (context.read<AuthCubit>().state.user?.isAdmin ?? false)
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _editCoffee(coffee),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.edit, size: 20),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _deleteCoffee(coffee),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildCoffeeImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          color: Colors.grey[300],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          color: Colors.grey[300],
        ),
        child: const Center(
          child: Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }
}
