import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'chatbot.dart';
import 'scanner.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductPage({Key? key, required this.productData}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<bool> verificationStatus;

  @override
  void initState() {
    super.initState();
    verificationStatus = List<bool>.filled(widget.productData['titles'].length, false);
  }

  Future<void> handleProductCheck(int index) async {
    final scannedResponse = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanner(isCheckButton: true),
      ),
    );

    if (scannedResponse != null && scannedResponse['message'] == "Part is valid and belongs to this product") {
      List<String> validParts = List<String>.from(scannedResponse['part']);
      String scannedSKU = scannedResponse['scannedSKU'];

      if (validParts.contains(scannedSKU)) {
        setState(() {
          verificationStatus[index] = true; // Update verification status for the product
        });
      }
    }
  }

  Widget buildEndDrawer() {
    final List<String> productTitles = List<String>.from(widget.productData['titles'] ?? []);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authenticate parts',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                if (verificationStatus.any((status) => status)) // Check if any part is verified
                  Text(
                    'Done', // Temporary heading to indicate update
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
              ],
            ),
          ),
          for (int i = 0; i < productTitles.length; i++)
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(productTitles[i]),
                  verificationStatus[i]
                      ? Icon(Icons.check_circle, color: Colors.green) // Green checkmark icon
                      : ElevatedButton(
                          onPressed: () async {
                            await handleProductCheck(i);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(60, 30),
                            backgroundColor: Colors.black,
                          ),
                          child: Text(
                            "Check",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                ],
              ),
              leading: Icon(Icons.settings),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData['product'];
    final List<String> imgList = List<String>.from(product?['images'] ?? []);
    final List<Map<String, String>> videoList = List<Map<String, String>>.from(
      product?['videos'].map((link) => {
        'videoId': YoutubePlayer.convertUrlToId(link) ?? '',
        'description': 'Watch video'
      }) ?? [],
    );

    final String aboutProduct = product?['aboutProduct'] ?? 'No about product information available';
    final String productName = (product?['ProductCombined'] != null && product!['ProductCombined'].isNotEmpty)
        ? product['ProductCombined'][0]
        : 'Unknown Product';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Image.network(
                'https://images.samsung.com/is/image/samsung/assets/global/about-us/brand/logo/300_186_4.png?568_N_PNG',
                height: 70,
                fit: BoxFit.contain,
              ),
        ),
      ),
      endDrawer: buildEndDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 300,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.8,
                          ),
                          items: imgList.map((item) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: Image.network(
                              item,
                              fit: BoxFit.cover,
                              height: 300,
                              width: double.infinity,
                            ),
                          )).toList(),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            productName,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        ExpansionTile(
                          title: Text(
                            "About Product",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'About: $aboutProduct',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text(
                            "Product Videos",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          children: videoList.map((video) {
                            final YoutubePlayerController _controller = YoutubePlayerController(
                              initialVideoId: video['videoId']!,
                              flags: YoutubePlayerFlags(
                                autoPlay: false,
                                mute: false,
                              ),
                            );

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: YoutubePlayer(
                                      controller: _controller,
                                      showVideoProgressIndicator: true,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    video['description']!,
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
              Footer(),
            ],
          ),
          Positioned(
            left: 20, // Shift to the extreme left
            bottom: 100,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  // Open the end drawer using a Builder to get the correct context
                  Scaffold.of(context).openEndDrawer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Background color
                ),
                child: Text(
                  'Authenticate Part',
                  style: TextStyle(color: Colors.white), // Text color
                ),
              ),
            ),
          ),
          Positioned(
            right: 20, // Shift to the extreme right
            bottom: 100,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotPage()),
                );
              },
              child: Icon(Icons.chat, color: Colors.white), // Chatbot icon
            ),
          ),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(
                'https://images.samsung.com/is/image/samsung/assets/global/about-us/brand/logo/300_186_4.png?568_N_PNG',
                height: 50,
                fit: BoxFit.contain,
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RatingDialog();
                    },
                  );
                },
                child: Text(
                  "Rate this Product",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            '© 2024 Samsung Electronics Co.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class RatingDialog extends StatefulWidget {
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0; // Holds the current rating

  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        index < _rating ? Icons.star : Icons.star_border,
        color: Colors.black,
      ),
      onPressed: () {
        setState(() {
          _rating = index + 1; // Update the rating when a star is tapped
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rate this Product"),
      content: SingleChildScrollView(
        child: Container( // Wrap Row with Container
          constraints: BoxConstraints(maxWidth: 300), // Set a max width
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => buildStar(index)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // Handle the rating submission logic here, if any
            Navigator.of(context).pop();
          },
          child: Text("Submit"),
        ),
      ],
    );
  }
}
