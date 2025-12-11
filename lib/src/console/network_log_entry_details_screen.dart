import 'package:flutter/material.dart';
import 'package:json_explorer/json_explorer.dart';
import 'package:logarte/logarte.dart';
import 'package:logarte/src/console/logarte_theme_wrapper.dart';
import 'package:logarte/src/extensions/entry_extensions.dart';
import 'package:logarte/src/extensions/object_extensions.dart';
import 'package:logarte/src/extensions/string_extensions.dart';
import 'package:provider/provider.dart';

class NetworkLogEntryDetailsScreen extends StatefulWidget {
  final NetworkLogarteEntry entry;
  final Logarte instance;

  const NetworkLogEntryDetailsScreen(
    this.entry, {
    super.key,
    required this.instance,
  });

  @override
  State<NetworkLogEntryDetailsScreen> createState() => _NetworkLogEntryDetailsScreenState();
}

class _NetworkLogEntryDetailsScreenState extends State<NetworkLogEntryDetailsScreen> {
  final JsonExplorerStore store = JsonExplorerStore();

  @override
  void initState() {
    super.initState();
    store.buildNodes(widget.entry.response.body);
  }

  @override
  Widget build(BuildContext context) {
    return LogarteThemeWrapper(
      child: Scaffold(
        body: DefaultTabController(
          length: 2,
          child: ChangeNotifierProvider.value(
            value: store,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerScrolled) {
                return [
                  SliverAppBar(
                    leading: IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    title: Text(
                      '${widget.entry.asReadableDuration}, '
                      '${widget.entry.response.body.toString().asReadableSize}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    floating: true,
                    snap: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          final text = widget.entry.toString();
                          widget.instance.onShare?.call(text);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_all),
                        onPressed: () {
                          final text = widget.entry.toString();
                          text.copyToClipboard(context);
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                    bottom: const TabBar(
                      tabs: [
                        Tab(text: 'Request'),
                        Tab(text: 'Response'),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverList.list(
                        children: [
                          SelectableCopiableTile(
                            title: 'METHOD',
                            subtitle: widget.entry.request.method,
                          ),
                          const Divider(height: 0),
                          SelectableCopiableTile(
                            title: 'URL',
                            subtitle: widget.entry.request.url,
                          ),
                          const Divider(height: 0),
                          SelectableCopiableTile(
                            title: 'HEADERS',
                            subtitle: widget.entry.request.headers.prettyJson,
                          ),
                          if (widget.entry.request.method != 'GET') ...[
                            const Divider(height: 0),
                            SelectableCopiableTile(
                              title: 'BODY',
                              subtitle: widget.entry.request.body.prettyJson,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  CustomScrollView(
                    slivers: [
                      SliverList.list(
                        children: [
                          const Divider(height: 0),
                          SelectableExpansionTile(
                            title: 'HEADERS',
                            subtitle: widget.entry.response.headers.prettyJson,
                          ),
                          const Divider(height: 0),
                          SelectableCopiableTile(
                            title: 'RESPONSE | STATUS CODE ${widget.entry.response.statusCode}',
                            subtitle: widget.entry.response.body.prettyJson,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectableCopiableTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const SelectableCopiableTile({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _copyToClipboard(context),
      title: SelectableText(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SelectableText(subtitle),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) {
    return subtitle.copyToClipboard(context);
  }
}

class SelectableExpansionTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const SelectableExpansionTile({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(subtitle),
        ),
      ],
    );
  }
}
