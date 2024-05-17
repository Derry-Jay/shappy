import 'package:flutter/material.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/pages/add_cum_edit_address_page.dart';
import 'package:shappy/src/pages/addresses_page.dart';
import 'package:shappy/src/pages/cart_page.dart';
import 'package:shappy/src/pages/category_based_products_page.dart';
import 'package:shappy/src/pages/category_based_stores_page.dart';
import 'package:shappy/src/pages/category_shop_search_page.dart';
import 'package:shappy/src/pages/checkout_failure_page.dart';
import 'package:shappy/src/pages/checkout_success_page.dart';
import 'package:shappy/src/pages/email_signup_page.dart';
import 'package:shappy/src/pages/faq_page.dart';
import 'package:shappy/src/pages/fav_stores_page.dart';
import 'package:shappy/src/pages/home_page.dart';
import 'package:shappy/src/pages/login_screen.dart';
import 'package:shappy/src/pages/main_app_page.dart';
import 'package:shappy/src/pages/mobile_verification.dart';
import 'package:shappy/src/pages/my_profile_page.dart';
import 'package:shappy/src/pages/order_details_page.dart';
import 'package:shappy/src/pages/orders_page.dart';
import 'package:shappy/src/pages/profile_edit_page.dart';
import 'package:shappy/src/pages/search_store_page.dart';
import 'package:shappy/src/pages/logo_page.dart';
import 'package:shappy/src/pages/add_user_detail.dart';
import 'package:shappy/src/pages/seller_success_page.dart';
import 'package:shappy/src/pages/splash_page.dart';
import 'package:shappy/src/pages/store_details_page.dart';
import 'package:shappy/src/pages/user_location_page.dart';
import 'package:shappy/src/pages/seller_confimation_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/Splash':
        return MaterialPageRoute(
            builder: (_) => SplashScreen(args as RouteArgument));
      case '/Logo':
        return MaterialPageRoute(builder: (_) => LogoPage());
      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/OTP':
        return MaterialPageRoute(
            builder: (_) => OTPScreen(args as RouteArgument));
      case '/Store_detail':
        return MaterialPageRoute(builder: (_) => StoreDetail());
      case '/User_location':
        return MaterialPageRoute(
            builder: (_) =>
                UserLocationPage(routeArgument: args as RouteArgument));
      case '/Home':
        return MaterialPageRoute(
            builder: (_) => HomePage(routeArgument: args as RouteArgument));
      case '/registeration':
        return MaterialPageRoute(
            builder: (_) => EmailSignUpPage(args as RouteArgument));
      case '/catbasedstore':
        return MaterialPageRoute(
            builder: (_) =>
                CategoryBasedStoresPage(routeArgument: args as RouteArgument));
      case '/catbasedproducts':
        return MaterialPageRoute(
            builder: (_) => CategoryBasedProductsPage(
                routeArgument: args
                    as RouteArgument)); //routeArgument: args as RouteArgument
      case '/orders':
        return MaterialPageRoute(
            builder: (_) => OrdersPage(routeArgument: args as RouteArgument));
      case '/orderDetails':
        return MaterialPageRoute(
            builder: (_) =>
                OrderDetailsPage(routeArgument: args as RouteArgument));
      case '/myProfile':
        return MaterialPageRoute(builder: (_) => MyProfilePage());
      case '/cart':
        return MaterialPageRoute(builder: (_) => CartPage(true));
      case '/store':
        return MaterialPageRoute(
            builder: (_) => StorePage(routeArgument: args as RouteArgument));
      case '/favStores':
        return MaterialPageRoute(builder: (_) => FavoriteStoresPage());
      case '/personalInfoEdit':
        return MaterialPageRoute(
            builder: (_) => ProfileEditPage(args as RouteArgument));
      case '/address':
        return MaterialPageRoute(
            builder: (_) =>
                AddressesPage(routeArgument: args as RouteArgument));
      case '/app_page':
        return MaterialPageRoute(
            builder: (_) => MainAppTabsPage(args as RouteArgument));
      case '/Faq':
        return MaterialPageRoute(
            builder: (_) => FrequentlyAskedQuestionsPage());
      case '/searchStore':
        return MaterialPageRoute(builder: (_) => SearchStorePage());
      case '/addAndEditAddress':
        return MaterialPageRoute(
            builder: (_) => AddAndEditAddressPage(args as RouteArgument));
      case '/checkoutSuccess':
        return MaterialPageRoute(builder: (_) => CheckoutSuccessPage());
      case '/categoryBasedStoreSearch':
        return MaterialPageRoute(
            builder: (_) => SearchCategoryStorePage(args as RouteArgument));
      case '/checkoutFailure':
        return MaterialPageRoute(
            builder: (_) => CheckOutFailurePage(args as String));
      case '/sellerConfirm':
        return MaterialPageRoute(
            builder: (_) => SellerConfirmationPage(args as RouteArgument));
      case '/sellerSuccess':
        return MaterialPageRoute(builder: (context) => SellerSuccessPage());
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(
            builder: (_) =>
                Scaffold(body: SafeArea(child: Text('Route Error'))));
    }
  }
}
