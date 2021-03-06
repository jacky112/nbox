import 'package:flutter/material.dart';
import 'colors.dart';
import 'sqlite.dart';
import 'file_manage_page.dart';
import 'cloud_setting_page.dart';
import 'oss.dart';
import 'event_bus.dart';
import 'config.dart';
import 'translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
    setCustomErrorPage();
    await db.init();
    await Oss().init();
    await conf.init();
    return runApp(MyApp());
}

class MyApp extends StatefulWidget {

    @override
    _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

    SpecificLocalizationDelegate _localeOverrideDelegate;

    Color _themeColor = Colors.black;

    @override
    void initState() {
        super.initState();
        String _colorKey = conf.k['theme_color'];
        if (themeColorMap[_colorKey] != null) {
            _themeColor = themeColorMap[_colorKey];
        }
        _localeOverrideDelegate = new SpecificLocalizationDelegate(Locale(conf.k['lang']));
        initAsync();
    }
    
    void initAsync() async {
        bus.on("main.themeChange", (arg) {
            setState(() {
                _themeColor = themeColorMap[arg];
            });
        });
        bus.on("main.langChange", (locale) {
            setState(() {
                _localeOverrideDelegate = new SpecificLocalizationDelegate(locale);
            });
        });
    }

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: '网盘盒子',
            theme: ThemeData(//.light().copyWith
                primaryColor: _themeColor,
                accentColor: _themeColor,
                indicatorColor: Colors.white,
            ),
            localizationsDelegates: [
                _localeOverrideDelegate, // 注册一个新的delegate
                const TranslationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: conf.supportedLocales(),
            home: Oss().have?FileManagePage():CloudSettingPage(first: true),
        );
    }

}

void setCustomErrorPage(){
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails){
        //print(flutterErrorDetails.toString());
        return Center(
            child: Text("我好像异常了！"),
        );
    };
}