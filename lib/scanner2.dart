import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samsung',
      debugShowCheckedModeBanner: false,
      home: QRpart(), // Initial route remains the same
    );
  }
}

class QRpart extends StatefulWidget {
  @override
  State<QRpart> createState() => _QRpartState();
}

class _QRpartState extends State<QRpart> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanning = true;
  bool isScanSuccessful = false;
  bool isLoading = false;
  Color boxBorderColor = Colors.white;
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onScanSuccess(String qrCode) {
    if (isScanning) {
      setState(() {
        isScanning = false;
        isScanSuccessful = true;
        isLoading = true;
        boxBorderColor = Colors.lightGreen;
      });

      // Extract the SKU ID (first part before the dash)
      String skuId = qrCode.split('-')[0]; // Only take the part before the first dash

      // Call the function to fetch part info with the SKU ID
      fetchPartInfo(skuId);
    }
  }

  Future<void> fetchPartInfo(String skuId) async {
    final String apiUrl = 'https://9blama2nbj.execute-api.ap-south-1.amazonaws.com/prod/search-products?qrData=$skuId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Debug: Log the API response
        print('API Response: $data');

        // Show success overlay
        successOverlay();
      } else {
        // Handle error response
        print('Failed to load part info: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      print('Error occurred: $e');
    } finally {
      // Update the loading state once the fetch is complete
      setState(() {
        isLoading = false;
      });
    }
  }

 void successOverlay() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.green, // Set the background color to green
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Container(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'Part is real',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center align the text
              ),
              const Spacer(), // Pushes the OK button to the bottom
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(), // Navigate to the LandingPage
                      ),
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isScanSuccessful ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              'https://images.samsung.com/is/image/samsung/assets/global/about-us/brand/logo/300_186_4.png?568_N_PNG',
              height: 60,
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
                controller.toggleTorch();
              });
            },
          ),
          IconButton(
            icon: Icon(
              isFrontCamera ? Icons.camera_front : Icons.camera_rear,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFrontCamera = !isFrontCamera;
                controller.switchCamera();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded( // Allow the scanning area to take available space
              child: Stack(
                children: [
                  if (!isScanSuccessful)
                    MobileScanner(
                      controller: controller,
                      onDetect: (BarcodeCapture capture) {
                        for (final barcode in capture.barcodes) {
                          if (barcode.rawValue != null) {
                            _onScanSuccess(barcode.rawValue!);
                            return;
                          }
                        }
                      },
                    ),
                  if (isScanSuccessful)
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: isLoading
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 5,
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Scan the QR Code",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: isScanSuccessful ? boxBorderColor.withOpacity(0.3) : Colors.transparent,
                            border: Border.all(color: boxBorderColor, width: 6),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isScanSuccessful
                                ? [
                                    BoxShadow(
                                      color: Colors.lightGreenAccent.withOpacity(0.7),
                                      spreadRadius: 10,
                                      blurRadius: 20,
                                      offset: Offset(0, 0),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar removed to prevent overflow
    );
  }
}
