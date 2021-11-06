part of 'scanner_bloc.dart';

@immutable
abstract class ScannerEvent {}

class ScannerStart extends ScannerEvent {}

class ScannerNewFrame extends ScannerEvent {
  ScannerNewFrame(this.image);
  final CameraImage image;
}
