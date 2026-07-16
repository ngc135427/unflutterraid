#!/usr/bin/env python3
"""Replace hard-coded Chinese display strings in unraid_api_client.dart."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "lib" / "services" / "unraid_api_client.dart"

# Order matters for some overlapping patterns — longest first where needed.
REPLACEMENTS: list[tuple[str, str]] = [
    (
        "import 'package:http/http.dart' as http;\n",
        "import 'package:http/http.dart' as http;\n\nimport 'display_copy.dart';\n",
    ),
    (
        """    if (!hasUnraidApi) {
      throw const UnraidApiException(
        '未找到 unraid-api 服务，请确认 Unraid Connect/API 插件已启用',
      );
    }""",
        """    if (!hasUnraidApi) {
      throw UnraidApiException(DisplayCopy.current.apiUnraidServiceMissing);
    }""",
    ),
    (
        "ManagementItemType.share => throw const UnraidApiException('共享项目不支持该操作'),",
        "ManagementItemType.share =>\n        throw UnraidApiException(DisplayCopy.current.apiShareActionUnsupported),",
    ),
]

TEXT_REPLACES: list[tuple[str, str]] = [
    ("'连接服务器超时'", "DisplayCopy.current.apiConnectionTimeout"),
    ("'无法连接服务器：$error'", "DisplayCopy.current.apiCannotConnect(error)"),
    (
        "message ?? '服务器返回 HTTP ${response.statusCode}'",
        "message ?? DisplayCopy.current.apiHttpError(response.statusCode)",
    ),
    ("'服务器返回了无效数据'", "DisplayCopy.current.apiInvalidData"),
    ("message ?? 'GraphQL 请求失败'", "message ?? DisplayCopy.current.apiGraphqlFailed"),
    ("'响应中缺少 data 字段'", "DisplayCopy.current.apiMissingDataField"),
    ("actionLabel: '读取目录'", "actionLabel: DisplayCopy.current.apiActionListDirectory"),
    ("actionLabel: '扫描媒体文件'", "actionLabel: DisplayCopy.current.apiActionScanMedia"),
    ("actionLabel: '读取文件'", "actionLabel: DisplayCopy.current.apiActionReadFile"),
    ("actionLabel: '读取缩略图'", "actionLabel: DisplayCopy.current.apiActionReadThumbnail"),
    (
        "'File Browser 返回了无效 JSON：$actionLabel'",
        "DisplayCopy.current.apiFileBrowserInvalidJson(actionLabel)",
    ),
    (
        "'File Browser $actionLabel超时'",
        "DisplayCopy.current.apiFileBrowserTimeout(actionLabel)",
    ),
    (
        "'无法连接 File Browser：$error'",
        "DisplayCopy.current.apiFileBrowserCannotConnect(error)",
    ),
    (
        "'File Browser 拒绝访问，请检查匿名访问或反向代理认证配置（HTTP ${response.statusCode}）'",
        "DisplayCopy.current.apiFileBrowserForbidden(response.statusCode)",
    ),
    (
        "'File Browser 未找到路径（HTTP 404）'",
        "DisplayCopy.current.apiFileBrowserNotFound",
    ),
    (
        "'File Browser $actionLabel失败：HTTP ${response.statusCode}'",
        "DisplayCopy.current.apiFileBrowserFailed(actionLabel, response.statusCode)",
    ),
    # Dashboard / mapping
    ("guid: _firstText([server['guid'], '未知']),", "guid: _firstText([server['guid'], DisplayCopy.current.unknown]),"),
    ("'未绑定'", "DisplayCopy.current.unbound"),
    ("'未返回'", "DisplayCopy.current.notReturned"),
    ("title: '已安装插件'", "title: DisplayCopy.current.installedPlugins"),
    ("value: '${installedPlugins.length} 个'", "value: DisplayCopy.current.countUnit(installedPlugins.length)"),
    ("value: '${apiKeys.length} 个'", "value: DisplayCopy.current.countUnit(apiKeys.length)"),
    ("description: '可用角色与权限来自 apiKeyPossibleRoles'", "description: DisplayCopy.current.apiKeyRolesDescription"),
    ("value: json['isSSOEnabled'] == true ? '已启用' : '未启用'", "value: json['isSSOEnabled'] == true ? DisplayCopy.current.enabled : DisplayCopy.current.disabled"),
    ("description: '${oidcProviders.length} 个 OIDC 提供方'", "description: DisplayCopy.current.oidcProviderCount(oidcProviders.length)"),
    ("'Unraid Cloud 状态'", "DisplayCopy.current.unraidCloudStatus"),
    (
        """'动态远程访问 ${_firstText([
                  _asMap(connect['dynamicRemoteAccess'])['runningType'],
                  remoteAccess['accessType'],
                  '未知'
                ])}'""",
        """DisplayCopy.current.dynamicRemoteAccess(_firstText([
                  _asMap(connect['dynamicRemoteAccess'])['runningType'],
                  remoteAccess['accessType'],
                  DisplayCopy.current.unknown,
                ]))""",
    ),
    ("title: '远程访问'", "title: DisplayCopy.current.remoteAccess"),
    (
        """value: _firstText([remoteAccess['accessType'], '未知']),
          description: '${_firstText([
                remoteAccess['forwardType'],
                'forward 未知'
              ])} · 端口 ${_firstText([remoteAccess['port'], '未知'])}'""",
        """value: _firstText([remoteAccess['accessType'], DisplayCopy.current.unknown]),
          description: '${_firstText([
                remoteAccess['forwardType'],
                DisplayCopy.current.forwardUnknown,
              ])} · ${DisplayCopy.current.portLabel(_firstText([remoteAccess['port'], DisplayCopy.current.unknown]))}'""",
    ),
    ("_firstText([json['image'], '未命名容器'])", "_firstText([json['image'], DisplayCopy.current.unnamedContainer])"),
    ("'Docker 容器'", "DisplayCopy.current.dockerContainer"),
    ("if (json['autoStart'] == true) '自启动'", "if (json['autoStart'] == true) DisplayCopy.current.autoStart"),
    (
        "if (json['isUpdateAvailable'] == true || updateStatus.isNotEmpty) '有更新'",
        "if (json['isUpdateAvailable'] == true || updateStatus.isNotEmpty) DisplayCopy.current.updateAvailable",
    ),
    ("title: '镜像'", "title: DisplayCopy.current.image"),
    ("value: _firstText([json['image'], '未知'])", "value: _firstText([json['image'], DisplayCopy.current.unknown])"),
    ("title: '端口'", "title: DisplayCopy.current.ports"),
    ("value: tailscale['online'] == true ? '在线' : '离线'", "value: tailscale['online'] == true ? DisplayCopy.current.online : DisplayCopy.current.offline"),
    ("_firstText([domain['name'], json['name'], '未命名虚拟机'])", "_firstText([domain['name'], json['name'], DisplayCopy.current.unnamedVm])"),
    ("description: '虚拟机'", "description: DisplayCopy.current.virtualMachine"),
    ("if (_formatStatus(state) == '运行中') 'VNC 可用'", "if (_formatStatus(state) == DisplayCopy.current.running) DisplayCopy.current.vncAvailable"),
    ("value: _firstText([domain['uuid'], '未知'])", "value: _firstText([domain['uuid'], DisplayCopy.current.unknown])"),
    ("description: '虚拟机域标识'", "description: DisplayCopy.current.vmDomainId"),
    ("title: '状态'", "title: DisplayCopy.current.status"),
    ("description: '来自 vms.domain.state'", "description: DisplayCopy.current.fromVmDomainState"),
    ("_firstText([json['name'], json['nameOrig'], '未命名共享'])", "_firstText([json['name'], json['nameOrig'], DisplayCopy.current.unnamedShare])"),
    ("status: json['cache'] == true ? '缓存' : '阵列'", "status: json['cache'] == true ? DisplayCopy.current.cache : DisplayCopy.current.array"),
    ("'共享目录'", "DisplayCopy.current.shareDirectory"),
    ("title: '容量'", "title: DisplayCopy.current.capacity"),
    ("description: 'free ${_formatKilobytes(json['free']) ?? '未知'}'", "description: DisplayCopy.current.freeLabel(_formatKilobytes(json['free']) ?? DisplayCopy.current.unknown)"),
    ("title: '分配策略'", "title: DisplayCopy.current.allocationStrategy"),
    ("value: _firstText([json['allocator'], '未知'])", "value: _firstText([json['allocator'], DisplayCopy.current.unknown])"),
    (
        "description: 'split level ${_firstText([json['splitLevel'], '默认'])}'",
        "description: DisplayCopy.current.splitLevel(_firstText([json['splitLevel'], DisplayCopy.current.defaultValue]))",
    ),
    ("title: '说明'", "title: DisplayCopy.current.description"),
    ("value: _firstText([json['comment'], '无'])", "value: _firstText([json['comment'], DisplayCopy.current.none])"),
    ("description: '共享目录配置'", "description: DisplayCopy.current.shareDirectoryConfig"),
    ("_firstText([json['name'], json['device'], '未知磁盘'])", "_firstText([json['name'], json['device'], DisplayCopy.current.unknownDisk])"),
    ("value: _firstText([json['smartStatus'], json['type'], '未知'])", "value: _firstText([json['smartStatus'], json['type'], DisplayCopy.current.unknown])"),
    ("if (json['isSpinning'] == false) '休眠'", "if (json['isSpinning'] == false) DisplayCopy.current.sleeping"),
    ("_firstText([json['name'], json['iface'], '网络接口'])", "_firstText([json['name'], json['iface'], DisplayCopy.current.networkInterface])"),
    ("value: _firstText([json['status'], json['operstate'], '未知'])", "value: _firstText([json['status'], json['operstate'], DisplayCopy.current.unknown])"),
    ("_firstText([json['ipAddress'], json['macAddress'], '无地址'])", "_firstText([json['ipAddress'], json['macAddress'], DisplayCopy.current.noAddress])"),
    ("_firstText([json['name'], json['type'], '访问地址'])", "_firstText([json['name'], json['type'], DisplayCopy.current.accessAddress])"),
    ("value: _firstText([json['ipv4'], json['ipv6'], '未返回'])", "value: _firstText([json['ipv4'], json['ipv6'], DisplayCopy.current.notReturned])"),
    (
        """description: '电量 ${_firstText([
            battery['chargeLevel'],
            '未知'
          ])}% · 负载 ${_firstText([power['loadPercentage'], '未知'])}%'""",
        """description: DisplayCopy.current.batteryLoad(
            _firstText([battery['chargeLevel'], DisplayCopy.current.unknown]),
            _firstText([power['loadPercentage'], DisplayCopy.current.unknown]),
          )""",
    ),
    ("_firstText([json['name'], '插件'])", "_firstText([json['name'], DisplayCopy.current.plugin])"),
    ("value: _firstText([json['version'], '未知版本'])", "value: _firstText([json['version'], DisplayCopy.current.unknownVersion])"),
    (
        """description:
          'API ${json['hasApiModule'] == true ? '有' : '无'} · CLI ${json['hasCliModule'] == true ? '有' : '无'}'""",
        """description: DisplayCopy.current.apiCliModules(
            json['hasApiModule'] == true ? DisplayCopy.current.yes : DisplayCopy.current.no,
            json['hasCliModule'] == true ? DisplayCopy.current.yes : DisplayCopy.current.no,
          )""",
    ),
    ("_firstText([json['name'], json['url'], '插件安装任务'])", "_firstText([json['name'], json['url'], DisplayCopy.current.pluginInstallTask])"),
    ("_firstText([json['updatedAt'], json['createdAt'], '安装任务'])", "_firstText([json['updatedAt'], json['createdAt'], DisplayCopy.current.installTask])"),
    ("_firstText([json['name'], json['path'], '日志'])", "_firstText([json['name'], json['path'], DisplayCopy.current.log])"),
    ("value: _formatBytes(json['size']) ?? '未知大小'", "value: _formatBytes(json['size']) ?? DisplayCopy.current.unknownSize"),
    ("value: _firstText([lanIp, '未返回'])", "value: _firstText([lanIp, DisplayCopy.current.notReturned])"),
    ("description: _firstText([localUrl, '本地访问地址'])", "description: _firstText([localUrl, DisplayCopy.current.localAccessAddress])"),
    ("value: _firstText([wanIp, '未返回'])", "value: _firstText([wanIp, DisplayCopy.current.notReturned])"),
    ("description: _firstText([remoteUrl, '远程访问地址'])", "description: _firstText([remoteUrl, DisplayCopy.current.remoteAccessAddress])"),
    ("_firstText([json['title'], json['subject'], '通知'])", "_firstText([json['title'], json['subject'], DisplayCopy.current.notification])"),
    ("'未命名'", "DisplayCopy.current.unnamed"),
    ("size: isDirectory ? '目录' : _formatBytes(json['size']) ?? ''", "size: isDirectory ? DisplayCopy.current.directory : _formatBytes(json['size']) ?? ''"),
    # Remaining bare '未知' after specific ones
    ("'未知'", "DisplayCopy.current.unknown"),
    # Format helpers
    ("final brand = _firstText([cpu['brand'], cpu['manufacturer'], DisplayCopy.current.unknown CPU]);", "final brand = _firstText([cpu['brand'], cpu['manufacturer'], DisplayCopy.current.unknownCpu]);"),
]


def main() -> None:
    text = PATH.read_text(encoding="utf-8")
    if "import 'display_copy.dart';" not in text:
        text = text.replace(
            "import 'package:http/http.dart' as http;\n",
            "import 'package:http/http.dart' as http;\n\nimport 'display_copy.dart';\n",
            1,
        )

    for old, new in REPLACEMENTS[1:]:
        if old not in text:
            print("WARN missing block:\n", old[:80])
        else:
            text = text.replace(old, new)

    for old, new in TEXT_REPLACES:
        if old not in text and "DisplayCopy" not in new:
            pass
        count = text.count(old)
        if count == 0:
            # try after partial apply
            if new in text or "DisplayCopy.current" in old:
                continue
            print(f"WARN missing: {old[:70]!r}")
        else:
            text = text.replace(old, new)

    # Fix accidental broken unknownCpu from naive replace
    text = text.replace(
        "DisplayCopy.current.unknown CPU",
        "DisplayCopy.current.unknownCpu",
    )
    text = text.replace(
        "DisplayCopy.current.unknown主板",
        "DisplayCopy.current.unknownMotherboard",
    )
    text = text.replace(
        "DisplayCopy.current.unknown系统",
        "DisplayCopy.current.unknownSystem",
    )

    # Manual format helper rewrites if still Chinese
    helpers = {
        "if (cores.isNotEmpty) '$cores 核'": "if (cores.isNotEmpty) DisplayCopy.current.coresCount(cores)",
        "if (threads.isNotEmpty) '$threads 线程'": "if (threads.isNotEmpty) DisplayCopy.current.threadsCount(threads)",
        "'未知主板'": "DisplayCopy.current.unknownMotherboard",
        "'未知系统'": "DisplayCopy.current.unknownSystem",
        "'未返回包版本'": "DisplayCopy.current.noPackageVersions",
        "return parts.where((part) => part.isNotEmpty && part != '未知').join(' · ');": "return parts.where((part) => part.isNotEmpty && part != DisplayCopy.current.unknown).join(' · ');",
        "return parts.where((part) => part.isNotEmpty && part != DisplayCopy.current.unknown).join(' · ');": "return parts.where((part) => part.isNotEmpty && part != DisplayCopy.current.unknown).join(' · ');",
        "'未返回服务'": "DisplayCopy.current.noServicesReturned",
        "return '$online/${services.length} 在线 · ${names.join(' · ')}';": "return DisplayCopy.current.servicesOnlineSummary(online, services.length, names.join(' · '));",
        "'未返回网络'": "DisplayCopy.current.noNetworksReturned",
        "return '${networks.length} 个网络${names.isEmpty ? '' : ' · $names'}';": "return '${DisplayCopy.current.networksCount(networks.length)}${names.isEmpty ? '' : ' · $names'}';",
        "'未返回端口冲突信息'": "DisplayCopy.current.noPortConflictInfo",
        "'未发现端口冲突'": "DisplayCopy.current.noPortConflicts",
        "return '$total 个端口冲突';": "return DisplayCopy.current.portConflictCount(total);",
        "return '${ip.isEmpty ? '容器' : ip} · $binding/$type';": "return '${ip.isEmpty ? DisplayCopy.current.container : ip} · $binding/$type';",
        "return description.isEmpty ? '未返回端口映射' : description;": "return description.isEmpty ? DisplayCopy.current.noPortMappings : description;",
        "return '未知';": "return DisplayCopy.current.unknown;",
        "return '总计 $totalText';": "return DisplayCopy.current.totalUsage(totalText);",
        "return '已用 $usedText';": "return DisplayCopy.current.usedUsage(usedText);",
        "return '已用 $usedText / $totalText';": "return DisplayCopy.current.usedTotalUsage(usedText, totalText);",
        "return '共享目录';": "return DisplayCopy.current.shareDirectory;",
        "'RUNNING' => '运行中'": "'RUNNING' => DisplayCopy.current.running",
        "'ONLINE' => '在线'": "'ONLINE' => DisplayCopy.current.online",
        "'OFFLINE' => '离线'": "'OFFLINE' => DisplayCopy.current.offline",
        "'STARTED' => '已启动'": "'STARTED' => DisplayCopy.current.started",
        "'STOPPED' => '已停止'": "'STOPPED' => DisplayCopy.current.stopped",
        "'PAUSED' => '已暂停'": "'PAUSED' => DisplayCopy.current.paused",
        "'EXITED' => '已停止'": "'EXITED' => DisplayCopy.current.stopped",
        "'IDLE' => '空闲'": "'IDLE' => DisplayCopy.current.idle",
        "'SHUTDOWN' || 'SHUTOFF' => '已关闭'": "'SHUTDOWN' || 'SHUTOFF' => DisplayCopy.current.shutDown",
        "'CRASHED' => '异常'": "'CRASHED' => DisplayCopy.current.crashed",
        "'PMSUSPENDED' => '休眠'": "'PMSUSPENDED' => DisplayCopy.current.sleeping",
        "null || '' => '未知'": "null || '' => DisplayCopy.current.unknown",
        "null || '' => DisplayCopy.current.unknown": "null || '' => DisplayCopy.current.unknown",
        "return '${elapsed.inDays} 天';": "return DisplayCopy.current.daysCount(elapsed.inDays);",
        "return '${elapsed.inHours} 小时';": "return DisplayCopy.current.hoursCount(elapsed.inHours);",
        "return '${elapsed.inMinutes} 分钟';": "return DisplayCopy.current.minutesCount(elapsed.inMinutes);",
    }
    for old, new in helpers.items():
        if old in text:
            text = text.replace(old, new)

    # Fix version fallbacks that used bare unknown already replaced
    text = text.replace(
        "version: _firstText([\n        vars['version'],\n        os['release'],\n        DisplayCopy.current.unknown,\n      ]),",
        "version: _firstText([\n        vars['version'],\n        os['release'],\n        DisplayCopy.current.unknown,\n      ]),",
    )
    text = text.replace(
        "registration: _firstText([\n        registration['type'],\n        registration['state'],\n        DisplayCopy.current.unknown,\n      ]),",
        "registration: _firstText([\n        registration['type'],\n        registration['state'],\n        DisplayCopy.current.unknown,\n      ]),",
    )
    text = text.replace(
        "lanIp: _firstText([server['lanip'], DisplayCopy.current.unknown]),",
        "lanIp: _firstText([server['lanip'], DisplayCopy.current.unknown]),",
    )
    text = text.replace(
        "wanIp: _firstText([server['wanip'], DisplayCopy.current.unknown]),",
        "wanIp: _firstText([server['wanip'], DisplayCopy.current.unknown]),",
    )
    text = text.replace(
        "localUrl: _firstText([server['localurl'], DisplayCopy.current.notReturned]),",
        "localUrl: _firstText([server['localurl'], DisplayCopy.current.notReturned]),",
    )
    text = text.replace(
        "remoteUrl: _firstText([server['remoteurl'], DisplayCopy.current.notReturned]),",
        "remoteUrl: _firstText([server['remoteurl'], DisplayCopy.current.notReturned]),",
    )

    # const UnraidApiException may remain invalid if we removed const strings
    text = text.replace("throw const UnraidApiException(", "throw UnraidApiException(")
    text = text.replace("throw const UnraidApiException", "throw UnraidApiException")

    PATH.write_text(text, encoding="utf-8")

    # Report remaining Chinese in string literals
    import re

    remaining = re.findall(r"'([^']*[\u4e00-\u9fff][^']*)'", text)
    remaining += re.findall(r'"([^"]*[\u4e00-\u9fff][^"]*)"', text)
    uniq = []
    for s in remaining:
        if s not in uniq:
            uniq.append(s)
    print(f"Remaining Chinese literals: {len(uniq)}")
    for s in uniq:
        print(" -", s)


if __name__ == "__main__":
    main()
