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
    setState(() {
      _cartItems = data;
      _totalPrice = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF8C42);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.black)),
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
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product Info
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
                                        fontSize: 14,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Quantity Controls
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            int newQty = item['quantity'] - 1;
                                            if (newQty <= 0) {
                                              await DatabaseHelper.instance
                                                  .removeFromCart(item['id']);
                                            } else {
                                              await DatabaseHelper.instance
                                                  .updateCartQuantity(
                                                item['id'],
                                                newQty,
                                              );
                                            }
                                            _loadCart();
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        Text(
                                          "${item['quantity']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            int newQty = item['quantity'] + 1;
                                            await DatabaseHelper.instance
                                                .updateCartQuantity(
                                              item['id'],
                                              newQty,
                                            );
                                            _loadCart();
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${_totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            String amount = (_totalPrice * 100).toInt().toString();
                            
                            // Make payment first
                            await PaymentService.makePayment(amount);
                            
                            // Only clear cart if payment was successful
                            await DatabaseHelper.instance.clearCart();

                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 60,
                                  ),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Payment Successful!",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Your order has been placed successfully. Thank you for shopping with us!",
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.of(
                                          context,
                                        ).pushNamedAndRemoveUntil(
                                          '/',
                                          (route) => false,
                                        );
                                      },
                                      child: const Text(
                                        "Go to Home",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            // Payment was cancelled or failed - do NOT clear cart
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Payment failed or cancelled"),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Checkout Now",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
