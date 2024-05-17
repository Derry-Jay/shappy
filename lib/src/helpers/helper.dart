import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/widgets.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/parser.dart';
import '../../generated/l10n.dart';
import '../elements/CircularLoadingWidget.dart';
import '../repository/settings_repository.dart';

class Helper {
  BuildContext context;
  DateTime currentBackPressTime;
  static BuildContext bc;
  Helper.of(BuildContext _context) {
    this.context = _context;
    Helper.bc = _context;
  }

  // for mapping data retrieved form json array
  static getData(Map<String, dynamic> data) {
    return data['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data'] as int) ?? 0;
  }

  static double getDoubleData(Map<String, dynamic> data) {
    return (data['data'] as double) ?? 0;
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data'] as bool) ?? false;
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Marker> getMyPositionMarker(
      double latitude, double longitude) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/img/my_marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(Random().nextInt(100).toString()),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        anchor: Offset(0.5, 0.5),
        position: LatLng(latitude, longitude));

    return marker;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  static List<Icon> getStarsList(double rate, {double size = 18}) {
    var list = <Icon>[];
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(Icon(Icons.star_half, size: size, color: Color(0xFFFFB24D)));
    }
    list.addAll(
        List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
      return Icon(Icons.star_border, size: size, color: Color(0xFFFFB24D));
    }));
    return list;
  }

  // static Widget getPrice(double myPrice, BuildContext context,
  //     {TextStyle style}) {
  //   if (style != null) {
  //     style = style.merge(TextStyle(fontSize: style.fontSize + 2));
  //   }
  //   try {
  //     if (myPrice == 0) {
  //       return Text('-', style: style ?? Theme.of(context).textTheme.subtitle1);
  //     }
  //     return RichText(
  //       softWrap: false,
  //       overflow: TextOverflow.fade,
  //       maxLines: 1,
  //       text: setting.value?.currencyRight != null &&
  //               setting.value?.currencyRight == false
  //           ? TextSpan(
  //               text: setting.value?.defaultCurrency,
  //               style: style ?? Theme.of(context).textTheme.subtitle1,
  //               children: <TextSpan>[
  //                 TextSpan(
  //                     text: myPrice.toStringAsFixed(
  //                             setting.value?.currencyDecimalDigits) ??
  //                         '',
  //                     style: style ?? Theme.of(context).textTheme.subtitle1),
  //               ],
  //             )
  //           : TextSpan(
  //               text: myPrice.toStringAsFixed(
  //                       setting.value?.currencyDecimalDigits) ??
  //                   '',
  //               style: style ?? Theme.of(context).textTheme.subtitle1,
  //               children: <TextSpan>[
  //                 TextSpan(
  //                     text: setting.value?.defaultCurrency,
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: style != null
  //                             ? style.fontSize - 4
  //                             : Theme.of(context).textTheme.subtitle1.fontSize -
  //                                 4)),
  //               ],
  //             ),
  //     );
  //   } catch (e) {
  //     return Text('');
  //   }
  // }

  static String getDistance(double distance, String unit) {
    String _unit = setting.value.distanceUnit;
    if (_unit == 'km') {
      distance *= 1.60934;
    }
    return distance != null ? distance.toStringAsFixed(2) + " " + unit : "";
  }

  static String skipHtml(String htmlString) {
    try {
      var document = parse(htmlString);
      String parsedString = parse(document.body.text).documentElement.text;
      return parsedString;
    } catch (e) {
      return '';
    }
  }

  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: Colors.white.withOpacity(0.85),
          child: CircularLoadingWidget(height: 200),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader?.remove();
      } catch (e) {}
    });
  }

  static String limitString(String text,
      {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) +
        (text.length > limit ? hiddenText : '');
  }

  static String getCreditCardNumber(String number) {
    String result = '';
    if (number != null && number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static Uri getUri(String path) {
    String _path = Uri.parse(GlobalConfiguration().getString('base_url')).path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
    Uri uri = Uri(
        scheme: Uri.parse(GlobalConfiguration().getString('base_url')).scheme,
        host: Uri.parse(GlobalConfiguration().getString('base_url')).host,
        port: Uri.parse(GlobalConfiguration().getString('base_url')).port,
        path: _path + path);
    return uri;
  }

  String trans(String text) {
    switch (text) {
      case "App\\Notifications\\StatusChangedOrder":
        return S.of(context).order_status_changed;
      case "App\\Notifications\\NewOrder":
        return S.of(context).new_order_from_client;
      case "km":
        return S.of(context).km;
      case "mi":
        return S.of(context).mi;
      default:
        return "";
    }
  }

  static MaterialColor customRed = MaterialColor(
    0xffe62337,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xffe62337),
      600: Color(0xffe62337),
      700: Color(0xffe62337),
      800: Color(0xffe62337),
      900: Color(0xffe62337),
    },
  );

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static bool isValidDate(String input) {
    final date = DateTime.parse(input);
    final originalFormatString = toOriginalFormatString(date);
    return input == originalFormatString;
  }

  static String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  double getPrice(Map<String, dynamic> map) {
    double p = 0.0;
    if (map == null || map == {})
      return 0.0;
    else {
      for (Map<String, dynamic> m in map["orderitems"])
        p += m["cost"] == null || m["quantity"] == null
            ? 0.0
            : (m["quantity"] < 1 && m["cost"] < 1
                ? 0.0
                : m["cost"] * m["quantity"]);
      return p;
    }
  }

  static int getCount(Map<String, dynamic> map) {
    int c = 0;
    if (map == null || map == {})
      return 0;
    else {
      for (Map<String, dynamic> m in map["orderitems"])
        c +=
            m["quantity"] == null ? 0 : (m["quantity"] < 1 ? 0 : m["quantity"]);
      return c;
    }
  }

  static int getWordCount(String str) =>
      str == null ? 1 : (str.isEmpty ? 1 : str.trim().split(' ').length);

  static String padSpace(String s) {
    String pad = "";
    for (int i = 10; i > s.length; i++) pad += " ";
    return pad;
  }
}
