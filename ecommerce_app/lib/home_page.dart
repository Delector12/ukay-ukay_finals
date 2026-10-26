import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'payment_page.dart';
import 'my_orders_page.dart';
import 'wishlist_service.dart';

const Color appBrown = Color(0xFF795548);
const Color appCream = Color(0xFFFFF8EE);
const Color appLightBrown = Color(0xFFE5D0B5);
const Color appDarkBrown = Color(0xFF4E342E);

// ============================================================
// SELLER MODEL
// ============================================================

class SellerInfo {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String description;

  const SellerInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.description,
  });
}

const List<SellerInfo> shopSellers = [
  SellerInfo(
    id: 'seller_001',
    name: "Mia's Vintage Closet",
    location: 'Quezon City, Metro Manila',
    imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop',
    description: 'Pre-loved vintage pieces at affordable prices.',
  ),
  SellerInfo(
    id: 'seller_002',
    name: 'Pretty Finds Ukay',
    location: 'Manila, Philippines',
    imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&h=300&fit=crop',
    description: 'Cute, stylish, and budget-friendly ukay finds.',
  ),
  SellerInfo(
    id: 'seller_003',
    name: 'Chic Thrift Shop',
    location: 'Pasig City, Metro Manila',
    imageUrl: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=300&h=300&fit=crop',
    description: 'Chic outfits for everyday wear and special occasions.',
  ),
  SellerInfo(
    id: 'seller_004',
    name: 'Streetwear Ukay',
    location: 'Makati City, Metro Manila',
    imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&h=300&fit=crop',
    description: 'Casual streetwear, jackets, denim, and accessories.',
  ),
];

// ============================================================
// PRODUCT MODEL
// ============================================================

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;
  final List<String> sizes;
  final String sellerId;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.sizes,
    required this.sellerId,
  });

  SellerInfo get seller {
    return shopSellers.firstWhere(
      (seller) => seller.id == sellerId,
      orElse: () => shopSellers.first,
    );
  }
}

// ============================================================
// CART ITEM MODEL
// ============================================================

class CartItem {
  final Product product;
  final String size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'quantity': quantity,
      'size': size,
      'image': product.imageUrl,
      'sellerId': product.sellerId,
      'sellerName': product.seller.name,
    };
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final Map<String, CartItem> cart = {};
  final Set<String> favorites = {};
  final WishlistService wishlistService = WishlistService();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? wishlistSubscription;

  String selectedCategory = 'All';
  String searchText = '';

  final List<String> categories = const [
    'All',
    'Pants',
    'Tops',
    'Jackets',
    'Dresses',
    'Skirts',
    'Bags',
    'Shoes',
    'Accessories',
  ];

  late final List<Product> products = _createProducts();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      wishlistSubscription = wishlistService.getWishlist().listen((snapshot) {
        if (!mounted) return;
        setState(() {
          favorites
            ..clear()
            ..addAll(snapshot.docs.map((doc) => doc.id));
        });
      }, onError: (_) {});
    }
  }

  // Each entry is a real, category-appropriate product.
  // No repeated names are generated just to reach 100 items.
  List<Product> _createProducts() {
    final catalog = <Map<String, dynamic>>[
      // PANTS (15)
      {'name': 'High-Waisted Straight-Leg Jeans', 'category': 'Pants', 'price': 220.0, 'image': 'photo-1542272604-787c3835535d'},
      {'name': 'Classic Blue Denim Jeans', 'category': 'Pants', 'price': 210.0, 'image': 'photo-1541099649105-f69ad21f3246'},
      {'name': 'Black Slim-Fit Trousers', 'category': 'Pants', 'price': 190.0, 'image': 'photo-1506629905607-d9b297d7f6a4'},
      {'name': 'Olive Cargo Pants', 'category': 'Pants', 'price': 230.0, 'image': 'photo-1517438476312-10d79c077509'},
      {'name': 'Relaxed-Fit Jogger Pants', 'category': 'Pants', 'price': 180.0, 'image': 'photo-1552902865-b72c031ac5ea'},
      {'name': 'Beige Wide-Leg Trousers', 'category': 'Pants', 'price': 200.0, 'image': 'photo-1594633312681-425c7b97ccd1'},
      {'name': 'Vintage Mom Jeans', 'category': 'Pants', 'price': 220.0, 'image': 'photo-1548883354-94bcfe321cbb'},
      {'name': 'Distressed Denim Jeans', 'category': 'Pants', 'price': 190.0, 'image': 'photo-1542272604-787c3835535d'},
      {'name': 'Tailored Office Pants', 'category': 'Pants', 'price': 210.0, 'image': 'photo-1598554747436-c9293d6a588f'},
      {'name': 'Casual Linen Trousers', 'category': 'Pants', 'price': 175.0, 'image': 'photo-1503342217505-b0a15ec3261c'},
      {'name': 'Dark-Wash Bootcut Jeans', 'category': 'Pants', 'price': 215.0, 'image': 'photo-1541099649105-f69ad21f3246'},
      {'name': 'Printed Palazzo Pants', 'category': 'Pants', 'price': 170.0, 'image': 'photo-1515886657613-9f3515b0c78f'},
      {'name': 'Track Pants with Side Stripes', 'category': 'Pants', 'price': 160.0, 'image': 'photo-1552902865-b72c031ac5ea'},
      {'name': 'Cropped Ankle Pants', 'category': 'Pants', 'price': 185.0, 'image': 'photo-1594633312681-425c7b97ccd1'},
      {'name': 'Denim Bermuda Shorts', 'category': 'Pants', 'price': 150.0, 'image': 'photo-1542272604-787c3835535d'},

      // TOPS (15)
      {'name': 'Vintage Graphic T-Shirt', 'category': 'Tops', 'price': 120.0, 'image': 'photo-1521572163474-6864f9cf17ab'},
      {'name': 'Classic White Cotton Blouse', 'category': 'Tops', 'price': 135.0, 'image': 'photo-1434389677669-e08b4cac3105'},
      {'name': 'Blue Striped Button-Down Shirt', 'category': 'Tops', 'price': 145.0, 'image': 'photo-1596755094514-f87e34085b2c'},
      {'name': 'Floral Short-Sleeve Blouse', 'category': 'Tops', 'price': 130.0, 'image': 'photo-1485230895905-ec40ba36b9bc'},
      {'name': 'Soft Knit Sweater', 'category': 'Tops', 'price': 180.0, 'image': 'photo-1576566588028-4147f3842f27'},
      {'name': 'Oversized Beige T-Shirt', 'category': 'Tops', 'price': 125.0, 'image': 'photo-1503342217505-b0a15ec3261c'},
      {'name': 'Classic Polo Shirt', 'category': 'Tops', 'price': 140.0, 'image': 'photo-1627225924765-552d49cf47ad'},
      {'name': 'Ribbed Long-Sleeve Top', 'category': 'Tops', 'price': 135.0, 'image': 'photo-1564257577-6a5f3b7f6d2d'},
      {'name': 'Pastel Sleeveless Blouse', 'category': 'Tops', 'price': 115.0, 'image': 'photo-1551163943-3f6a855d1153'},
      {'name': 'Plaid Button-Up Shirt', 'category': 'Tops', 'price': 150.0, 'image': 'photo-1598033129183-c4f50c736f10'},
      {'name': 'Striped Knit Sweater', 'category': 'Tops', 'price': 175.0, 'image': 'photo-1618354691373-d851c5c3a990'},
      {'name': 'Vintage Denim Shirt', 'category': 'Tops', 'price': 160.0, 'image': 'photo-1603252109303-2751441dd157'},
      {'name': 'Black Basic Tank Top', 'category': 'Tops', 'price': 90.0, 'image': 'photo-1503342217505-b0a15ec3261c'},
      {'name': 'Printed Casual Blouse', 'category': 'Tops', 'price': 125.0, 'image': 'photo-1485230895905-ec40ba36b9bc'},
      {'name': 'Cream Turtleneck Sweater', 'category': 'Tops', 'price': 185.0, 'image': 'photo-1576566588028-4147f3842f27'},

      // JACKETS (12)
      {'name': 'Vintage Blue Denim Jacket', 'category': 'Jackets', 'price': 260.0, 'image': 'photo-1551028719-00167b16eac5'},
      {'name': 'Classic Black Blazer', 'category': 'Jackets', 'price': 270.0, 'image': 'photo-1591047139829-d91aecb6caea'},
      {'name': 'Lightweight Windbreaker', 'category': 'Jackets', 'price': 240.0, 'image': 'photo-1544923246-77307dd654cb'},
      {'name': 'Cozy Knit Cardigan', 'category': 'Jackets', 'price': 220.0, 'image': 'photo-1576566588028-4147f3842f27'},
      {'name': 'Brown Corduroy Jacket', 'category': 'Jackets', 'price': 280.0, 'image': 'photo-1591047139829-d91aecb6caea'},
      {'name': 'Cropped Denim Jacket', 'category': 'Jackets', 'price': 250.0, 'image': 'photo-1551028719-00167b16eac5'},
      {'name': 'Oversized Grey Blazer', 'category': 'Jackets', 'price': 275.0, 'image': 'photo-1591047139829-d91aecb6caea'},
      {'name': 'Sporty Zip-Up Jacket', 'category': 'Jackets', 'price': 230.0, 'image': 'photo-1544923246-77307dd654cb'},
      {'name': 'Vintage Floral Cardigan', 'category': 'Jackets', 'price': 210.0, 'image': 'photo-1576566588028-4147f3842f27'},
      {'name': 'Faux-Leather Biker Jacket', 'category': 'Jackets', 'price': 290.0, 'image': 'photo-1551028719-00167b16eac5'},
      {'name': 'Cream Casual Blazer', 'category': 'Jackets', 'price': 260.0, 'image': 'photo-1591047139829-d91aecb6caea'},
      {'name': 'Packable Rain Windbreaker', 'category': 'Jackets', 'price': 225.0, 'image': 'photo-1544923246-77307dd654cb'},

      // DRESSES (12)
      {'name': 'Floral Summer Sundress', 'category': 'Dresses', 'price': 195.0, 'image': 'photo-1515372039744-b8f02a3ae446'},
      {'name': 'Black Midi Slip Dress', 'category': 'Dresses', 'price': 220.0, 'image': 'photo-1496747611176-843222e1e57c'},
      {'name': 'Blue Floral Maxi Dress', 'category': 'Dresses', 'price': 240.0, 'image': 'photo-1539008835657-9e8e9680c956'},
      {'name': 'Vintage Polka-Dot Dress', 'category': 'Dresses', 'price': 230.0, 'image': 'photo-1515886657613-9f3515b0c78f'},
      {'name': 'Sleeveless Linen Dress', 'category': 'Dresses', 'price': 210.0, 'image': 'photo-1490481651871-ab68de25d43d'},
      {'name': 'Elegant Evening Maxi Dress', 'category': 'Dresses', 'price': 280.0, 'image': 'photo-1539008835657-9e8e9680c956'},
      {'name': 'Casual Jersey Midi Dress', 'category': 'Dresses', 'price': 185.0, 'image': 'photo-1496747611176-843222e1e57c'},
      {'name': 'Pastel Wrap Dress', 'category': 'Dresses', 'price': 215.0, 'image': 'photo-1515372039744-b8f02a3ae446'},
      {'name': 'Tiered Boho Maxi Dress', 'category': 'Dresses', 'price': 250.0, 'image': 'photo-1539008835657-9e8e9680c956'},
      {'name': 'Square-Neck Mini Dress', 'category': 'Dresses', 'price': 205.0, 'image': 'photo-1496747611176-843222e1e57c'},
      {'name': 'Vintage Shirt Dress', 'category': 'Dresses', 'price': 200.0, 'image': 'photo-1515886657613-9f3515b0c78f'},
      {'name': 'Pleated Midi Dress', 'category': 'Dresses', 'price': 225.0, 'image': 'photo-1515372039744-b8f02a3ae446'},

      // SKIRTS (10)
      {'name': 'Black Pleated Mini Skirt', 'category': 'Skirts', 'price': 150.0, 'image': 'photo-1583496661160-fb5886a13d24'},
      {'name': 'Blue Denim Midi Skirt', 'category': 'Skirts', 'price': 175.0, 'image': 'photo-1582142306909-195724d33ffc'},
      {'name': 'Floral A-Line Midi Skirt', 'category': 'Skirts', 'price': 165.0, 'image': 'photo-1583496661160-fb5886a13d24'},
      {'name': 'Beige Maxi Skirt', 'category': 'Skirts', 'price': 180.0, 'image': 'photo-1582142306909-195724d33ffc'},
      {'name': 'Vintage Check Mini Skirt', 'category': 'Skirts', 'price': 155.0, 'image': 'photo-1583496661160-fb5886a13d24'},
      {'name': 'Satin Midi Skirt', 'category': 'Skirts', 'price': 170.0, 'image': 'photo-1582142306909-195724d33ffc'},
      {'name': 'Pleated Tennis Skirt', 'category': 'Skirts', 'price': 160.0, 'image': 'photo-1583496661160-fb5886a13d24'},
      {'name': 'Earth-Tone Wrap Skirt', 'category': 'Skirts', 'price': 165.0, 'image': 'photo-1582142306909-195724d33ffc'},
      {'name': 'Denim Button-Front Mini Skirt', 'category': 'Skirts', 'price': 170.0, 'image': 'photo-1583496661160-fb5886a13d24'},
      {'name': 'Boho Printed Maxi Skirt', 'category': 'Skirts', 'price': 185.0, 'image': 'photo-1582142306909-195724d33ffc'},

      // BAGS (10)
      {'name': 'Natural Canvas Tote Bag', 'category': 'Bags', 'price': 180.0, 'image': 'photo-1548036328-c9fa89d128fa'},
      {'name': 'Vintage Brown Shoulder Bag', 'category': 'Bags', 'price': 210.0, 'image': 'photo-1584917865442-de89df76afd3'},
      {'name': 'Black Mini Sling Bag', 'category': 'Bags', 'price': 190.0, 'image': 'photo-1553062407-98eeb64c6a62'},
      {'name': 'Everyday Nylon Backpack', 'category': 'Bags', 'price': 230.0, 'image': 'photo-1622560480654-d96214fdc887'},
      {'name': 'Quilted Chain Shoulder Bag', 'category': 'Bags', 'price': 220.0, 'image': 'photo-1584917865442-de89df76afd3'},
      {'name': 'Small Crossbody Bag', 'category': 'Bags', 'price': 175.0, 'image': 'photo-1553062407-98eeb64c6a62'},
      {'name': 'Classic School Backpack', 'category': 'Bags', 'price': 240.0, 'image': 'photo-1622560480654-d96214fdc887'},
      {'name': 'Woven Summer Tote', 'category': 'Bags', 'price': 195.0, 'image': 'photo-1548036328-c9fa89d128fa'},
      {'name': 'Mini Top-Handle Bag', 'category': 'Bags', 'price': 185.0, 'image': 'photo-1584917865442-de89df76afd3'},
      {'name': 'Sporty Travel Backpack', 'category': 'Bags', 'price': 250.0, 'image': 'photo-1622560480654-d96214fdc887'},

      // SHOES (10)
      {'name': 'White Low-Top Sneakers', 'category': 'Shoes', 'price': 250.0, 'image': 'photo-1542291026-7eec264c27ff'},
      {'name': 'Classic Brown Loafers', 'category': 'Shoes', 'price': 240.0, 'image': 'photo-1533867617858-e7b97e060509'},
      {'name': 'Everyday Flat Sandals', 'category': 'Shoes', 'price': 150.0, 'image': 'photo-1543163521-1bf539c55dd2'},
      {'name': 'Black Ankle Boots', 'category': 'Shoes', 'price': 280.0, 'image': 'photo-1542291026-7eec264c27ff'},
      {'name': 'Retro Running Sneakers', 'category': 'Shoes', 'price': 270.0, 'image': 'photo-1533867617858-e7b97e060509'},
      {'name': 'Strappy Summer Sandals', 'category': 'Shoes', 'price': 165.0, 'image': 'photo-1543163521-1bf539c55dd2'},
      {'name': 'Canvas Slip-On Shoes', 'category': 'Shoes', 'price': 200.0, 'image': 'photo-1542291026-7eec264c27ff'},
      {'name': 'Vintage Chelsea Boots', 'category': 'Shoes', 'price': 290.0, 'image': 'photo-1533867617858-e7b97e060509'},
      {'name': 'Comfort Walking Sandals', 'category': 'Shoes', 'price': 155.0, 'image': 'photo-1543163521-1bf539c55dd2'},
      {'name': 'Black Platform Loafers', 'category': 'Shoes', 'price': 260.0, 'image': 'photo-1533867617858-e7b97e060509'},

      // ACCESSORIES (16)
      {'name': 'Classic Black Sunglasses', 'category': 'Accessories', 'price': 85.0, 'image': 'photo-1511499767150-a48a237f0083'},
      {'name': 'Brown Faux-Leather Belt', 'category': 'Accessories', 'price': 90.0, 'image': 'photo-1553062407-98eeb64c6a62'},
      {'name': 'Gold-Tone Hoop Earrings', 'category': 'Accessories', 'price': 95.0, 'image': 'photo-1535632066927-ab7c9ab60908'},
      {'name': 'Layered Gold Necklace', 'category': 'Accessories', 'price': 110.0, 'image': 'photo-1611652022419-a9419f74343d'},
      {'name': 'Pearl Bracelet', 'category': 'Accessories', 'price': 80.0, 'image': 'photo-1611591437281-460bfbe1220a'},
      {'name': 'Printed Silk-Feel Scarf', 'category': 'Accessories', 'price': 85.0, 'image': 'photo-1601924994987-69e26d50dc26'},
      {'name': 'Silver Pendant Necklace', 'category': 'Accessories', 'price': 100.0, 'image': 'photo-1611652022419-a9419f74343d'},
      {'name': 'Minimalist Wristwatch', 'category': 'Accessories', 'price': 150.0, 'image': 'photo-1524805444758-089113d48a6d'},
      {'name': 'Brown Adjustable Belt', 'category': 'Accessories', 'price': 90.0, 'image': 'photo-1553062407-98eeb64c6a62'},
      {'name': 'Tortoiseshell Sunglasses', 'category': 'Accessories', 'price': 95.0, 'image': 'photo-1511499767150-a48a237f0083'},
      {'name': 'Beaded Statement Bracelet', 'category': 'Accessories', 'price': 85.0, 'image': 'photo-1611591437281-460bfbe1220a'},
      {'name': 'Vintage Brooch Pin', 'category': 'Accessories', 'price': 75.0, 'image': 'photo-1535632066927-ab7c9ab60908'},
      {'name': 'Small Hoop Earrings', 'category': 'Accessories', 'price': 80.0, 'image': 'photo-1535632066927-ab7c9ab60908'},
      {'name': 'Soft Knit Beanie', 'category': 'Accessories', 'price': 95.0, 'image': 'photo-1576871337622-98d48d1cf531'},
      {'name': 'Neutral Baseball Cap', 'category': 'Accessories', 'price': 90.0, 'image': 'photo-1588850561407-ed78c282e89b'},
      {'name': 'Vintage Hair Clip Set', 'category': 'Accessories', 'price': 70.0, 'image': 'photo-1522335789203-aabd1fc54bc9'},
    ];

    return List<Product>.generate(catalog.length, (index) {
      final item = catalog[index];
      final category = item['category'] as String;
      final seller = shopSellers[index % shopSellers.length];

      return Product(
        id: 'ukay_${index + 1}',
        name: item['name'] as String,
        category: category,
        price: item['price'] as double,
        description:
            '${item['name']} — a pre-loved ${category.toLowerCase()} item in good condition. '
            'Please review the photos and select the correct size before checkout.',
        imageUrl: _productImage(item['image'] as String),
        sizes: _sizesForCategory(category),
        sellerId: seller.id,
      );
    });
  }

  List<String> _sizesForCategory(String category) {
    switch (category) {
      case 'Pants':
        return ['26', '28', '30', '32', '34', '36', '38', 'XS', 'S', 'M', 'L', 'XL'];
      case 'Tops':
      case 'Jackets':
      case 'Dresses':
      case 'Skirts':
        return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
      case 'Shoes':
        return ['36', '37', '38', '39', '40', '41', '42', '43', '44'];
      case 'Bags':
      case 'Accessories':
      default:
        return ['One Size'];
    }
  }

  String _productImage(String photoId) {
    return 'https://images.unsplash.com/$photoId?w=700&auto=format&fit=crop';
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      final query = searchText.toLowerCase().trim();
      final matchesSearch = product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.seller.name.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get cartCount {
  return cart.values.fold<int>(
    0,
    (int sum, CartItem item) => sum + item.quantity,
    );
  }

  double get cartTotal {
    return cart.values.fold<double>(
      0.0,
      (double sum, CartItem item) => sum + item.subtotal,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    wishlistSubscription?.cancel();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appBrown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void addToCart(Product product, String size) {
    final key = '${product.id}_$size';
    setState(() {
      if (cart.containsKey(key)) {
        cart[key]!.quantity++;
      } else {
        cart[key] = CartItem(product: product, size: size);
      }
    });
    showMessage('${product.name} added to cart!');
  }

  void changeQuantity(String key, int change) {
    setState(() {
      if (!cart.containsKey(key)) return;
      cart[key]!.quantity += change;
      if (cart[key]!.quantity <= 0) cart.remove(key);
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void openSeller(SellerInfo seller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellerPage(
          seller: seller,
          products: products,
          onProductTap: (product) {
            Navigator.pop(context);
            showProductDetails(product);
          },
        ),
      ),
    );
  }

  void openSellerDirectory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellerDirectoryPage(
          sellers: shopSellers,
          products: products,
          onSellerTap: openSeller,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getRatingData(String productId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('product_reviews')
          .where('productId', isEqualTo: productId)
          .get();
      if (snapshot.docs.isEmpty) return {'average': 0.0, 'count': 0};

      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['rating'] as num?)?.toDouble() ?? 0;
      }
      return {'average': total / snapshot.docs.length, 'count': snapshot.docs.length};
    } catch (_) {
      return {'average': 0.0, 'count': 0};
    }
  }

  Future<Map<String, dynamic>> getReviewEligibility(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'canReview': false, 'message': 'Please log in to review this product.'};
    }

    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final orderDoc in ordersSnapshot.docs) {
      final order = orderDoc.data();
      final status = (order['orderStatus'] ?? order['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      if (status != 'delivered') continue;

      final rawItems = order['items'];
      if (rawItems is! List) continue;

      final hasProduct = rawItems.any((rawItem) {
        if (rawItem is! Map) return false;
        final item = Map<String, dynamic>.from(rawItem);
        final itemProductId = item['productId']?.toString() ?? '';
        return itemProductId.isNotEmpty
            ? itemProductId == product.id
            : item['name']?.toString() == product.name;
      });
      if (!hasProduct) continue;

      final userReviews = await FirebaseFirestore.instance
          .collection('product_reviews')
          .where('userId', isEqualTo: user.uid)
          .get();
      final alreadyReviewed = userReviews.docs.any((reviewDoc) {
        final review = reviewDoc.data();
        return review['orderId'] == orderDoc.id &&
            review['productId'] == product.id;
      });

      if (alreadyReviewed) continue;

      return {'canReview': true, 'orderId': orderDoc.id};
    }

    return {
      'canReview': false,
      'message': 'You can rate and review this item after your order is marked Delivered.',
    };
  }

  void showProductDetails(Product product) {
    String selectedSize = product.sizes.first;
    double selectedRating = 5;
    final commentController = TextEditingController();
    final reviewEligibilityFuture = getReviewEligibility(product);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: appCream,
              insetPadding: const EdgeInsets.all(16),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          product.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 220,
                            color: appLightBrown,
                            child: const Center(
                              child: Icon(Icons.checkroom, size: 70, color: appBrown),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(product.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: appBrown)),
                      Text(product.category, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text('₱${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, color: appBrown, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(product.description),
                      const SizedBox(height: 16),
                      const Text('Seller', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: appLightBrown,
                          backgroundImage: NetworkImage(product.seller.imageUrl),
                        ),
                        title: Text(product.seller.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(product.seller.location),
                        trailing: const Icon(Icons.storefront, color: appBrown),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          openSeller(product.seller);
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: appBrown,
                            side: const BorderSide(color: appBrown),
                          ),
                          icon: const Icon(Icons.storefront),
                          label: const Text('View Seller Shop'),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            openSeller(product.seller);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.category == 'Shoes'
                            ? 'Choose Shoe Size'
                            : (product.category == 'Pants'
                                ? 'Choose Waist / Clothing Size'
                                : (product.category == 'Bags' || product.category == 'Accessories'
                                    ? 'Size'
                                    : 'Choose Clothing Size')),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.sizes.map((size) {
                          return ChoiceChip(
                            label: Text(size),
                            selected: selectedSize == size,
                            selectedColor: appLightBrown,
                            onSelected: (_) => setDialogState(() => selectedSize = size),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Ratings & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      FutureBuilder<Map<String, dynamic>>(
                        future: getRatingData(product.id),
                        builder: (context, snapshot) {
                          final data = snapshot.data ?? {'average': 0.0, 'count': 0};
                          final average = (data['average'] as num).toDouble();
                          final count = data['count'] as int;
                          return Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 5),
                              Text(count == 0 ? 'No reviews yet' : '${average.toStringAsFixed(1)} / 5 ($count reviews)'),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<Map<String, dynamic>>(
                        future: reviewEligibilityFuture,
                        builder: (context, eligibilitySnapshot) {
                          if (eligibilitySnapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator(color: appBrown)),
                            );
                          }

                          final eligibility = eligibilitySnapshot.data ?? {
                            'canReview': false,
                            'message': 'Unable to check review eligibility.',
                          };
                          final canReview = eligibility['canReview'] == true;

                          if (!canReview) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: appLightBrown.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                eligibility['message']?.toString() ??
                                    'You can review after your order is delivered.',
                                style: const TextStyle(color: appDarkBrown),
                              ),
                            );
                          }

                          final orderId = eligibility['orderId']?.toString() ?? '';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your rating'),
                              Row(
                                children: List.generate(5, (index) {
                                  final rating = index + 1;
                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => setDialogState(() => selectedRating = rating.toDouble()),
                                    icon: Icon(
                                      rating <= selectedRating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 30,
                                    ),
                                  );
                                }),
                              ),
                              TextField(
                                controller: commentController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Write your review...',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appBrown,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final user = FirebaseAuth.instance.currentUser;
                                    if (user == null) {
                                      showMessage('Please log in to submit a review.');
                                      return;
                                    }
                                    if (commentController.text.trim().isEmpty) {
                                      showMessage('Please write a comment before submitting.');
                                      return;
                                    }
                                    try {
                                      // Re-check eligibility before writing the review.
                                      final check = await getReviewEligibility(product);
                                      if (check['canReview'] != true || check['orderId'] != orderId) {
                                        showMessage(check['message']?.toString() ?? 'This order is not eligible for a review.');
                                        return;
                                      }
                                      await FirebaseFirestore.instance.collection('product_reviews').add({
                                        'productId': product.id,
                                        'productName': product.name,
                                        'userId': user.uid,
                                        'userName': user.displayName ?? 'Customer',
                                        'orderId': orderId,
                                        'rating': selectedRating,
                                        'comment': commentController.text.trim(),
                                        'createdAt': FieldValue.serverTimestamp(),
                                      });
                                      if (!dialogContext.mounted) return;
                                      Navigator.pop(dialogContext);
                                      commentController.dispose();
                                      showMessage('Review submitted successfully!');
                                      showProductDetails(product);
                                    } catch (e) {
                                      showMessage('Could not submit review: $e');
                                    }
                                  },
                                  child: const Text('Submit Review'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: appBrown, foregroundColor: Colors.white),
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Add to Cart'),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                commentController.dispose();
                                addToCart(product, selectedSize);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              commentController.dispose();
                            },
                            child: const Text('Close', style: TextStyle(color: appBrown)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appCream,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final items = cart.entries.toList();
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('My Shopping Cart', style: TextStyle(color: appBrown, fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: items.isEmpty
                          ? const Center(child: Text('Your cart is empty.'))
                          : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (_, index) {
                                final entry = items[index];
                                final item = entry.value;
                                return Card(
                                  color: Colors.white,
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.product.imageUrl,
                                        width: 55,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.checkroom),
                                      ),
                                    ),
                                    title: Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    subtitle: Text('Size: ${item.size}\n₱${item.product.price.toStringAsFixed(2)}'),
                                    isThreeLine: true,
                                    trailing: SizedBox(
                                      width: 112,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              changeQuantity(entry.key, -1);
                                              setSheetState(() {});
                                            },
                                            icon: const Icon(Icons.remove_circle_outline),
                                          ),
                                          Text('${item.quantity}'),
                                          IconButton(
                                            onPressed: () {
                                              changeQuantity(entry.key, 1);
                                              setSheetState(() {});
                                            },
                                            icon: const Icon(Icons.add_circle_outline),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: appLightBrown)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('₱${cartTotal.toStringAsFixed(2)}', style: const TextStyle(color: appBrown, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appBrown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: cart.isEmpty
                                  ? null
                                  : () {
                                      final checkoutItems = cart.values.map((item) => item.toMap()).toList();
                                      final total = cartTotal;
                                      Navigator.pop(sheetContext);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PaymentPage(items: checkoutItems, totalAmount: total),
                                        ),
                                      );
                                    },
                              child: const Text('Proceed to Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openOrderHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersPage()));
  }

  void openWishlist() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()));
  }

  Future<void> toggleFavorite(Product product) async {
    if (FirebaseAuth.instance.currentUser == null) {
      showMessage('Please log in to use your wishlist.');
      return;
    }
    try {
      final added = await wishlistService.toggleWishlist(
        productId: product.id,
        productName: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      if (!mounted) return;
      showMessage(added
          ? '${product.name} added to wishlist!'
          : '${product.name} removed from wishlist.');
    } catch (e) {
      if (!mounted) return;
      showMessage('Wishlist error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCream,
      appBar: AppBar(
        backgroundColor: appBrown,
        foregroundColor: Colors.white,
        title: const Text('Ukay-Ukay Finds', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(tooltip: 'Seller Shops', onPressed: openSellerDirectory, icon: const Icon(Icons.storefront)),
          IconButton(tooltip: 'My Wishlist', onPressed: openWishlist, icon: const Icon(Icons.favorite_border)),
          IconButton(tooltip: 'My Orders', onPressed: openOrderHistory, icon: const Icon(Icons.receipt_long)),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(tooltip: 'Cart', onPressed: openCart, icon: const Icon(Icons.shopping_cart_outlined)),
              if (cartCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          IconButton(tooltip: 'Logout', onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchText = value),
              decoration: InputDecoration(
                hintText: 'Search clothes, bags, shoes, sellers...',
                prefixIcon: const Icon(Icons.search, color: appBrown),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchText = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: openSellerDirectory,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appLightBrown.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storefront, color: appBrown, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Discover Our Sellers', style: TextStyle(fontWeight: FontWeight.bold, color: appBrown)),
                          Text('Visit seller shops and explore their items.', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: appBrown, size: 16),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final category = categories[index];
                final selected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    selectedColor: appBrown,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: selected ? Colors.white : appBrown, fontWeight: FontWeight.w600),
                    onSelected: (_) => setState(() => selectedCategory = category),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Pre-loved Treasures', style: TextStyle(color: appBrown, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Text('${filteredProducts.length} items', style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('No products found.'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1100 ? 5 : width >= 750 ? 4 : width >= 500 ? 3 : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: 0.56,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (_, index) {
                          final product = filteredProducts[index];
                          final isFavorite = favorites.contains(product.id);
                          return Card(
                            color: Colors.white,
                            elevation: 3,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(child: CircularProgressIndicator(color: appBrown));
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: appLightBrown,
                                          child: const Center(child: Icon(Icons.checkroom, color: appBrown, size: 48)),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: CircleAvatar(
                                          radius: 17,
                                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 19,
                                            onPressed: () => toggleFavorite(product),
                                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : appBrown),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(product.category, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                                      const SizedBox(height: 3),
                                      Text('₱${product.price.toStringAsFixed(2)}', style: const TextStyle(color: appBrown, fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 3),
                                      Text(product.seller.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 10)),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: appBrown,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            minimumSize: const Size(0, 34),
                                          ),
                                          onPressed: () => showProductDetails(product),
                                          child: const Text('View Details', style: TextStyle(fontSize: 11)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SELLER DIRECTORY PAGE
// ============================================================

class SellerDirectoryPage extends StatelessWidget {
  final List<SellerInfo> sellers;
  final List<Product> products;
  final ValueChanged<SellerInfo> onSellerTap;

  const SellerDirectoryPage({
    super.key,
    required this.sellers,
    required this.products,
    required this.onSellerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCream,
      appBar: AppBar(backgroundColor: appBrown, foregroundColor: Colors.white, title: const Text('Our Sellers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Shop by Seller', style: TextStyle(color: appBrown, fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Discover unique finds from our ukay-ukay sellers.'),
          const SizedBox(height: 16),
          ...sellers.map((seller) {
            final count = products.where((p) => p.sellerId == seller.id).length;
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSellerTap(seller),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: appLightBrown,
                        backgroundImage: NetworkImage(seller.imageUrl),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: const Icon(Icons.store, color: appBrown),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(seller.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appBrown)),
                            const SizedBox(height: 4),
                            Text(seller.location, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 5),
                            Text(seller.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 5),
                            Text('$count products', style: const TextStyle(color: appBrown, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: appBrown),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// INDIVIDUAL SELLER PAGE
// ============================================================

class SellerPage extends StatelessWidget {
  final SellerInfo seller;
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const SellerPage({
    super.key,
    required this.seller,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final sellerProducts = products.where((p) => p.sellerId == seller.id).toList();

    return Scaffold(
      backgroundColor: appCream,
      appBar: AppBar(backgroundColor: appBrown, foregroundColor: Colors.white, title: const Text('Seller Shop')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              color: appLightBrown.withValues(alpha: 0.55),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(seller.imageUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: const Icon(Icons.storefront, color: appBrown, size: 42),
                  ),
                  const SizedBox(height: 12),
                  Text(seller.name, textAlign: TextAlign.center, style: const TextStyle(color: appBrown, fontSize: 23, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 17, color: appBrown),
                      Flexible(child: Text(seller.location, textAlign: TextAlign.center)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(seller.description, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Chip(
                    avatar: const Icon(Icons.shopping_bag, size: 18, color: appBrown),
                    label: Text('${sellerProducts.length} products'),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text('Products from ${seller.name}', style: const TextStyle(color: appBrown, fontSize: 19, fontWeight: FontWeight.bold)),
            ),
          ),
          if (sellerProducts.isEmpty)
            const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No products available yet.'))))
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width >= 850 ? 4 : width >= 550 ? 3 : 2;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = sellerProducts[index];
                        return Card(
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: InkWell(
                            onTap: () => onProductTap(product),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: appLightBrown,
                                        child: const Center(child: Icon(Icons.checkroom, size: 45, color: appBrown)),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(9),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('₱${product.price.toStringAsFixed(2)}', style: const TextStyle(color: appBrown, fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      const Text('View product', style: TextStyle(color: appBrown, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: sellerProducts.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// ORDER HISTORY PAGE
// ============================================================

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: appCream,
      appBar: AppBar(backgroundColor: appBrown, foregroundColor: Colors.white, title: const Text('Order History')),
      body: user == null
          ? const Center(child: Text('Please log in to view your orders.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load orders. Please try again.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: appBrown));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long, size: 65, color: appLightBrown),
                        SizedBox(height: 12),
                        Text('You have no orders yet.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final order = docs[index].data();
                    final rawItems = order['items'];
                    final items = rawItems is List ? rawItems : [];
                    final status = (order['orderStatus'] ?? order['status'] ?? 'Pending').toString();
                    final paymentMethod = order['paymentMethod']?.toString() ?? 'Not specified';
                    final total = (order['totalAmount'] as num?)?.toDouble() ?? 0;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.receipt_long, color: appBrown),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Order #${docs[index].id.substring(0, docs[index].id.length > 8 ? 8 : docs[index].id.length)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: appLightBrown.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(status, style: const TextStyle(color: appBrown, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 22),
                            ...items.map((rawItem) {
                              if (rawItem is! Map) return const SizedBox.shrink();
                              final item = Map<String, dynamic>.from(rawItem);
                              final name = item['name']?.toString() ?? 'Product';
                              final size = item['size']?.toString() ?? 'N/A';
                              final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
                              final price = (item['price'] as num?)?.toDouble() ?? 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Text('$name (Size: $size)')),
                                    Text('x$quantity'),
                                    const SizedBox(width: 12),
                                    Text('₱${(price * quantity).toStringAsFixed(2)}'),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Payment'),
                                Flexible(child: Text(paymentMethod, textAlign: TextAlign.end)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(color: appBrown, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
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
}


// ============================================================
// WISHLIST PAGE (FIRESTORE)
// ============================================================

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = WishlistService();
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: appCream,
        appBar: AppBar(
          title: const Text('My Wishlist'),
          backgroundColor: appBrown,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Please log in to view your wishlist.')),
      );
    }

    return Scaffold(
      backgroundColor: appCream,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: appBrown,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.getWishlist(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load wishlist.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: appBrown));
          }
          final products = snapshot.data?.docs ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: appBrown),
                  SizedBox(height: 12),
                  Text('Your wishlist is empty.'),
                  Text('Save products you love!'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data();
              final name = data['productName']?.toString() ?? 'Product';
              final price = (data['price'] as num?)?.toDouble() ?? 0.0;
              final imageUrl = data['imageUrl']?.toString() ?? '';
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: SizedBox(
                    width: 60,
                    height: 70,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.checkroom, color: appBrown)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.checkroom, color: appBrown),
                          ),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: const TextStyle(color: appBrown, fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove from wishlist',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      try {
                        await service.removeFromWishlist(doc.id);
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unable to remove product.')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
