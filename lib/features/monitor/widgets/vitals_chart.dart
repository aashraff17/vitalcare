import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class VitalsChart extends StatelessWidget {
  final String title;
  final String unit;
  final List<double> dataPoints;
  final Color lineColor;
  final double minY;
  final double maxY;
  final bool isDetailed;

  const VitalsChart({
    super.key,
    required this.title,
    required this.unit,
    required this.dataPoints,
    required this.lineColor,
    required this.minY,
    required this.maxY,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final spots = dataPoints.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final actualMin = dataPoints.reduce(min);
    final actualMax = dataPoints.reduce(max);
    final pad       = (actualMax - actualMin).clamp(1.0, double.infinity) * 0.25;
    final chartMinY = (actualMin - pad).clamp(minY, double.infinity);
    final chartMaxY = (actualMax + pad).clamp(double.negativeInfinity, maxY);
    final isTemp    = unit == '°C';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMid,
                ),
              ),
              Text(
                '${dataPoints.last.toStringAsFixed(isTemp ? 1 : 0)} $unit',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHigh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: isDetailed ? 130 : 80,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (dataPoints.length - 1).toDouble(),
                minY: chartMinY,
                maxY: chartMaxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (chartMaxY - chartMinY) / 3,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFEEF0F4),  // light gray grid on white
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: (chartMaxY - chartMinY) / 3,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(isTemp ? 1 : 0),
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: AppColors.textLow,
                        ),
                      ),
                    ),
                  ),
                  rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, index) {
                        if (index == spots.length - 1) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: lineColor,
                            strokeWidth: 1.5,
                            strokeColor: AppColors.card,
                          );
                        }
                        return FlDotCirclePainter(
                            radius: 0, color: Colors.transparent);
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withValues(alpha: 0.07),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
