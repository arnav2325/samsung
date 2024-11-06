import 'package:flutter/material.dart';
import 'scanner.dart'; // Import your scanner.dart file here
import 'scanner2.dart'; // Import scanner2.dart file here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samsung Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a list of icons and labels for each grid box
    final List<IconData> icons = [
      Icons.tv,
      Icons.phone_android,
      Icons.laptop,
      Icons.watch,
      Icons.headset, // Headphones icon
      Icons.kitchen, // Refrigerator icon
      Icons.more_horiz, // Three dots icon for more devices
      Icons.settings, // Gear icon for "Parts"
      Icons.more_horiz, // Another three dots icon for the last grid box
    ];

    final List<String> labels = [
      'Television',
      'Smartphone',
      'Laptop',
      'Smartwatch',
      'Headphone', // Headphone text
      'Refrigerator', // Changed to "Refrigerator"
      '', // Empty label for the three dots icon
      'Parts', // Label for the new device
      '', // Label for the new device
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://images.samsung.com/is/image/samsung/assets/global/about-us/brand/logo/300_186_4.png?568_N_PNG',
                  height: 70,
                  fit: BoxFit.contain,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Authenticate your devices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ],
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20), // Space between AppBar and Devices heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center( // Center the Devices heading
              child: Text(
                'Devices',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // Reduced space before the grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // First row of grid items
                  GridView.builder(
                    itemCount: 3, // First row has 3 items
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns
                      crossAxisSpacing: 15, // Space between columns
                      mainAxisSpacing: 15, // Space between rows
                    ),
                    itemBuilder: (context, index) {
                      return _GridItem(
                        index: index,
                        icon: icons[index],
                        label: labels[index],
                      );
                    },
                  ),
                  const SizedBox(height: 10), // Space before the new row
                  // New row of grid items
                  GridView.builder(
                    itemCount: 3, // New row has 3 items
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns
                      crossAxisSpacing: 15, // Space between columns
                      mainAxisSpacing: 15, // Space between rows
                    ),
                    itemBuilder: (context, index) {
                      return _GridItem(
                        index: index + 3, // Adjust index for the new row
                        icon: icons[index + 3],
                        label: labels[index + 3],
                      );
                    },
                  ),
                  const SizedBox(height: 30), // Space before the heading
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0), // Align heading to the left
                    child: Text(
                      'Authenticate Parts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Space before the second row
                  // Second row of grid items
                  GridView.builder(
                    itemCount: 3, // Second row has 3 items
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns
                      crossAxisSpacing: 15, // Space between columns
                      mainAxisSpacing: 15, // Space between rows
                    ),
                    itemBuilder: (context, index) {
                      return _GridItem(
                        index: index + 6, // Adjust index for the second row
                        icon: icons[index + 6],
                        label: labels[index + 6],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 75, // Set a fixed height for the footer
        color: Colors.black, // Black background for footer
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Image.network(
            'https://images.samsung.com/is/image/samsung/assets/global/about-us/brand/logo/300_186_4.png?568_N_PNG',
            height: 100,
            width: 100,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _GridItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;

  const _GridItem({
    Key? key,
    required this.index,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  __GridItemState createState() => __GridItemState();
}

class __GridItemState extends State<_GridItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHighlighted = false; // Track if the item is highlighted

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(_controller); // Reduced zoom-in size
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Start the animation
        _controller.forward().then((_) {
          // Check if it's the Television or Parts item
          if (widget.index == 0) { // Television item
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScanner()),
            ).then((_) {
              // Reset highlight when navigating back
              setState(() {
                _isHighlighted = false;
              });
            });
          } else if (widget.index == 7) { // Parts item
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRpart()),
            ).then((_) {
              setState(() {
                _isHighlighted = false;
              });
            });
          }
          // Reset animation
          _controller.reverse();
        });

        // Set highlight state for shadow effect
        if (widget.index == 0 || widget.index == 7) {
          setState(() {
            _isHighlighted = true;
          });
        }
      },
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300], // Set a greyish background color
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHighlighted
                ? [
                    const BoxShadow(
                      color: Colors.black54, // Shadow color
                      blurRadius: 8,
                      spreadRadius: 3,
                      offset: Offset(0, 0), // Shadow position
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon, // Display unique icon for each grid box
                size: 48,
                color: Colors.black, // Icon color
              ),
              const SizedBox(height: 10),
              Text(
                widget.label, // Display unique label for each grid box
                style: const TextStyle(
                  color: Colors.black, // Change label color to black
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
