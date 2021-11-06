import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:meta/meta.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc([this._type = BarcodeType.text]) : super(ScannerInitial());

  final _barcodeDetector = GoogleMlKit.vision.barcodeScanner([
    BarcodeFormat.qrCode,
  ]);

  CameraController? cameraController;
  bool _scanning = false;
  final BarcodeType _type;
  late final CameraDescription camera;

  @override
  Stream<ScannerState> mapEventToState(
    ScannerEvent event,
  ) async* {
    if (event is ScannerStart) {
      yield* _mapScannerStartedToState();
    } else if (event is ScannerNewFrame) {
      yield* _mapScannerNewFrameToState(event.image);
    }
  }

  @override
  Future<void> close() {
    cameraController?.dispose();
    return super.close();
  }

  Stream<ScannerState> _mapScannerStartedToState() async* {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      // If no camera availdable, yields error
      yield ScannerError('No camera available');
    }
    camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras[0],
    );

    cameraController = CameraController(camera, ResolutionPreset.low);
    await cameraController!.initialize();
    await cameraController!.startImageStream((frame) {
      if (_scanning) {
        return;
      }
      _scanning = true;
      add(ScannerNewFrame(frame));
    });
    yield ScannerScanning();
  }

  Stream<ScannerState> _mapScannerNewFrameToState(CameraImage image) async* {
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final barcodes = await _barcodeDetector.processImage(
      InputImage.fromBytes(
        bytes: allBytes.done().buffer.asUint8List(),
        inputImageData: InputImageData(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          planeData: image.planes.map(
            (plane) {
              return InputImagePlaneMetadata(
                bytesPerRow: plane.bytesPerRow,
                height: plane.height,
                width: plane.width,
              );
            },
          ).toList(),
          imageRotation: InputImageRotationMethods.fromRawValue(
                  camera.sensorOrientation) ??
              InputImageRotation.Rotation_0deg,
          inputImageFormat:
              InputImageFormatMethods.fromRawValue(image.format.raw as int) ??
                  InputImageFormat.BGRA8888,
        ),
      ),
    );
    for (final barcode in barcodes) {
      if (barcode.type == _type) {
        await cameraController!.stopImageStream();
        yield ScannerResult(barcode.value.rawValue);
      }
    }
    _scanning = false;
  }
}
