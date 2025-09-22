import 'package:flutter/material.dart';
import 'dart:async';

class ConnectivityIndicator extends StatefulWidget {
  final Widget child;
  
  const ConnectivityIndicator({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  late StreamSubscription _connectivitySubscription;
  bool _isOnline = true;
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  void _initConnectivity() {
    // For now, assume online and don't show indicator
    // This avoids the connectivity plugin issues
    setState(() {
      _isOnline = true;
      _showIndicator = false;
    });
    
    // Create a dummy subscription to avoid null reference errors
    _connectivitySubscription = Stream.empty().listen((_) {});
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_showIndicator)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _isOnline ? Colors.green : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnline ? 'Back Online' : 'You\'re Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
