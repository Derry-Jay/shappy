import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/helpers/helper.dart';
import 'package:shappy/src/models/favoritestore.dart';
import 'package:shappy/src/models/store_category.dart';
import 'package:shappy/src/models/user.dart';
import 'package:shappy/src/repository/store_repository.dart';
import 'package:shappy/src/repository/user_repository.dart';
import 'package:toast/toast.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart';

class HomeController extends ControllerMVC {
  User user;
  OverlayEntry loader;
  bool loading = false;
  GlobalKey<ScaffoldState> scaffoldKey;
  List<CameraDescription> cameras;
  CameraController controller;
  List<FavoriteStore> favoriteStore;
  List<StoreCategory> category = <StoreCategory>[];
  HomeController() {
    loader = Helper.overlayLoader(context);
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    setData();
  }

  void setData() async {
    final stream = await getUserDetails();
    if (stream != null)
      setState(() => user = stream);
    else
      setState(() => user = User());
  }

  Future<void> listenForFavoriteStore() async {
    user = await getUserDetails();
    final stream = await getFavoriteStore(user);
    if (stream != null) {
      setState(() => favoriteStore = stream);
      // if (favoriteStore.isEmpty)
      //   Toast.show("You Haven't Added any Store as Favourite", context,
      //       duration: Toast.LENGTH_LONG);
    } else {
      setState(() => favoriteStore = <FavoriteStore>[]);
      Toast.show("Unable to Fetch Your Favourite Stores", context,
          duration: Toast.LENGTH_LONG);
    }
  }

  Future<void> listenForHomeCategories() async {
    final List<StoreCategory> stream =
        await getShopCategories(currentUser.value);
    setState(() => category = stream);
  }

  void waitUntilAddFavStore(String shopID, User user) async {
    final value = await addFavoriteStore(shopID, user);
    if (value != null) {
      if ((value["status"] != null ? value["status"] : false) &&
          !(value["error"] != null ? value["error"] : true)) {
        await listenForFavoriteStore();
        Toast.show(value["message"], context, duration: Toast.LENGTH_LONG);
      } else
        Toast.show("Store is not Found", context, duration: Toast.LENGTH_LONG);
    } else
      Toast.show("Error", context, duration: Toast.LENGTH_LONG);
  }

  void pushNotificationControl(Map<String, dynamic> body) async {
    await pushToken(body).then((value) {
      if (value != null && value["success"]) {
        print(value);
        // Toast.show(value["message"], context, duration: Toast.LENGTH_LONG);
      }
    });
  }

  void waitUntilRemoveFavStore(String favID) async {
    final value = await removeFavoriteStore(favID);
    if (value != null && value["status"] && !value["error"]) {
      Toast.show(value["message"], context, duration: Toast.LENGTH_LONG);
      await listenForFavoriteStore();
      Navigator.pop(context);
    } else
      Toast.show("Error", context, duration: Toast.LENGTH_LONG);
  }

  void getCamPerm() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) async {
      setState(() {});
      var status = await Permission.camera.status;
      if (status.isGranted) {
        final val = await scan();
        waitUntilAddFavStore(val, user);
      }
    });
  }
}
