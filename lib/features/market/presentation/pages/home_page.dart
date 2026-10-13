import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/market_config.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../widgets/market_search_bar.dart';
import '../widgets/market_tab_bar.dart';
import 'leaderboard_view.dart';
import 'market_view.dart';
import 'news_view.dart';

/// 首页外壳：搜索框 + 一级 Tab。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocProvider<MarketBloc>(
          create: (BuildContext context) =>
              getIt<MarketBloc>()..add(const MarketStarted()),
          child: Column(
            children: <Widget>[
              const MarketSearchBar(),
              MarketTabBar(
                tabs: MarketConfig.tabs,
                currentIndex: _tabIndex,
                onSelected: (int index) => setState(() => _tabIndex = index),
              ),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: const <Widget>[
                    MarketView(),
                    NewsView(),
                    LeaderboardView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
