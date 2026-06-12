import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final bool showPersistentIndicator;
  
  const OfflineIndicator({
    Key? key,
    required this.child,
    this.showPersistentIndicator = false,
  }) : super(key: key);

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
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
          
          // If coming back online, test API connectivity
          if (isOnline) {
            _testApiConnectivity();
          }
          
          // Always set auto-hide timer when connectivity changes
          _hideTimer?.cancel();
          print('🔄 OfflineIndicator: Connectivity changed - setting auto-hide timer for 4 seconds');
          _hideTimer = Timer(const Duration(seconds: 4), () {
            print('🔄 OfflineIndicator: Connectivity change auto-hide timer triggered');
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

  Future<void> _testApiConnectivity() async {
    // For now, just assume API is working if network is available
    // In a real implementation, you could make a simple API call here
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isOnline = true;
        // Don't hide indicator here - let the auto-hide timer handle it
        // _showIndicator = false;
      });
    }
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((result) => result != ConnectivityResult.none);
    
    print('🔄 OfflineIndicator: Initial connectivity check - isOnline: $isOnline, showPersistentIndicator: ${widget.showPersistentIndicator}');
    
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
        // Show indicator if offline or if showPersistentIndicator is true
        _showIndicator = !isOnline || widget.showPersistentIndicator;
      });
      
      print('🔄 OfflineIndicator: Initial state - _showIndicator: $_showIndicator');
      
      // Set timer if showing indicator
      if (_showIndicator) {
        _hideTimer?.cancel();
        print('🔄 OfflineIndicator: Initial state - setting auto-hide timer for 4 seconds');
        _hideTimer = Timer(const Duration(seconds: 4), () {
          print('🔄 OfflineIndicator: Initial auto-hide timer triggered');
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
    print('🔄 OfflineIndicator: Building - _isOnline: $_isOnline, _showIndicator: $_showIndicator');
    
    return Stack(
      children: [
        widget.child,
        // Show toast indicator at bottom when offline or when showing persistent indicator
        if (!_isOnline || _showIndicator)
          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
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
      ],
    );
  }
}

class SmallOfflineIndicator extends StatelessWidget {
  const SmallOfflineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: [ConnectivityResult.none],
      builder: (context, snapshot) {
        final results = snapshot.data ?? [ConnectivityResult.none];
        final isOnline = results.any((result) => result != ConnectivityResult.none);
        
        if (isOnline) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 4),
              const Text(
                'Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
