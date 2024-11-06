import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart'; // Import ProductPage


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
      home: const QRScanner(), // Initial route remains the same
    );
  }
}

class QRScanner extends StatefulWidget {
  final String? initialQrCode;
  final bool isCheckButton; // New parameter to indicate if opened from "Check" button

  const QRScanner({super.key, this.initialQrCode, this.isCheckButton = false});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
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

    if (widget.isCheckButton) {
      // Handle part verification
      fetchPartVerification(qrCode); // Make sure this method does not navigate anywhere else
    } else {
      // Regular product info fetch
      fetchProductInfo(qrCode); // This should lead to navigating to ProductPage
    }
  }
}


  Future<void> fetchProductInfo(String qrCode) async {
  String codeToParse = widget.isCheckButton ? qrCode : qrCode.split('-')[0]; // Use SKU ID if not from Check button
  final String apiUrl =
      'https://9blama2nbj.execute-api.ap-south-1.amazonaws.com/prod/search-products?qrData=$codeToParse';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        // Navigate to ProductPage with the product data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(
              productData: data,
            ),
          ),
        ).then((_) {
          setState(() {
            isScanning = true;
            isScanSuccessful = false;
            isLoading = false;
            boxBorderColor = Colors.white;
          });
        });
      } else {
        print('No product information found.');
      }
    } else {
      print('Failed to fetch product info. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}





Future<void> fetchPartVerification(String qrCode) async {
  final String apiUrl =
      'https://9blama2nbj.execute-api.ap-south-1.amazonaws.com/prod/search-products?qrData=$qrCode';

  bool isSuccess = false; // Track the success of the operation

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        // Show full-screen overlay for valid part verification
        await _showSuccessOverlay('Part is valid and belongs to this product');
        isSuccess = true; // Mark as success
        // After the overlay is dismissed, navigate back to ProductPage
        Navigator.of(context).pop({
          'message': 'Part is valid and belongs to this product',
        });
      } else {
        print('No product information found.');
      }
    } else {
      print('Failed to verify part. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred during part verification: $e');
  } finally {
    // Wait for 2 seconds before navigating back to ProductPage
    await Future.delayed(Duration(seconds: 1));
    if (!isSuccess) {
      // If the operation was not successful, show the failed overlay
      await _showFailedOverlay();
    }
    Navigator.of(context).pop(); // Ensure navigation back to ProductPage
  }
}

Future<void> _showSuccessOverlay(String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.green,
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 80),
                  SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text("OK", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showFailedOverlay() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.red, // Red background for failure
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 80), // Error icon
                  SizedBox(height: 20),
                  Text(
                    'Part does not belong to this product.',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text("OK", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
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
      body: Stack(
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
      bottomNavigationBar: Container(
        height: 75,
        color: Colors.black,
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
