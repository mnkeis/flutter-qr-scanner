part of 'scanner_bloc.dart';

@immutable
abstract class ScannerState {}

class ScannerInitial extends ScannerState {}

class ScannerScanning extends ScannerState {}

class ScannerResult extends ScannerState {
  ScannerResult(this.result);

  // Scan result
  final String? result;
}

class ScannerError extends ScannerState {
  ScannerError(this.message);

  // Error message
  final String message;
}
