import 'dart:io';

import 'package:flutter/material.dart';
import 'package:status_bar_tap/status_bar_tap.dart';

/// Demonstrates multiple ScrollController management with StatusBarTap
class MultipleControllersScreen extends StatefulWidget {
  const MultipleControllersScreen({super.key});

  @override
  State<MultipleControllersScreen> createState() =>
      _MultipleControllersScreenState();
}

class _MultipleControllersScreenState extends State<MultipleControllersScreen> {
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();
  final List<bool> _controllerActive = [true, true];
  final List<bool> _scrollOnTap = [true, true];
  int _tapCount = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLibrary();
  }

  /// Initialize StatusBarTap and register controllers
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

      if (_scrollOnTap[0]) {
        StatusBarTap().registerScrollController(_leftController);
      }
      if (_scrollOnTap[1]) {
        StatusBarTap().registerScrollController(_rightController);
      }

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

  void _toggleLeftController(bool enabled) {
    setState(() {
      _controllerActive[0] = enabled;
    });
  }

  void _toggleRightController(bool enabled) {
    setState(() {
      _controllerActive[1] = enabled;
    });
  }

  /// Toggle controller registration in StatusBarTap library
  ///
  /// When enabled: controller will scroll to top on status bar tap
  /// When disabled: controller remains active but ignores status bar taps
  void _toggleScrollOnTap(int index, bool enabled) {
    setState(() {
      _scrollOnTap[index] = enabled;
      if (enabled) {
        if (index == 0) {
          StatusBarTap().registerScrollController(_leftController);
        } else {
          StatusBarTap().registerScrollController(_rightController);
        }
      } else {
        if (index == 0) {
          StatusBarTap().unregisterScrollController(_leftController);
        } else {
          StatusBarTap().unregisterScrollController(_rightController);
        }
      }
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    StatusBarTap().unregisterScrollController(_leftController);
    StatusBarTap().unregisterScrollController(_rightController);
    StatusBarTap().dispose();
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarTap().wrapWithDebugVisual(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Split View Demo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
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
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Active panels: ${_controllerActive.where((a) => a).length}/2',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControllerSwitch(0, 'Show Left'),
                            _buildControllerSwitch(1, 'Show Right'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildScrollToggle(0, 'Left scroll on tap'),
                            _buildScrollToggle(1, 'Right scroll on tap'),
                          ],
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildLeftPanel()),
                  Container(width: 1, color: Colors.grey[300]),
                  Expanded(child: _buildRightPanel()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControllerSwitch(int index, String label) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 4),
        Switch(
          value: _controllerActive[index],
          onChanged: (value) {
            if (index == 0) {
              _toggleLeftController(value);
            } else {
              _toggleRightController(value);
            }
          },
          activeThumbColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildScrollToggle(int index, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _scrollOnTap[index],
          onChanged: (value) => _toggleScrollOnTap(index, value ?? false),
          activeColor: Colors.blue,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text('CATEGORIES',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    _controllerActive[0]
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: _controllerActive[0] ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _scrollOnTap[0]
                        ? Icons.touch_app
                        : Icons.touch_app_outlined,
                    color: _scrollOnTap[0] ? Colors.blue : Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _controllerActive[0]
              ? ListView.builder(
                  controller: _leftController,
                  physics: Platform.isIOS
                      ? const BouncingScrollPhysics()
                      : const ClampingScrollPhysics(),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text('${index + 1}')),
                        title: Text('Category ${index + 1}'),
                        subtitle: Text(
                            'Tap scroll: ${_scrollOnTap[0] ? "ON" : "OFF"}'),
                      ),
                    );
                  },
                )
              : _buildDisabledPanel('Left Disabled'),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text('CONTENT',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    _controllerActive[1]
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: _controllerActive[1] ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _scrollOnTap[1]
                        ? Icons.touch_app
                        : Icons.touch_app_outlined,
                    color: _scrollOnTap[1] ? Colors.blue : Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _controllerActive[1]
              ? ListView.builder(
                  controller: _rightController,
                  physics: Platform.isIOS
                      ? const BouncingScrollPhysics()
                      : const ClampingScrollPhysics(),
                  itemCount: 50,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text('${index + 1}')),
                        title: Text('Item ${index + 1}'),
                        subtitle: Text(
                            'Tap scroll: ${_scrollOnTap[1] ? "ON" : "OFF"}'),
                      ),
                    );
                  },
                )
              : _buildDisabledPanel('Right Disabled'),
        ),
      ],
    );
  }

  Widget _buildDisabledPanel(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.block, size: 48, color: Colors.grey),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
