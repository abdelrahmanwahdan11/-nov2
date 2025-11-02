import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Signal<T> extends ValueNotifier<T> {
  Signal(super.value);

  final StreamController<T> _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  void emit(T newValue) {
    value = newValue;
  }

  @override
  set value(T newValue) {
    if (newValue == super.value) {
      return;
    }
    super.value = newValue;
    _controller.add(newValue);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

class SignalBuilder<T> extends StatelessWidget {
  const SignalBuilder({
    super.key,
    required this.signal,
    required this.builder,
  });

  final Signal<T> signal;
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: signal,
      builder: builder,
    );
  }
}
