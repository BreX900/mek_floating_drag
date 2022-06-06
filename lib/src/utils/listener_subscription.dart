import 'package:flutter/widgets.dart';

extension ListenListenableExtension on Listenable {
  ListenerSubscription listen(void Function() listener) {
    addListener(listener);
    return ListenerSubscription(() => removeListener(listener));
  }
}

extension ListenAnimationExtension on Animation {
  ListenerSubscription listenStatus(AnimationStatusListener listener) {
    addStatusListener(listener);
    return ListenerSubscription(() => removeStatusListener(listener));
  }
}

extension ListenRemoversListExtension on List<ListenerSubscription> {
  void close() {
    for (final subscription in this) {
      subscription.close();
    }
    clear();
  }
}

class ListenerSubscription {
  final VoidCallback _onClose;

  ListenerSubscription(this._onClose);

  void close() => _onClose();

  void addTo(List<ListenerSubscription> subscriptions) {
    subscriptions.add(this);
  }
}
