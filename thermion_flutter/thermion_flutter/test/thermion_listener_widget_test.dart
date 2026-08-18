import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thermion_dart/thermion_dart.dart';
import 'package:thermion_flutter/src/widgets/src/thermion_listener_widget.dart';

class _RecordingInputHandler implements InputHandler {
  final events = <InputEvent>[];

  @override
  void handle(InputEvent event) {
    events.add(event);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  testWidgets(
    'claims scroll signals inside a nested scroll view',
    (tester) async {
      final inputHandler = _RecordingInputHandler();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              height: 1000,
              child: ThermionListenerWidget(
                inputHandler: inputHandler,
                child: const SizedBox(height: 200),
              ),
            ),
          ),
        ),
      );

      tester.sendEventToBinding(
        const PointerScrollEvent(
          position: Offset(40, 40),
          scrollDelta: Offset(0, 16),
        ),
      );
      await tester.pump();

      expect(inputHandler.events, hasLength(1));
      final event = inputHandler.events.single as ScrollEvent;
      expect(event.localPosition.x, 40);
      expect(event.localPosition.y, 40);
      expect(event.delta, 16);
      expect(scrollController.offset, 0);

      scrollController.dispose();
    },
  );
}
