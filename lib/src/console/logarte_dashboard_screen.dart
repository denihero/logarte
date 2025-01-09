import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logarte/logarte.dart';
import 'package:logarte/src/console/logarte_entry_item.dart';
import 'package:logarte/src/console/logarte_theme_wrapper.dart';

class LogarteDashboardScreen extends StatefulWidget {
  final Logarte instance;
  final bool showBackButton;
  const LogarteDashboardScreen(
    this.instance, {
    Key? key,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  State<LogarteDashboardScreen> createState() => _LogarteDashboardScreenState();
}

class _LogarteDashboardScreenState extends State<LogarteDashboardScreen> {
  late final TextEditingController _controller;
  late final ValueNotifier<String> _searchNotifier;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _searchNotifier = ValueNotifier<String>('');
    _controller.addListener(() {
      _searchNotifier.value = _controller.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = widget.instance.logs.value;

    final allCount = logs.length;
    final networkCount = logs.whereType<NetworkLogarteEntry>().length;
    final navigationCount = logs.whereType<NavigatorLogarteEntry>().length;
    final errorsCount = logs.whereType<PlainLogarteEntry>().length;

    return PopScope(
      canPop: false,
      child: LogarteThemeWrapper(
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    leading: widget.showBackButton ? const BackButton() : null,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        onPressed: () {
                          logs.clear();
                          setState(() {

                          });
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                    title: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        filled: true,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _controller.clear,
                        ),
                      ),
                    ),
                    bottom: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 12.0),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.list_alt_rounded),
                          text: 'All ($allCount)',
                        ),
                        Tab(
                          icon: const Icon(Icons.public),
                          text: 'Network ($networkCount)',
                        ),
                        Tab(
                          icon: const Icon(Icons.error),
                          text: 'Errors ($errorsCount)',
                        ),
                        Tab(
                          icon: const Icon(Icons.navigation_rounded),
                          text: 'Navigation ($navigationCount)',
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: ValueListenableBuilder<String>(
                valueListenable: _searchNotifier,
                builder: (context, search, _) {
                  return TabBarView(
                    children: [
                      _List<LogarteEntry>(
                        instance: widget.instance,
                        search: search,
                        logs: logs,
                      ),
                      _List<NetworkLogarteEntry>(
                        instance: widget.instance,
                        search: search,
                        logs: logs,
                      ),
                      _List<PlainLogarteEntry>(
                        instance: widget.instance,
                        search: search,
                        logs: logs,
                      ),
                      _List<NavigatorLogarteEntry>(
                        instance: widget.instance,
                        search: search,
                        logs: logs,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _List<T extends LogarteEntry> extends StatelessWidget {
  const _List({
    Key? key,
    required this.instance,
    required this.search,
    required this.logs,
  }) : super(key: key);

  final Logarte instance;
  final String search;
  final List<LogarteEntry> logs;

  @override
  Widget build(BuildContext context) {
    final filtered = (T == LogarteEntry ? logs : logs.whereType<T>().toList())
        .where((log) => log.contents.any(
              (content) => content.toLowerCase().contains(search),
            ))
        .toList()
        .reversed
        .toList();

    return Scrollbar(
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: filtered.length,
        padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
        itemBuilder: (context, index) {
          final log = filtered[index];
          return LogarteEntryItem(log, instance: instance);
        },
      ),
    );
  }
}
