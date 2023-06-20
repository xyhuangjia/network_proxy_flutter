import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_proxy/network/bin/server.dart';
import 'package:network_proxy/utils/ip.dart';



class SslWidget extends StatefulWidget {
  final ProxyServer proxyServer;

  const SslWidget({super.key, required this.proxyServer});

  @override
  State<SslWidget> createState() => _SslState();
}

class _SslState extends State<SslWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.https),
      surfaceTintColor: Colors.white70,
      tooltip: "Https代理",
      offset: const Offset(10, 30),
      itemBuilder: (context) {
        return [
          PopupMenuItem(child: _Switch(proxyServer: widget.proxyServer)),
          PopupMenuItem(
              child: ListTile(
            dense: true,
            title: const Text("安装根证书到系统"),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              pcCer();
            },
          )),
          PopupMenuItem<String>(
            child: ListTile(
                title: const Text("安装根证书到手机"),
                dense: true,
                trailing: const Icon(Icons.arrow_right),
                onTap: () async {
                  mobileCer(await localIp());
                }),
          ),
          // const PopupMenuItem<String>(
          //   child: ListTile(title: Text("安装根证书到Android"), dense: true, trailing: Icon(Icons.arrow_right)),
          // )
        ];
      },
    );
  }

  void pcCer() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              contentPadding: const EdgeInsets.all(16),
              title: const Text("电脑https抓包配置", style: TextStyle(fontSize: 16)),
              alignment: Alignment.center,
              children: [
                const Text("1.下载根证书安装到本系统（已完成忽略）"),
                FilledButton(onPressed: () => _downloadCert(), child: const Text("下载证书")),
                const SizedBox(height: 10),
                const Text("2.双击安装证书，Mac安装完选择“始终信任此证书”,\n   Windows选择“受信任的根证书颁发机构” "),
              ]);
        });
  }

  void mobileCer(String host) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              contentPadding: const EdgeInsets.all(16),
              title: const Text("手机https抓包配置", style: TextStyle(fontSize: 16)),
              alignment: Alignment.center,
              children: [
                const Text("1. 根证书安装到本系统（已完成忽略）"),
                const SizedBox(height: 10),
                SelectableText.rich(TextSpan(text: "2.配置手机Wifi代理 Host：$host  Port：${widget.proxyServer.port}")),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text("3.打开手机系统自带浏览器访问：\t"),
                    SelectableText.rich(
                        TextSpan(text: "http://proxy.pin/ssl", style: TextStyle(decoration: TextDecoration.underline)))
                  ],
                ),
                const SizedBox(height: 10),
                const Text("4.打开手机设置下载安装证书(Profile)和信任证书(Certificate) \n\t  设置 > 通用 > 关于本机 > 证书信任设置"),
                const SizedBox(height: 20),
                const Text("  微信小程序ios需要开启本地网络权限", style: TextStyle(fontWeight: FontWeight.bold)),
              ]);
        });
  }

  void _downloadCert() async {
    final String? path = await getSavePath(suggestedName: "ProxyPinCA.crt");
    if (path != null) {
      const String fileMimeType = 'application/x-x509-ca-cert';
      var body = await rootBundle.load('assets/certs/ca.crt');
      final XFile xFile = XFile.fromData(
        body.buffer.asUint8List(),
        mimeType: fileMimeType,
      );
      await xFile.saveTo(path);
    }
  }
}

class _Switch extends StatefulWidget {
  final ProxyServer proxyServer;

  const _Switch({Key? key, required this.proxyServer}) : super(key: key);

  @override
  State<_Switch> createState() => _SwitchState();
}

class _SwitchState extends State<_Switch> {
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        title: const Text("启用Https代理", style: TextStyle(fontSize: 12)),
        visualDensity: const VisualDensity(horizontal: -4),
        dense: true,
        value: widget.proxyServer.enableSsl,
        onChanged: (val) {
          widget.proxyServer.enableSsl = val;
          changed = true;
          setState(() {});
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (changed) {
      widget.proxyServer.flushConfig();
    }
  }
}