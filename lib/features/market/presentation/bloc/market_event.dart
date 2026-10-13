import 'package:equatable/equatable.dart';

import '../../domain/entities/coin.dart';
import 'market_state.dart';

sealed class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class MarketStarted extends MarketEvent {
  const MarketStarted();
}

final class MarketRefreshed extends MarketEvent {
  const MarketRefreshed();
}

final class MarketQueryChanged extends MarketEvent {
  const MarketQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class MarketCategorySelected extends MarketEvent {
  const MarketCategorySelected(this.index);

  final int index;

  @override
  List<Object?> get props => <Object?>[index];
}

final class MarketSortRequested extends MarketEvent {
  const MarketSortRequested(this.field);

  final MarketSortField field;

  @override
  List<Object?> get props => <Object?>[field];
}

/// 自选列表变更（添加或移除币对）。
final class MarketWatchlistUpdated extends MarketEvent {
  const MarketWatchlistUpdated(this.coins);

  final List<Coin> coins;

  @override
  List<Object?> get props => coins;
}
