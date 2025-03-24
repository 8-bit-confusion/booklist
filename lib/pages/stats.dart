import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../pages.dart';
import '../saves.dart';
import '../settings_launcher.dart';

class Stats extends PageContent {
  const Stats({super.key});

  @override
  String title() { return "Statistics"; }

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  bool sameWeek(DateTime a, DateTime b) {
    DateTime d1 = a.subtract(Duration(days: a.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    DateTime d2 = b.subtract(Duration(days: b.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    return d1.compareTo(d2) == 0;
  }

  bool sameMonth(DateTime a, DateTime b) {
    return a.month == b.month && a.year == b.year;
  }

  @override
  Widget build(BuildContext context) {
    List<int> indexes = List<int>.generate(SettingsData.spanTitles[settingsData.timeSpan]!.length, (i) => i);
    List<double> barHeights = indexes
        .map((int index) => statsData.readingUpdates
            .where(
              settingsData.timeSpan == TimeSpan.week  ? (ReadingUpdate update) => (update.timestamp.weekday == index + 1 && sameWeek(update.timestamp, DateTime.now())) :
              settingsData.timeSpan == TimeSpan.month ? (ReadingUpdate update) => (update.timestamp.day == index + 1 && sameMonth(update.timestamp, DateTime.now())) :
              (ReadingUpdate update) => (update.timestamp.month == index + 1 && update.timestamp.year == DateTime.now().year)
            )
            .map((ReadingUpdate update) => update.pages)
            .followedBy([0])
            .reduce((int a, int b) => a + b)
            .toDouble())
        .toList();

    return SettingsLauncher(
      body: Scaffold(
        body: Container(
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
              Row(
                children: <Widget>[
                  Text("Pages read this ", style: TextStyle(fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,),),
                  TextButton(
                    style: const ButtonStyle(
                      splashFactory: null,
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),
                      padding: WidgetStatePropertyAll(EdgeInsets.all(4.0)),
                      minimumSize: WidgetStatePropertyAll(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(SettingsData.spanNames[settingsData.timeSpan]!.toLowerCase(),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(
                              "Time span:",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16.0,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                RadioListTile(
                                  value: TimeSpan.week,
                                  groupValue: settingsData.timeSpan,
                                  dense: true,
                                  title: Text("Week", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                    color: Theme.of(context).colorScheme.primary,),),
                                  onChanged: (TimeSpan? value) {
                                    if (value != null) {
                                      setState(() { settingsData.setTimeSpan(value); });
                                    }
                                  },
                                ),
                                RadioListTile(
                                  value: TimeSpan.month,
                                  groupValue: settingsData.timeSpan,
                                  dense: true,
                                  title: Text("Month", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                    color: Theme.of(context).colorScheme.primary,),),
                                  onChanged: (TimeSpan? value) {
                                    if (value != null) {
                                      setState(() { settingsData.setTimeSpan(value); });
                                    }
                                  },
                                ),
                                RadioListTile(
                                  value: TimeSpan.year,
                                  groupValue: settingsData.timeSpan,
                                  dense: true,
                                  title: Text("Year", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                    color: Theme.of(context).colorScheme.primary,),),
                                  onChanged: (TimeSpan? value) {
                                    if (value != null) {
                                      setState(() { settingsData.setTimeSpan(value); });
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12.0,),
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
                        minY: -barHeights.reduce((double a, double b) => max(a, b)) * 0.05,
                        maxY: barHeights.reduce((double a, double b) => max(a, b)) * 1.15,
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
                                      return settingsData.timeSpan != TimeSpan.month || [1, 5, 10, 15, 20, 25, 31].contains(axisValue.toInt() + 1) ?  Container(
                                        padding: const EdgeInsets.only(top: 8.0,),
                                        child: Text(SettingsData.spanTitles[settingsData.timeSpan]![axisValue.toInt()], style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,),),
                                      ) : Container();
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
                            width: settingsData.timeSpan == TimeSpan.week ? 16.0 : settingsData.timeSpan == TimeSpan.month ? 8.0 : 12.0,
                            toY: barHeights[index],
                          )],
                          showingTooltipIndicators: barHeights[index] > 0 && (settingsData.timeSpan != TimeSpan.month ||
                              barHeights[index] == barHeights.reduce((double a, double b) => max(a, b))) ? [0] : [],
                        )).toList()
                    )
                ),
              ),
            ] + (kDebugMode ? [Expanded(
              child: ListView(
                children: <Widget>[
                  Text(
                    statsData.toJson().toString(),
                    style: const TextStyle(fontSize: 8.0),
                  ),
                ],
              ),
            )] : []),
          )
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Log other reading", style: TextStyle(
            fontWeight: FontWeight.w300,),),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    "Additional reading:",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16.0,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Date: ", style: TextStyle(fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.primary,),),
                          TextButton(
                            style: const ButtonStyle(
                              splashFactory: null,
                              overlayColor: WidgetStatePropertyAll(Colors.transparent),
                              padding: WidgetStatePropertyAll(EdgeInsets.all(4.0)),
                              minimumSize: WidgetStatePropertyAll(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text("${DateTime.now().toString().split(" ")[0]} ",
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                                const Icon(Icons.edit),
                              ],
                            ),
                            onPressed: () {

                            },
                          ),
                        ],
                      )
                    ],
                  ),
                )
            );
          },
        ),
      ),
    );
  }
}