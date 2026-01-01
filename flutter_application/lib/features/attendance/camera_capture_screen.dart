import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No camera found')));
            Navigator.pop(context);
        }
        return;
      }

      // Use front camera if available
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera error: $e')));
         Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() => _capturedImage = image);
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_capturedImage != null) {
        // Preview State
        return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
                children: [
                    Positioned.fill(child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover)),
                    Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                ElevatedButton.icon(
                                    onPressed: () => setState(() => _capturedImage = null),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retake'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[800],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                ),
                                ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context, _capturedImage),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Confirm'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4F46E5), // Indigo
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                ),
                            ],
                        ),
                    )
                ],
            )
        );
    }

    // Camera View
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),
          
          // Header (Close)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ),

          // Footer (Capture)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 4),
                  ),
                  child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                      ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
