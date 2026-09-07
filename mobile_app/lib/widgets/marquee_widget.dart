import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Duration backDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 10000),
    this.backDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll() async {
    while (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent > 0) {
          await _scrollController.animateTo(
            maxExtent,
            duration: widget.animationDuration,
            curve: Curves.linear,
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          if (_scrollController.hasClients) {
            await _scrollController.animateTo(
              0.0,
              duration: widget.backDuration,
              curve: Curves.easeOut,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: widget.child,
    );
  }
}
