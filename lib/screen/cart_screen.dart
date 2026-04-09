import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mastery/services/payment_service.dart';
import '../db/database_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final data = await DatabaseHelper.instance.getCartItems();
    double total = 0;
    for (var item in data) {
      total += (item['price'] * item['quantity']);
    }
    if (mounted) {
      setState(() {
        _cartItems = data;
        _totalPrice = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF8C42);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty!"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Top align
                            children: [
                              // Product Image with Error Handling
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item['image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info Section - Wrapped in Expanded to prevent Overflow
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${item['price']}",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Quantity Selector
                                    Row(
                                      children: [
                                        _buildQtyBtn(
                                          Icons.remove_circle_outline,
                                          () async {
                                            if (item['quantity'] > 1) {
                                              await DatabaseHelper.instance
                                                  .updateCartQuantity(
                                                    item['id'],
                                                    item['quantity'] - 1,
                                                  );
                                            } else {
                                              await DatabaseHelper.instance
                                                  .removeFromCart(item['id']);
                                            }
                                            _loadCart();
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            "${item['quantity']}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _buildQtyBtn(
                                          Icons.add_circle_outline,
                                          () async {
                                            await DatabaseHelper.instance
                                                .updateCartQuantity(
                                                  item['id'],
                                                  item['quantity'] + 1,
                                                );
                                            _loadCart();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_sweep_outlined,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  await DatabaseHelper.instance.removeFromCart(
                                    item['id'],
                                  );
                                  _loadCart();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Checkout Section
                _buildCheckoutSection(primaryColor),
              ],
            ),
    );
  }

  // Reusable Quantity Button to keep UI clean
  Widget _buildQtyBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Icon(icon, color: const Color(0xFFFF8C42), size: 24),
    );
  }

  Widget _buildCheckoutSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Payable:",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  "\$${_totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isProcessing ? null : _handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Checkout Now",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout() async {
    setState(() => _isProcessing = true);
    try {
      String amount = (_totalPrice * 100).toInt().toString();
      await PaymentService.makePayment(amount);

      // Payment success logic
      await DatabaseHelper.instance.clearCart();
      if (mounted) _showSuccessDialog();
    } catch (e) {
      // শুধু পেমেন্ট ফেইল করলে মেসেজ দেখাবে, ক্যানসেল করলে শান্ত থাকবে
      debugPrint("Payment Error: $e");
      if (mounted && !e.toString().contains('Canceled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment unsuccessful. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Order Placed!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your payment was successful.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false),
                child: const Text("Back to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
