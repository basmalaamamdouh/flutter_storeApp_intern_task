import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'details_screen.dart'; // Make sure this path is correct

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use a more specific type for the future
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("https://dummyjson.com/products"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['products'];
      } else {
        // Handle server errors or non-200 status codes
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error fetching products: $e'); // For debugging
      throw Exception('Failed to connect to the server. Please check your internet connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a primary color consistent with your onboarding/splash screen
    const Color primaryPurple = Color(0xFF5D3FD3); // From your splash/onboarding

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Store App", // More thematic title
          style: TextStyle(
            color: Colors.white, // White text for AppBar title
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
        backgroundColor: primaryPurple, // Use your app's primary color
        elevation: 0, // No shadow under AppBar
        // You can add leading/trailing icons here if needed, e.g., search or cart
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search, color: Colors.white),
        //     onPressed: () { /* TODO: Implement search */ },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.shopping_cart, color: Colors.white),
        //     onPressed: () { /* TODO: Implement cart */ },
        //   ),
        // ],
      ),
      body: FutureBuilder<List<dynamic>>( // Specify the type for FutureBuilder
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryPurple));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.error.toString(), // Display the actual error message
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Trigger a re-fetch of data
                          // This will rebuild the FutureBuilder and re-execute fetchProducts()
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            List<dynamic> products = snapshot.data!; // Explicitly type products
            return GridView.builder(
              padding: const EdgeInsets.all(12), // Slightly more padding
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjust aspect ratio for better card fit
                crossAxisSpacing: 12, // More spacing
                mainAxisSpacing: 12, // More spacing
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                // Check if product data is valid before accessing
                if (product == null || product['id'] == null) {
                  return const SizedBox.shrink(); // Hide invalid product entries
                }
                return GestureDetector(
                  onTap: () {
                    // Navigate to details screen, passing the product map
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsScreen(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4, // Slightly higher elevation for a nicer shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // Rounded corners for cards
                    ),
                    clipBehavior: Clip.antiAlias, // Ensures image respects rounded corners
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Expanded( // Use Expanded to give image flexible height within card
                          child: product['thumbnail'] != null
                              ? Image.network(
                            product['thumbnail'],
                            height: double.infinity, // Take available height
                            width: double.infinity, // Take available width
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: primaryPurple,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              );
                            },
                          )
                              : const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),
                        // Product Details
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'] ?? 'No Title', // Provide default
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2, // Limit title to 2 lines
                                overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${product['price']?.toStringAsFixed(2) ?? 'N/A'}", // Format price
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: primaryPurple, // Highlight price
                                    ),
                                  ),
                                  if (product['rating'] != null) // Display rating if available
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(
                                          product['rating'].toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 14),
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
                  ),
                );
              },
            );
          } else {
            // This case should ideally not be reached if connectionState is handled
            return const Center(child: Text("No products available."));
          }
        },
      ),
    );
  }
}