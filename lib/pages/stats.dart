import 'dart:core';
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
  bool showOtherTooltips = true;

  bool sameWeek(DateTime a, DateTime b) {
    DateTime d1 = a.subtract(Duration(days: a.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    DateTime d2 = b.subtract(Duration(days: b.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    return d1.compareTo(d2) == 0;
  }

  bool sameMonth(DateTime a, DateTime b) {
    return a.month == b.month && a.year == b.year;
  }

  bool showToolTip(int index, List<double> barHeights, double maxHeight) {
    if (!showOtherTooltips) return false;
    if (barHeights[index] == 0) return false;

    if (settingsData.timeSpan == TimeSpan.month && barHeights[index] != maxHeight) return false;

    double deltaPrev = index > 0 ? (barHeights[index] - barHeights[index - 1]).abs() : double.nan;
    double deltaNext = index < barHeights.length - 1 ? (barHeights[index] - barHeights[index + 1]).abs() : double.nan;
    bool shadowedByPrev = (index > 0 && barHeights[index] < barHeights[index - 1] && deltaPrev < 0.2 * maxHeight);
    bool shadowedByNext = (index < barHeights.length - 1 && barHeights[index] < barHeights[index + 1] && deltaNext < 0.2 * maxHeight);
    if (settingsData.timeSpan == TimeSpan.year && (shadowedByPrev || shadowedByNext)) return false;
    return true;
  }

  double getHInterval(double maxHeight) {
    // double result = pow(10.0, ((log(maxHeight) / log(10))).floorToDouble() + 1.0).toDouble() / 2.0;
    double order = max(1.0, pow(10.0, maxHeight.toInt().toString().length - 2).toDouble());
    double result = ((maxHeight / 5.0) / order).floorToDouble() * order;
    print("$order $result");
    return max(result, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    List<int> indexes = List<int>.generate(SettingsData.spanTitles[settingsData.timeSpan]!.length, (i) => i);
    List<double> pageBarHeights = indexes
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
    List<double> bookBarHeights = indexes
        .map((int index) => statsData.readingUpdates
            .where(
              settingsData.timeSpan == TimeSpan.week  ? (ReadingUpdate update) => (update.timestamp.weekday == index + 1 && sameWeek(update.timestamp, DateTime.now())) :
              settingsData.timeSpan == TimeSpan.month ? (ReadingUpdate update) => (update.timestamp.day == index + 1 && sameMonth(update.timestamp, DateTime.now())) :
              (ReadingUpdate update) => (update.timestamp.month == index + 1 && update.timestamp.year == DateTime.now().year)
            )
            .map((ReadingUpdate update) => update.bookCompletions)
            .followedBy([0])
            .reduce((int a, int b) => a + b)
            .toDouble())
        .toList();
    List<double> bookLineHeights = indexes
        .map((int index) => bookBarHeights.sublist(0, index + 1)
            .reduce((double a, double b) => a + b))
        .toList();

    int cutoff = settingsData.timeSpan == TimeSpan.year ? DateTime.now().month :
        settingsData.timeSpan == TimeSpan.month ? DateTime.now().day :
        DateTime.now().weekday;
    LineChartBarData bookLineChartBarData = LineChartBarData(
      spots: indexes.map((int index) =>
        index >= cutoff ? FlSpot.nullSpot : FlSpot(index.toDouble(), bookLineHeights[index]),
      ).toList(),
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    double maxBarHeight = pageBarHeights.reduce((double a, double b) => max(a, b));
    double maxLineHeight = bookBarHeights.reduce((double a, double b) => max(a, b));

    return SettingsLauncher(
      body: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 8.0,),
              Row(
                children: <Widget>[
                  Text("Show statistics for this ", style: TextStyle(fontWeight: FontWeight.w300,
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
                            content: RadioGroup(
                              groupValue: settingsData.timeSpan,
                              onChanged: (TimeSpan? value) {
                                if (value != null) {
                                  setState(() { settingsData.setTimeSpan(value); });
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  RadioListTile(
                                    value: TimeSpan.week,
                                    dense: true,
                                    title: Text("Week", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                      color: Theme.of(context).colorScheme.primary,),),
                                  ),
                                  RadioListTile(
                                    value: TimeSpan.month,
                                    dense: true,
                                    title: Text("Month", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                      color: Theme.of(context).colorScheme.primary,),),
                                  ),
                                  RadioListTile(
                                    value: TimeSpan.year,
                                    dense: true,
                                    title: Text("Year", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300,
                                      color: Theme.of(context).colorScheme.primary,),),
                                  ),
                                ],
                              ),
                            )
                          )
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8.0,),
              Expanded(
                child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      const SizedBox(height: 16.0,),
                      Text(
                        "Pages read",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 8.0,),
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
                                minY: -pageBarHeights.reduce((double a, double b) => max(a, b)) * 0.05,
                                maxY: pageBarHeights.reduce((double a, double b) => max(a, b)) * 1.15,
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
                                    toY: pageBarHeights[index],
                                  )],
                                  showingTooltipIndicators: showToolTip(index, pageBarHeights, maxBarHeight) ? [0] : [],
                                )).toList()
                            )
                        ),
                      ),
                      const SizedBox(height: 24.0,),
                      Text(
                        "Books completed",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 8.0,),
                      Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                            border: Border.fromBorderSide(BorderSide(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            )),
                          ),
                          height: 256.0,
                          child: LineChart(
                            LineChartData(
                                minY: -bookBarHeights.reduce((double a, double b) => a + b) * 0.075,
                                maxY: bookBarHeights.reduce((double a, double b) => a + b) * 1.15,
                                minX: -0.75,
                                maxX: (SettingsData.spanTitles[settingsData.timeSpan]!.length - 1) + 0.75,
                                gridData: FlGridData(
                                    horizontalInterval: getHInterval(maxLineHeight),
                                    verticalInterval: 1.0,
                                    getDrawingHorizontalLine: (double y) {
                                      return FlLine(color: Theme.of(context).colorScheme.onInverseSurface, strokeWidth: 1.0);
                                    },
                                    getDrawingVerticalLine: (double x) {
                                      return FlLine(color: Theme.of(context).colorScheme.onInverseSurface, strokeWidth: 1.0);
                                    }
                                ),
                                borderData: FlBorderData(border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.inversePrimary))),
                                titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(),
                                    rightTitles: const AxisTitles(),
                                    topTitles: const AxisTitles(),
                                    bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            minIncluded: false,
                                            maxIncluded: false,
                                            showTitles: true,
                                            reservedSize: 32.0,
                                            interval: 1.0,
                                            getTitlesWidget: (double axisValue, TitleMeta meta) {
                                              return (
                                                  axisValue >= 0.0 &&
                                                      axisValue < SettingsData.spanTitles[settingsData.timeSpan]!.length &&
                                                      (settingsData.timeSpan != TimeSpan.month || [1, 5, 10, 15, 20, 25, 31].contains(axisValue.toInt() + 1))
                                              ) ? Container(
                                                padding: const EdgeInsets.only(top: 8.0,),
                                                child: Text(SettingsData.spanTitles[settingsData.timeSpan]![axisValue.toInt()], style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,),),
                                              ) : Container();
                                            }
                                        )
                                    )
                                ),
                                lineTouchData: LineTouchData(
                                    enabled: false,
                                    handleBuiltInTouches: false,
                                    touchTooltipData: LineTouchTooltipData(
                                        tooltipMargin: 8.0,
                                        tooltipPadding: EdgeInsets.zero,
                                        getTooltipColor: (_) => Colors.transparent,
                                        getTooltipItems: (List<LineBarSpot> spots) {
                                          if (spots[0].y.isNaN) {
                                            return [const LineTooltipItem("", TextStyle())];
                                          }

                                          return [LineTooltipItem(spots[0].y.toInt().toString(),
                                              TextStyle(color: Theme.of(context).colorScheme.primary))];
                                        }
                                    )
                                ),
                                lineBarsData: [
                                  bookLineChartBarData
                                ],
                                showingTooltipIndicators: settingsData.timeSpan == TimeSpan.year ?
                                    indexes.sublist(0, DateTime.now().month).map((int index) =>
                                        ShowingTooltipIndicators([LineBarSpot(bookLineChartBarData, 0, bookLineChartBarData.spots[index])])
                                    ).toList() : settingsData.timeSpan == TimeSpan.month ?
                                    indexes.sublist(DateTime.now().day - 1, DateTime.now().day).map((int index) =>
                                        ShowingTooltipIndicators([LineBarSpot(bookLineChartBarData, 0, bookLineChartBarData.spots[index])])
                                    ).toList() :
                                    indexes.sublist(0, DateTime.now().weekday).map((int index) =>
                                        ShowingTooltipIndicators([LineBarSpot(bookLineChartBarData, 0, bookLineChartBarData.spots[index])])
                                    ).toList()
                            ),
                          )
                      ),
                    ] + (kDebugMode ? [
                      const SizedBox(height: 24.0,),
                      Text(
                        statsData.toJson().toString(),
                        style: const TextStyle(fontSize: 8.0),
                      ),
                    ] : [])
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}