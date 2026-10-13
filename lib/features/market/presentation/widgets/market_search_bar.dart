import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';

/// 顶部搜索框，提示文案是当前涨幅最高的币种。
class MarketSearchBar extends StatefulWidget {
  const MarketSearchBar({super.key});

  @override
  State<MarketSearchBar> createState() => _MarketSearchBarState();
}

class _MarketSearchBarState extends State<MarketSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 有内容时才显示清除按钮。
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.badge,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BlocBuilder<MarketBloc, MarketState>(
                buildWhen: (MarketState previous, MarketState current) =>
                    previous.hotHint != current.hotHint,
                builder: (BuildContext context, MarketState state) {
                  return TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.up,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '🔥 ${state.hotHint}',
                      hintStyle: const TextStyle(
                        fontSize: 15.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: (String value) =>
                        context.read<MarketBloc>().add(MarketQueryChanged(value)),
                  );
                },
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  _controller.clear();
                  context.read<MarketBloc>().add(const MarketQueryChanged(''));
                },
                icon: const Icon(
                  Icons.cancel,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
