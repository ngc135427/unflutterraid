import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/phone_frame.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  static const routeName = '/detail';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UnraidDashboard) {
      return _DashboardDetailPage(dashboard: args);
    }

    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 28,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      l10n.back,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.productDetails,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        l10n.viewFullInfo,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: FadeSlide(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailSection(
                        icon: Icons.info,
                        title: l10n.basicInfo,
                        child: Text(
                          l10n.detailSampleBody,
                          style: _bodyStyle,
                        ),
                      ),
                      _DetailSection(
                        icon: Icons.list,
                        title: l10n.featureList,
                        child: Column(
                          children: [
                            _FeatureRow(label: l10n.featureResponsive),
                            _FeatureRow(label: l10n.featureVisualConsistency),
                            _FeatureRow(label: l10n.featureAnimations),
                            _FeatureRow(label: l10n.featureClearHierarchy),
                          ],
                        ),
                      ),
                      _DetailSection(
                        icon: Icons.description,
                        title: l10n.detailedDescription,
                        child: Column(
                          children: [
                            _InfoCard(
                              title: l10n.designPhilosophy,
                              text: l10n.designPhilosophyText,
                            ),
                            SizedBox(height: 12),
                            _InfoCard(
                              title: l10n.interactionDesign,
                              text: l10n.interactionDesignText,
                            ),
                          ],
                        ),
                      ),
                      _DetailSection(
                        icon: Icons.style,
                        title: l10n.uiElements,
                        child: Text(
                          l10n.uiElementsText,
                          style: _bodyStyle,
                        ),
                      ),
                      GradientButton(
                        label: l10n.confirmAction,
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.actionConfirmedTitle),
                            content: Text(l10n.actionConfirmedBody),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(l10n.gotIt),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardDetailPage extends StatelessWidget {
  _DashboardDetailPage({required this.dashboard});

  final UnraidDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 28,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      l10n.back,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dashboard.serverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'server / info / settings / cloud',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: FadeSlide(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailSection(
                        icon: Icons.badge,
                        title: l10n.serverProfile,
                        child: Column(
                          children: [
                            _DataRow(label: 'GUID', value: dashboard.guid),
                            _DataRow(
                                label: 'Owner', value: dashboard.ownerName),
                            _DataRow(
                              label: l10n.authorization,
                              value: dashboard.registration,
                            ),
                            _DataRow(
                                label: l10n.status, value: dashboard.status),
                          ],
                        ),
                      ),
                      _DetailSection(
                        icon: Icons.developer_board,
                        title: l10n.hardwareAndSystem,
                        child: Column(
                          children: [
                            _DataRow(label: l10n.model, value: dashboard.model),
                            _DataRow(label: 'CPU', value: dashboard.cpuSummary),
                            _DataRow(
                              label: l10n.motherboard,
                              value: dashboard.baseboardSummary,
                            ),
                            _DataRow(
                                label: l10n.system, value: dashboard.osSummary),
                            _DataRow(
                              label: l10n.packageVersion,
                              value: dashboard.packagesSummary,
                            ),
                          ],
                        ),
                      ),
                      _DetailSection(
                        icon: Icons.storage,
                        title: l10n.arrayAndStorage,
                        child: Column(
                          children: [
                            _DataRow(
                              label: l10n.array,
                              value:
                                  '${dashboard.arrayState} · ${dashboard.arrayUsage}',
                            ),
                            _DataRow(
                              label: 'Parity',
                              value: dashboard.paritySummary.isEmpty
                                  ? l10n.noParityTask
                                  : dashboard.paritySummary,
                            ),
                            _DataRow(
                              label: l10n.disk,
                              value:
                                  l10n.countItems(dashboard.diskItems.length),
                            ),
                            _DataRow(
                              label: l10n.navShare,
                              value:
                                  l10n.countItems(dashboard.shareItems.length),
                            ),
                          ],
                        ),
                      ),
                      _DetailSection(
                        icon: Icons.language,
                        title: l10n.networkAndConnection,
                        child: Column(
                          children: [
                            _DataRow(label: 'LAN', value: dashboard.lanIp),
                            _DataRow(label: 'WAN', value: dashboard.wanIp),
                            _DataRow(
                                label: l10n.localUrl,
                                value: dashboard.localUrl),
                            _DataRow(
                                label: l10n.remoteUrl,
                                value: dashboard.remoteUrl),
                            _DataRow(
                              label: l10n.dockerNetwork,
                              value: dashboard.dockerNetworkSummary,
                            ),
                            _DataRow(
                              label: l10n.portConflicts,
                              value: dashboard.dockerConflictSummary,
                            ),
                          ],
                        ),
                      ),
                      _DetailSection(
                        icon: Icons.cloud_done,
                        title: l10n.cloudPluginsPermissions,
                        child: Column(
                          children: [
                            _DataRow(
                              label: 'Cloud',
                              value: dashboard.cloudItems
                                  .map((item) => '${item.title} ${item.value}')
                                  .take(2)
                                  .join(' · '),
                            ),
                            _DataRow(
                              label: l10n.plugins,
                              value: l10n
                                  .countRecords(dashboard.pluginItems.length),
                            ),
                            _DataRow(
                              label: l10n.permissions,
                              value: dashboard.securityItems
                                  .map((item) => '${item.title} ${item.value}')
                                  .join(' · '),
                            ),
                            _DataRow(
                              label: l10n.logs,
                              value: l10n.countFiles(dashboard.logItems.length),
                            ),
                          ],
                        ),
                      ),
                      GradientButton(
                        label: l10n.returnHome,
                        icon: Icons.home,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  _DataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.softLine)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: TextStyle(color: AppTheme.textLight, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? AppLocalizations.of(context).unknown : value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _bodyStyle = TextStyle(
  color: AppTheme.textMedium,
  fontSize: 15,
  height: 1.6,
);

class _DetailSection extends StatelessWidget {
  _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.softLine)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMedium, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  _InfoCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textMedium,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
