import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:next_day/page/about/about_page.dart';
import 'package:next_day/plugin/cache_manager_plugin.dart';

class SettingPage extends StatefulWidget {
  @override
  State createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _cacheSize = '';

  _SettingPageState() {
    _updateCacheSize();
  }

  void _cleanCache() async {
    if (_cacheSize != '') {
      await CacheManagerPlugin.cleanCache();
      _updateCacheSize();
    }
  }

  void _updateCacheSize() async {
    String cacheSize = await CacheManagerPlugin.cacheSize();
    setState(() {
      _cacheSize = cacheSize;
    });
  }

  void _goToAboutPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => AboutPage(),
        transitionsBuilder:
            (_, Animation<double> animation, __, Widget child) =>
                SlideTransition(
                  position: new Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
      ),
    );
  }

  Widget _cacheCleanCell() {
    return GestureDetector(
      onTap: _cleanCache,
      child: Container(
        height: 44,
        color: Colors.grey.withOpacity(0.5),
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '清理缓存',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none,
                  fontSize: 16),
            ),
            Text(
              _cacheSize,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none,
                  fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Widget _aboutCell() {
    return GestureDetector(
      onTap: _goToAboutPage,
      child: Container(
        height: 44,
        color: Colors.grey.withOpacity(0.5),
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '关于',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none,
                    fontSize: 16),
              )
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('关于'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Image.asset('assets/icons/back.png', width: 24, height: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: Colors.black38.withOpacity(0.5),
          child: Column(children: [
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                //如果是奇数返回分割线
                switch (index) {
                  case 0:
                    return _cacheCleanCell();
                  case 1:
                    return const Divider(
                      height: 0.0,
                      indent: 16,
                      color: Colors.white,
                    );
                  case 2:
                    return _aboutCell();
                }
              },
            ))
          ]),
        ),
      ),
    );
  }
}
