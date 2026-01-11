import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'db_helper.dart';

void main() {
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Inventory',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        fontFamily: 'Sans-serif',
      ),
      home: const SplashScreen(),
    );
  }
}

// 1. SPLASH SCREEN (Cek Session)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.indigo.shade500],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "SMART INVENTORY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              "Solusi Kelola Stok Modern",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _handleLogin() async {
    if (_user.text == 'admin' && _pass.text == 'admin123') {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username atau Password Salah!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(35),
          child: Column(
            children: [
              const Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 15),
              const Text(
                "Admin Login",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _user,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _handleLogin,
                  child: const Text(
                    "MASUK SISTEM",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await _dbHelper.getProducts();
    setState(() {
      products = data;
    });
  }

  void _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _openWhatsApp(String productName, String stock) async {
    String message =
        "Halo Supplier, stok barang *$productName* sisa *$stock*. Tolong kirim stok tambahan.";
    String url =
        "https://wa.me/6285713306040?text=${Uri.encodeComponent(message)}";
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka WhatsApp")));
    }
  }

  void _openMaps() async {
    const String mapsUrl = "https://www.google.com/maps";
    if (!await launchUrl(
      Uri.parse(mapsUrl),
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka Maps")));
    }
  }

  void _deleteProduct(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Barang"),
        content: Text("Yakin ingin menghapus $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _dbHelper.deleteProduct(id);
              _loadProducts();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _showForm(int? index) {
    TextEditingController nC = TextEditingController();
    TextEditingController pC = TextEditingController();
    TextEditingController sC = TextEditingController();

    if (index != null) {
      nC.text = products[index]['name'];
      pC.text = products[index]['price'].toString();
      sC.text = products[index]['stock'].toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? "Tambah Produk" : "Edit Produk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nC,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: pC,
              decoration: const InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: sC,
              decoration: const InputDecoration(labelText: "Stok"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final price = int.tryParse(pC.text);
              final stock = int.tryParse(sC.text);
              if (nC.text.isEmpty || price == null || stock == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Input tidak valid!")),
                );
                return;
              }
              final Map<String, dynamic> row = {
                'name': nC.text,
                'price': price,
                'stock': stock,
              };
              if (index == null) {
                await _dbHelper.insertProduct(row);
              } else {
                row['id'] = products[index]['id'];
                await _dbHelper.updateProduct(row);
              }
              _loadProducts();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard Inventaris",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: _openMaps,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text("Data Kosong"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final prod = products[index];
                final bool lowStock = prod['stock'] <= 5;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: lowStock
                          ? Colors.red.shade100
                          : Colors.indigo.shade100,
                      child: Icon(
                        Icons.inventory,
                        color: lowStock ? Colors.red : Colors.indigo,
                      ),
                    ),
                    title: Text(
                      prod['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Harga: Rp ${prod['price']}"),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: lowStock
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Stok: ${prod['stock']}",
                            style: TextStyle(
                              color: lowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.message, color: Colors.green),
                          onPressed: () => _openWhatsApp(
                            prod['name'],
                            prod['stock'].toString(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteProduct(prod['id'], prod['name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(null),
        label: const Text("Tambah Produk"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}
