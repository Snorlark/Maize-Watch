import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isOnline = results.any((result) => result != ConnectivityResult.none);
        
        if (isOnline != _isOnline) {
          setState(() {
            _isOnline = isOnline;
            _showIndicator = true;
          });
          
          // Hide indicator after 4 seconds
          _hideTimer?.cancel();
          print('🔄 ConnectivityIndicator: Connectivity changed - setting auto-hide timer for 4 seconds');
          _hideTimer = Timer(const Duration(seconds: 4), () {
            print('🔄 ConnectivityIndicator: Connectivity change auto-hide timer triggered');
            if (mounted) {
              setState(() {
                _showIndicator = false;
              });
            }
          });
        }
      },
    );
    
    // Check initial connectivity
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((result) => result != ConnectivityResult.none);
    
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
        // Only show indicator if offline, not on initial load
        _showIndicator = !isOnline;
      });
      
      // Only set timer if showing indicator (offline state)
      if (_showIndicator) {
        _hideTimer?.cancel();
        print('🔄 ConnectivityIndicator: Initial offline state - setting auto-hide timer for 4 seconds');
        _hideTimer = Timer(const Duration(seconds: 4), () {
          print('🔄 ConnectivityIndicator: Initial auto-hide timer triggered');
          if (mounted) {
            setState(() {
              _showIndicator = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        // Show toast indicator at bottom when offline or when showing persistent indicator
        if (!_isOnline || _showIndicator)
          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOnline ? Icons.wifi : Icons.wifi_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isOnline ? 'Back Online' : 'Offline Mode - Cached Data',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showIndicator = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
