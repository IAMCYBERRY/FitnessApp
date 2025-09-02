/// Rank badge widget displaying user's current rank with styling.
/// 
/// This widget creates a visually appealing rank badge that displays
/// the user's current rank (E, D, C, B, A, S, SS) with appropriate
/// colors, styling, and animations. It serves as a visual indicator
/// of the user's progress and achievement level in the RivalX system.

import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// A circular badge displaying the user's current rank
class RankBadge extends StatelessWidget {
  /// The rank to display (E, D, C, B, A, S, SS)
  final String rank;
  
  /// Size of the badge
  final double size;
  
  /// Whether to show a glow effect
  final bool showGlow;

  /// Creates a RankBadge widget
  /// 
  /// @param rank The rank string to display
  /// @param size The diameter of the badge
  /// @param showGlow Whether to show glow effect for higher ranks
  const RankBadge({
    super.key,
    required this.rank,
    this.size = 50,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = AppTheme.getRankColor(rank);
    final isHighRank = rank == 'S' || rank == 'SS';
    
    Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rankColor,
        border: Border.all(
          color: rankColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: showGlow && isHighRank
            ? [
                BoxShadow(
                  color: rankColor.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          rank,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: _getTextColor(rank),
            letterSpacing: rank == 'SS' ? -1 : 0,
          ),
        ),
      ),
    );

    // Add pulse animation for SS rank
    if (showGlow && rank == 'SS') {
      return _PulsingBadge(
        child: badge,
        color: rankColor,
      );
    }

    return badge;
  }

  /// Gets appropriate text color for the rank badge
  /// 
  /// @param rank The rank string
  /// @return Color for the text
  Color _getTextColor(String rank) {
    switch (rank) {
      case 'E':
      case 'D':
      case 'A':
        return AppTheme.textWhite;
      case 'C':
      case 'B':
      case 'S':
      case 'SS':
        return AppTheme.primaryBlack;
      default:
        return AppTheme.textWhite;
    }
  }
}

/// Animated pulsing badge for special ranks
class _PulsingBadge extends StatefulWidget {
  final Widget child;
  final Color color;

  const _PulsingBadge({
    required this.child,
    required this.color,
  });

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6 * _animation.value),
                blurRadius: 20 + (10 * _animation.value),
                spreadRadius: 4 + (2 * _animation.value),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}