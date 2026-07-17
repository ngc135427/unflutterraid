import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/phone_frame.dart';

class DockerLogsPageArgs {
  const DockerLogsPageArgs({
    required this.apiClient,
    required this.containerId,
    required this.containerName,
  });

  final UnraidApiClient apiClient;
  final String containerId;
  final String containerName;
}

class DockerLogsPage extends StatefulWidget {
  const DockerLogsPage({super.key});

  static const routeName = '/docker-logs';

  @override
  State<DockerLogsPage> createState() => _DockerLogsPageState();
}

class _DockerLogsPageState extends State<DockerLogsPage> {
  bool _loading = true;
  String? _error;
  List<DockerLogLine> _lines = const [];
  final _scrollController = ScrollController();

  DockerLogsPageArgs? get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is DockerLogsPageArgs ? args : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final args = _args;
    final l10n = AppLocalizations.of(context);
    if (args == null || args.containerId.isEmpty) {
      setState(() {
        _loading = false;
        _error = l10n.missingConnectionArgs;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lines = await args.apiClient.fetchDockerLogs(args.containerId);
      if (!mounted) {
        return;
      }
      setState(() {
        _lines = lines;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } on UnraidApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = l10n.loadFailed(error.toString());
        _loading = false;
      });
    }
  }

  Future<void> _copyAll() async {
    final text = _lines
        .map((line) => line.timestamp.isEmpty
            ? line.message
            : '${line.timestamp}  ${line.message}')
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).logsCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final args = _args;
    final title = args?.containerName ?? l10n.dockerLogsTitle;

    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.refresh,
                    onPressed: _loading ? null : () => unawaited(_load()),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                  IconButton(
                    tooltip: l10n.copyLogs,
                    onPressed:
                        _lines.isEmpty ? null : () => unawaited(_copyAll()),
                    icon: const Icon(Icons.copy, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () => unawaited(_load()),
                                  child: Text(l10n.retry),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _lines.isEmpty
                          ? Center(
                              child: Text(
                                l10n.dockerLogsEmpty,
                                style: const TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(14, 12, 14, 24),
                              itemCount: _lines.length,
                              itemBuilder: (context, index) {
                                final line = _lines[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: SelectableText.rich(
                                    TextSpan(
                                      children: [
                                        if (line.timestamp.isNotEmpty)
                                          TextSpan(
                                            text: '${line.timestamp}  ',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.45),
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        TextSpan(
                                          text: line.message,
                                          style: const TextStyle(
                                            color: Color(0xFFE5E7EB),
                                            fontSize: 12,
                                            height: 1.35,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
          if (!_loading && _error == null)
            Container(
              width: double.infinity,
              color: AppTheme.background,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                l10n.dockerLogsConsoleNote,
                style: const TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
