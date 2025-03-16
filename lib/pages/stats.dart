import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../pages.dart';
import '../saves.dart';

class Stats extends PageContent {
  const Stats({super.key});

  @override
  String title() { return "Statistics"; }

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  List<int> indexes = [0, 1, 2, 3, 4, 5, 6];
  List<String> titles = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];

  @override
  Widget build(BuildContext context) {
    List<double> weekPages = indexes
        .map((int weekday) => statsData.readingUpdates
            .where((ReadingUpdate update) => (update.timestamp.weekday == weekday + 1 && (update.timestamp.day - DateTime.now().day).abs() < 7))
            .map((ReadingUpdate update) => update.pages)
            .followedBy([0])
            .reduce((int a, int b) => a + b)
            .toDouble())
        .toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 96.0,),
          Text(
            widget.title(),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w400,
              fontSize: 32.0,
            ),
          ),
          const SizedBox(height: 24.0,),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              border: Border.fromBorderSide(BorderSide(
                color: Theme.of(context).colorScheme.inversePrimary,
              )),
            ),
            height: 256.0,
            child: BarChart(
              BarChartData(
                minY: -weekPages.reduce((double a, double b) => max(a, b)) * 0.05,
                maxY: weekPages.reduce((double a, double b) => max(a, b)) * 1.15,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.inversePrimary))),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.0,
                      getTitlesWidget: (double axisValue, TitleMeta meta) {
                        return Container(
                          padding: const EdgeInsets.only(top: 8.0,),
                          child: Text(titles[axisValue.toInt()], style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,),),
                        );
                      }
                    )
                  )
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 0.0,
                    tooltipPadding: EdgeInsets.zero,
                    getTooltipColor: (_) => Colors.transparent,
                    getTooltipItem: (BarChartGroupData groupData, int a, BarChartRodData rodData, int b) {
                      return BarTooltipItem(rodData.toY.toInt().toString(), TextStyle(
                          color: Theme.of(context).colorScheme.primary));
                    }
                  ),
                ),
                barGroups: indexes.map((int index) => BarChartGroupData(
                  x: index,
                  barRods: [BarChartRodData(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color.lerp(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondaryContainer, 0.95)!,
                        Theme.of(context).colorScheme.inversePrimary,
                      ]
                    ),
                    width: 16.0,
                    toY: weekPages[index],
                  )],
                  showingTooltipIndicators: weekPages[index] > 0 ? [0] : [],
                )).toList()
              )
            ),
          ),
          const SizedBox(height: 24.0,),
          Text(
            statsData.toJson().toString(),
            style: const TextStyle(fontSize: 8.0),
          ),
        ]
      )
    );
  }
}