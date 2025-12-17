import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/category_model.dart';
import '../../services/firestore_service.dart';

/// 📂 CATEGORIES SCREEN
/// Manage expense and income categories
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  
  List<CategoryModel> _expenseCategories = [];
  List<CategoryModel> _incomeCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    
    // Load default categories
    _expenseCategories = CategoryModel.getDefaultExpenseCategories();
    _incomeCategories = CategoryModel.getDefaultIncomeCategories();

    // Try to load user's custom categories
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _firestoreService.getCategoriesStream(authProvider.currentUser!.uid).listen((categories) {
        if (mounted) {
          setState(() {
            final customExpense = categories.where((c) => c.type == 'expense' && !c.isDefault).toList();
            final customIncome = categories.where((c) => c.type == 'income' && !c.isDefault).toList();
            
            _expenseCategories = [
              ...CategoryModel.getDefaultExpenseCategories(),
              ...customExpense,
            ];
            _incomeCategories = [
              ...CategoryModel.getDefaultIncomeCategories(),
              ...customIncome,
            ];
          });
        }
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.category_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () => _showAddCategoryDialog(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          indicatorWeight: 3,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Expense', icon: Icon(Icons.arrow_upward, size: 20)),
            Tab(text: 'Income', icon: Icon(Icons.arrow_downward, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryGrid(_expenseCategories, 'expense'),
                _buildCategoryGrid(_incomeCategories, 'income'),
              ],
            ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryModel> categories, String type) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCategoryDetails(category),
          onLongPress: category.isDefault ? null : () => _showDeleteDialog(category),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category.hasBudget) ...[
                  const SizedBox(height: 4),
                  Text(
                    category.getFormattedBudget('\$'),
                    style: TextStyle(
                      color: AppColors.primaryYellow.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (!category.isDefault) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Custom',
                      style: TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(CategoryModel category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: category.type == 'expense'
                    ? AppColors.primaryPink.withOpacity(0.2)
                    : const Color(0xFF4CAF50).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.type == 'expense' ? 'Expense Category' : 'Income Category',
                style: TextStyle(
                  color: category.type == 'expense'
                      ? AppColors.primaryPink
                      : const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (category.hasBudget)
              _buildDetailRow('Monthly Budget', category.getFormattedBudget('\$')),
            _buildDetailRow('Type', category.isDefault ? 'Default' : 'Custom'),
            const SizedBox(height: 24),
            if (!category.isDefault)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditCategoryDialog(category);
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(category);
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Delete', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    String selectedType = 'expense';
    int selectedIconIndex = 0;
    int selectedColorIndex = 0;

    final icons = [
      Icons.shopping_bag,
      Icons.restaurant,
      Icons.directions_car,
      Icons.movie,
      Icons.medical_services,
      Icons.school,
      Icons.home,
      Icons.sports_esports,
      Icons.pets,
      Icons.fitness_center,
      Icons.flight,
      Icons.card_giftcard,
    ];

    final colors = [
      AppColors.primaryYellow,
      AppColors.primaryPink,
      AppColors.primaryPurple,
      AppColors.primaryRose,
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'New Category 📂',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Category Type Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedType = 'expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: selectedType == 'expense'
                                  ? AppColors.yellowPinkGradient
                                  : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Expense',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedType = 'income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == 'income'
                                  ? const Color(0xFF4CAF50)
                                  : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Income',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Name Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: TextStyle(color: Colors.white60),
                      prefixIcon: Icon(Icons.label, color: AppColors.primaryYellow),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Budget Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Budget (Optional)',
                      labelStyle: TextStyle(color: Colors.white60),
                      prefixIcon: Icon(Icons.attach_money, color: AppColors.primaryYellow),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Icon Selection
                const Text(
                  'Choose Icon',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: icons.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => setModalState(() => selectedIconIndex = index),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selectedIconIndex == index
                              ? colors[selectedColorIndex].withOpacity(0.3)
                              : AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(12),
                          border: selectedIconIndex == index
                              ? Border.all(color: colors[selectedColorIndex], width: 2)
                              : null,
                        ),
                        child: Icon(
                          icons[index],
                          color: selectedIconIndex == index
                              ? colors[selectedColorIndex]
                              : Colors.white60,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Color Selection
                const Text(
                  'Choose Color',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: colors.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => setModalState(() => selectedColorIndex = index),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(10),
                          border: selectedColorIndex == index
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: selectedColorIndex == index
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a name')),
                        );
                        return;
                      }

                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      if (authProvider.currentUser == null) return;

                      final category = CategoryModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: authProvider.currentUser!.uid,
                        name: nameController.text,
                        icon: icons[selectedIconIndex],
                        color: colors[selectedColorIndex],
                        monthlyBudget: budgetController.text.isNotEmpty
                            ? double.parse(budgetController.text)
                            : null,
                        isDefault: false,
                        type: selectedType,
                        createdAt: DateTime.now(),
                      );

                      await _firestoreService.addCategory(category);
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Category created! 📂'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditCategoryDialog(CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    final budgetController = TextEditingController(
      text: category.monthlyBudget?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Category', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: AppColors.primaryNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Monthly Budget',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: AppColors.primaryNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedCategory = category.copyWith(
                name: nameController.text,
                monthlyBudget: budgetController.text.isNotEmpty
                    ? double.parse(budgetController.text)
                    : null,
              );

              await _firestoreService.updateCategory(updatedCategory);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category updated!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteCategory(category.id);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
