import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/scanner_bloc.dart';

class QrScanner extends StatelessWidget {
  const QrScanner({
    required this.onResult,
    this.title,
    Key? key,
  }) : super(key: key);

  final String? title;
  final Function(String) onResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocProvider(
        create: (context) => ScannerBloc()..add(ScannerStart()),
        child: BlocConsumer<ScannerBloc, ScannerState>(
          listener: (context, state) {
            if (state is ScannerResult) {
              final result = state.result;
              if (result != null) {
                onResult(result);
              }
              // context.read<ScannerBloc>().add(ScannerStart());
            }
          },
          builder: (context, state) {
            if (state is ScannerScanning) {
              final height = MediaQuery.of(context).size.height * 0.5;
              final width = MediaQuery.of(context).size.width * 0.7;
              return Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                    SizedBox(
                      height: height,
                      width: width,
                      child: Stack(
                        children: [
                          context
                              .watch<ScannerBloc>()
                              .cameraController!
                              .buildPreview(),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: width / 6,
                              vertical: height / 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
