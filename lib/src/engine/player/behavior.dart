import 'package:lands/src/engine/player/player.dart';
import 'package:lands/src/engine/action/action.dart';

/// What the [Player] is "doing". If the player has no behavior, he is waiting for
/// user input. Otherwise, the behavior will determine which [Action]s he
/// performs.
///
/// Behavior is coarser-grained than actions. A single behavior may produce a
/// series of actions. For example, when running, it will continue to produce
/// walk actions until disturbed.
abstract class Behavior {
  bool canPerform(Player player);
  Action getAction(Player player);
}

/// A simple one-shot behavior that performs a given [Action] and then reverts
/// back to waiting for input.
class ActionBehavior extends Behavior {
  final Action action;

  ActionBehavior(this.action);

  @override
  bool canPerform(Player player) => true;

  @override
  Action getAction(Player player) {
    player.waitForInput();
    return action;
  }
}
