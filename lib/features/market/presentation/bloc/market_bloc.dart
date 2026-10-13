import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/market_repository.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc(this._repository) : super(const MarketState()) {
    on<MarketStarted>(_onStarted);
    on<MarketRefreshed>(_onRefreshed);
    on<MarketQueryChanged>(_onQueryChanged);
    on<MarketCategorySelected>(_onCategorySelected);
    on<MarketSortRequested>(_onSortRequested);
    on<MarketWatchlistUpdated>(_onWatchlistUpdated);
  }

  final MarketRepository _repository;

  Future<void> _onStarted(MarketStarted event, Emitter<MarketState> emit) =>
      _load(emit);

  Future<void> _onRefreshed(MarketRefreshed event, Emitter<MarketState> emit) =>
      _load(emit, showLoading: false);

  void _onQueryChanged(MarketQueryChanged event, Emitter<MarketState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onCategorySelected(
    MarketCategorySelected event,
    Emitter<MarketState> emit,
  ) {
    emit(state.copyWith(categoryIndex: event.index));
  }

  /// 点同一列切换升降序，点新的一列默认降序。
  void _onSortRequested(
    MarketSortRequested event,
    Emitter<MarketState> emit,
  ) {
    if (state.sortField == event.field &&
        state.sortField != MarketSortField.none) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
      return;
    }
    emit(state.copyWith(sortField: event.field, sortAscending: false));
  }

  void _onWatchlistUpdated(
    MarketWatchlistUpdated event,
    Emitter<MarketState> emit,
  ) {
    emit(
      state.copyWith(
        watchlistSymbols:
            event.coins.map((coin) => coin.symbol).toList(growable: false),
      ),
    );
  }

  Future<void> _load(
    Emitter<MarketState> emit, {
    bool showLoading = true,
  }) async {
    if (showLoading && state.coins.isEmpty) {
      emit(state.copyWith(status: MarketStatus.loading));
    }

    final MarketResult result = await _repository.loadMarkets();
    emit(
      state.copyWith(
        status: MarketStatus.success,
        coins: result.coins,
        source: result.source,
        offline: result.offline,
        notice: result.notice,
        clearNotice: result.notice == null,
        loadCount: state.loadCount + 1,
      ),
    );
  }
}
