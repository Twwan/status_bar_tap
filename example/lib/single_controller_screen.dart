import 'dart:io';

import 'package:flutter/material.dart';
import 'package:status_bar_tap/status_bar_tap.dart';

/// Demonstrates single ScrollController management with StatusBarTap
class SingleControllerScreen extends StatefulWidget {
  const SingleControllerScreen({super.key});

  @override
  State<SingleControllerScreen> createState() => _SingleControllerScreenState();
}

class _SingleControllerScreenState extends State<SingleControllerScreen> {
  final ScrollController _scrollController = ScrollController();
  int _tapCount = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLibrary();
  }

  /// Initialize StatusBarTap and register controller
  void _initializeLibrary() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double statusBarHeight = MediaQuery.of(context).padding.top;

      StatusBarTap().initialize(
        config: StatusBarTapConfig(
          enableOnIOS: true,
          enableOnAndroid: true,
          statusBarHeight: statusBarHeight,
          androidTapAreaHeight: 20,
          debug: true,
          debugVisual: true,
          onTap: _incrementTapCount,
        ),
      );

      StatusBarTap().registerScrollController(_scrollController);

      setState(() {
        _isInitialized = true;
      });
    });
  }

  /// Callback method triggered when status bar is tapped
  void _incrementTapCount() {
    setState(() {
      _tapCount++;
    });
  }

  /// Handles navigation back to start screen
  void _goBack() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    /// Clean up library resources and scroll controllers
    ///
    /// Important: Always call this method when the widget is disposed
    /// to prevent memory leaks and ensure clean library shutdown
    StatusBarTap().unregisterScrollController(_scrollController);
    StatusBarTap().dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;
    final bool isAndroid = Platform.isAndroid;

    return StatusBarTap().wrapWithDebugVisual(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Single List Demo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
            tooltip: 'Go back to test dispose',
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue[50],
              child: _isInitialized
                  ? Column(
                      children: [
                        Text(
                          'Status bar taps: $_tapCount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Platform: ${isIOS ? 'iOS' : isAndroid ? 'Android' : 'Unknown'}\n'
                          'Android tap area: ${StatusBarTap().config.androidTapAreaHeight}px\n',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    )
                  : const Center(child: Text('Library not initialized')),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: isIOS
                    ? const BouncingScrollPhysics()
                    : const ClampingScrollPhysics(),
                itemCount: 50,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('List Item ${index + 1}'),
                      subtitle: Text(isIOS
                          ? 'Tap status bar to scroll to top ↑'
                          : 'Tap top area to scroll to top ↑'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
