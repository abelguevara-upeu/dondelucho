import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import 'categorias_screen.dart';
import 'custom_bottom_nav_bar.dart';
import 'platos_categoria_screen.dart';
import 'carrito.screen.dart';
import 'cuenta_screen.dart'; // 👈 Importado

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  List<String> promotionImages = [];
  Timer? _autoChangeTimer;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
    _startAutoChange();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoChangeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPromotions() async {
    FirebaseFirestore.instance.collection('promotions').snapshots().listen((snapshot) async {
      List<String> validImages = [];
      for (var doc in snapshot.docs) {
        String? url = doc['image_url'];
        if (url != null && await _isValidUrl(url)) {
          validImages.add(url);
        } else {
          await doc.reference.delete();
        }
      }
      setState(() {
        promotionImages = validImages;
      });
    });
  }

  Future<bool> _isValidUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _startAutoChange() {
    _autoChangeTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (promotionImages.isNotEmpty) {
        setState(() {
          _currentPage = (_currentPage + 1) % promotionImages.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final List<Widget> widgetOptions = <Widget>[
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.asset('assets/logo_principal.jpg', height: 80),
          ),
          SizedBox(
            height: 120,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final categories = snapshot.data!.docs;
                if (categories.isEmpty) return Center(child: Text("No hay categorías disponibles."));

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final data = categories[index].data() as Map<String, dynamic>;
                    final categoryName = data['name'] ?? '';
                    final imageUrl = data['image_url'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlatosCategoriaScreen(categoria: categoryName.toLowerCase()),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(categoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: promotionImages.isEmpty
                ? Center(child: CircularProgressIndicator())
                : PageView.builder(
                    controller: _pageController,
                    itemCount: promotionImages.length,
                    itemBuilder: (_, index) => _promotionImage(promotionImages[index]),
                  ),
          ),
        ],
      ),
      CategoriasScreen(),
      Center(child: Text('Promociones', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      Center(child: Text('Pedidos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      CuentaScreen(), // 👈 Agregado aquí
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(''),
      ),
      body: Stack(
        children: [
          widgetOptions[_selectedIndex],
          if (cart.items.isNotEmpty)
            Positioned(
              bottom: 70,
              right: 16,
              child: FloatingActionButton.extended(
                backgroundColor: Color(0xF2642424),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                icon: Icon(Icons.shopping_cart),
                label: Text("${cart.items.length} - s/ ${cart.total.toStringAsFixed(2)}"),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _promotionImage(String imageUrl) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }
}
