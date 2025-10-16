import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Configuration for StatusBarTap behavior
class StatusBarTapConfig {
  /// Enable on iOS (default: true)
  final bool enableOnIOS;

  /// Enable on Android (default: false)
  final bool enableOnAndroid;

  /// Additional tap area below status bar on Android (in logical pixels)
  final double androidTapAreaHeight;

  /// Actual status bar height (required)
  /// Typically obtained with `MediaQuery.of(context).padding.top`
  final double statusBarHeight;

  /// Callback when status bar is tapped
  final VoidCallback? onTap;

  /// Scroll animation duration (default: 400ms)
  final Duration scrollDuration;

  /// Scroll animation curve (default: Curves.fastOutSlowIn)
  final Curve scrollCurve;

  /// Enable debug logging (default: false)
  final bool debug;

  /// Show visual tap area in debug mode (default: false)
  final bool debugVisual;

  /// Color for debug visual overlay (default: Colors.red.withOpacity(0.3))
  final Color debugColor;

  const StatusBarTapConfig({
    this.enableOnIOS = true,
    this.enableOnAndroid = false,
    this.androidTapAreaHeight = 20.0,
    required this.statusBarHeight,
    this.onTap,
    this.scrollDuration = const Duration(milliseconds: 400),
    this.scrollCurve = Curves.fastOutSlowIn,
    this.debug = false,
    this.debugVisual = false,
    this.debugColor = Colors.red,
  });

  bool get isEnabled {
    if (Platform.isIOS) return enableOnIOS;
    if (Platform.isAndroid) return enableOnAndroid;
    return false;
  }
}

/// Main class for handling status bar taps
class StatusBarTap {
  static final StatusBarTap _instance = StatusBarTap._internal();
  factory StatusBarTap() => _instance;
  StatusBarTap._internal();

  late StatusBarTapConfig _config;
  bool _isInitialized = false;
  bool _handlerRegistered = false;

  final List<ScrollController> _scrollControllers = [];

  /// Initialize status bar tap functionality
  void initialize({
    required StatusBarTapConfig config,
  }) {
    if (_isInitialized) {
      _debugPrint('StatusBarTap is already initialized');
      return;
    }

    _config = config;
    _isInitialized = true;

    _debugPrint('🚀 StatusBarTap initialized');
    _debugPrint('📱 Platform: ${Platform.operatingSystem}');
    _debugPrint(
        '⚙️  Config: iOS=${_config.enableOnIOS}, Android=${_config.enableOnAndroid}');
    _debugPrint('📏 Status bar height: ${_config.statusBarHeight}px');
    _debugPrint('🎯 Tap area height: ${_getTapAreaHeight()}px');
    _debugPrint(
        '⏱️  Scroll duration: ${_config.scrollDuration.inMilliseconds}ms');
    _debugPrint('📈 Scroll curve: ${_config.scrollCurve}');
    _debugPrint('🔧 Debug mode: ${_config.debug}');

    if (_config.isEnabled) {
      _setupGlobalTapHandler();
    } else {
      _debugPrint('❌ StatusBarTap disabled for this platform');
    }
  }

  /// Register a ScrollController for automatic scroll-to-top
  void registerScrollController(ScrollController controller) {
    if (!_scrollControllers.contains(controller)) {
      _scrollControllers.add(controller);
      _debugPrint(
          '📜 ScrollController registered (total: ${_scrollControllers.length})');
    }
  }

  /// Unregister a ScrollController
  void unregisterScrollController(ScrollController controller) {
    _scrollControllers.remove(controller);
    _debugPrint(
        '🗑️ ScrollController unregistered (remaining: ${_scrollControllers.length})');
  }

  void _setupGlobalTapHandler() {
    if (_handlerRegistered) return;

    try {
      GestureBinding.instance.pointerRouter
          .addGlobalRoute(_handleGlobalPointer);
      _handlerRegistered = true;
      _debugPrint('✅ Global tap handler registered');
    } catch (e) {
      _debugPrint('❌ Failed to setup global tap handler: $e');
    }
  }

  void _handleGlobalPointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      _handleTap(event.position);
    }
  }

  void _handleTap(Offset position) {
    final double tapAreaHeight = _getTapAreaHeight();
    final double tapThreshold = _config.statusBarHeight + tapAreaHeight;

    _debugPrint('👆 Tap detected at: ${position.dy.toStringAsFixed(1)}px');
    _debugPrint('   📏 Threshold: ${tapThreshold.toStringAsFixed(1)}px');

    if (position.dy <= tapThreshold) {
      _debugPrint('   🎯 Status bar area tapped');
      _scrollAllToTop();
    } else {
      _debugPrint('   ❌ Tap outside status bar area');
    }
  }

  void _scrollAllToTop() {
    _debugPrint(
        '🔼 Starting scroll to top for ${_scrollControllers.length} controller(s)');

    _config.onTap?.call();

    for (final controller in _scrollControllers) {
      if (controller.hasClients) {
        _debugPrint('   📜 Scrolling controller: hasClients=true');
        _scrollToTop(controller);
      } else {
        _debugPrint('   ⚠️  Controller has no clients');
      }
    }
  }

  void _scrollToTop(ScrollController controller) {
    controller.animateTo(
      0,
      duration: _config.scrollDuration,
      curve: _config.scrollCurve,
    );
  }

  double _getTapAreaHeight() {
    if (Platform.isAndroid) {
      return _config.androidTapAreaHeight;
    }
    return 0.0;
  }

  /// Debug print - only logs if debug is enabled
  void _debugPrint(String message) {
    if (_config.debug) {
      debugPrint('🔍 [StatusBarTap] $message');
    }
  }

  /// Wrap your scaffold with debug visualizer
  Widget wrapWithDebugVisual({required Widget child}) {
    if (!_config.debugVisual) return child;

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _config.statusBarHeight + _getTapAreaHeight(),
          child: Column(
            children: [
              // Status Bar Zone
              Container(
                height: _config.statusBarHeight,
                color: _config.debugColor.withValues(alpha: 0.4),
                child: _config.debug
                    ? Center(
                        child: Text(
                          'STATUS BAR (${_config.statusBarHeight}px)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              // Tap Area Zone (только на Android)
              if (_getTapAreaHeight() > 0)
                Container(
                  height: _getTapAreaHeight(),
                  color: _config.debugColor.withValues(alpha: 0.2),
                  child: _config.debug
                      ? Center(
                          child: Text(
                            'TAP AREA (${_getTapAreaHeight()}px)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dispose and clean up resources
  void dispose() {
    if (!_isInitialized) return;

    _debugPrint('🛑 Disposing StatusBarTap...');

    if (_handlerRegistered) {
      try {
        GestureBinding.instance.pointerRouter
            .removeGlobalRoute(_handleGlobalPointer);
        _handlerRegistered = false;
        _debugPrint('✅ Global tap handler unregistered');
      } catch (e) {
        _debugPrint('❌ Error during dispose: $e');
      }
    }

    _scrollControllers.clear();
    _isInitialized = false;

    _debugPrint('✅ StatusBarTap disposed');
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get current configuration
  StatusBarTapConfig get config => _config;
}
