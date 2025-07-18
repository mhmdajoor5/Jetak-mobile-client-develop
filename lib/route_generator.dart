import 'package:flutter/material.dart';
import 'src/controllers/delivery_pickup_controller.dart';
import 'src/models/credit_card.dart';
import 'src/pages/Home/OffersNearYouPage.dart' show OffersNearYouPage;
import 'src/pages/icredit_payment_page.dart';

import 'src/models/restaurant.dart';
import 'src/models/route_argument.dart';
import 'src/pages/TrackingModernWidget.dart' show TrackingModernWidget;
import 'src/pages/add_new_card.dart';
import 'src/pages/auth/login.dart';
import 'src/pages/bottom_nav_bar_modules/profile.dart';
import 'src/pages/cart.dart';
import 'src/pages/category.dart';
import 'src/pages/chat.dart';
import 'src/pages/checkout.dart';
import 'src/pages/debug.dart';
import 'src/pages/delivery_addresses.dart';
import 'src/pages/delivery_pickup.dart';
import 'src/pages/details.dart';
import 'src/pages/favorites.dart';
import 'src/pages/food.dart';
import 'src/pages/forget_password.dart';
import 'src/pages/help.dart';
import 'src/pages/menu_list.dart';
import 'src/pages/new_payment.dart';
import 'src/pages/order_success.dart';
import 'src/pages/bottom_nav_bar/pages.dart';
import 'src/pages/payment_methods.dart';
import 'src/pages/paypal_payment.dart';
import 'src/pages/razorpay_payment.dart';
import 'src/pages/reviews.dart';
import 'src/pages/settings.dart';
import 'src/pages/auth/signup.dart';
import 'src/pages/splash_screen.dart';
import 'src/controllers/home_controller.dart';

class RouteGenerator {
  static final HomeController homeController = HomeController();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/Debug':
        return MaterialPageRoute(
          builder: (_) => DebugWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/Payment':
        return MaterialPageRoute(builder: (_) => Payment());
      case '/Splash':
        return MaterialPageRoute(builder: (_) => SplashScreen(con: homeController));
      case '/SignUp':
      case '/MobileVerification':
      case '/MobileVerification2':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      case '/Profile':
        return MaterialPageRoute(builder: (_) => ProfileWidget());
      case '/ForgetPassword':
        return MaterialPageRoute(builder: (_) => ForgetPasswordWidget());
      case '/Pages':
        return MaterialPageRoute(
          builder: (_) => PagesWidget(currentTab: args),
        );
      case '/Favorites':
        return MaterialPageRoute(builder: (_) => FavoritesWidget());
      case '/Chat':
        return MaterialPageRoute(
          builder: (_) => ChatWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      // case '/Details':
      //   return MaterialPageRoute(
      //
      //     builder: (_) => DetailsWidget(currentTab: args),
      //   );
      case '/Details':
        return MaterialPageRoute(
          builder: (_) {
            // Handle case where args is already a RouteArgument
            if (args is RouteArgument) {
              return DetailsWidget(routeArgument: args);
            }
            // Handle case where args is a Restaurant
            else if (args is Restaurant) {
              return DetailsWidget(
                routeArgument: RouteArgument(param: args),
              );
            }
            // Fallback for other cases
            else {
              return DetailsWidget(
                routeArgument: RouteArgument(param: null),
              );
            }
          },
        );
      case '/Menu':
        return MaterialPageRoute(
          builder: (_) => MenuWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/Food':
        return MaterialPageRoute(
          builder: (_) => FoodWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/Category':
        return MaterialPageRoute(
          builder: (_) => CategoryWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/Cart':
        return MaterialPageRoute(
          builder: (_) => CartWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      // case '/Tracking':
      //   return MaterialPageRoute(
      //     builder: (_) => TrackingWidget(
      //       routeArgument: args is RouteArgument ? args : RouteArgument(),
      //     ),
      //   );
      case '/Tracking':
        final args = settings.arguments as RouteArgument?;
        return MaterialPageRoute(
          builder: (_) => TrackingModernWidget(routeArgument: args),
        );


      case '/Reviews':
        return MaterialPageRoute(
          builder: (_) => ReviewsWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/PaymentMethod':
        return MaterialPageRoute(
          builder: (_) => PaymentMethodsWidget(routeArgument: args),
        );
      case '/DeliveryAddresses':
        final List<dynamic> arguments = args is List ? args : [false, DeliveryPickupController()];
        return MaterialPageRoute(
          builder: (_) => DeliveryAddressesWidget(
            shouldChooseDeliveryHere: arguments[0] as bool,
            conDeliverPickupController: arguments[1] as DeliveryPickupController,
          ),
        );
      case '/DeliveryPickup':
        return MaterialPageRoute(
          builder: (_) => DeliveryPickupWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/Checkout':
        return MaterialPageRoute(builder: (_) => CheckoutWidget());
      case '/CashOnDelivery':
        return MaterialPageRoute(
          builder: (_) => OrderSuccessWidget(
            routeArgument: RouteArgument(param: 'Cash on Delivery'),
          ),
        );
      case '/PayOnPickup':
        return MaterialPageRoute(
          builder: (_) => OrderSuccessWidget(
            routeArgument: RouteArgument(param: 'Pay on Pickup'),
          ),
        );
      case '/PayPal':
        return MaterialPageRoute(
          builder: (_) => PayPalPaymentWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/iCredit':
        return MaterialPageRoute(
          builder: (_) => ICreditPaymentWidget(routeArgument: args),
        );
      case '/add_new_card':
        return MaterialPageRoute<CreditCard>(
          builder: (_) => AddNewCardWidget(),
        );
      case '/OffersNearYou':
        return MaterialPageRoute(builder: (_) => OffersNearYouPage());
      case '/RazorPay':
        return MaterialPageRoute(
          builder: (_) => RazorPayPaymentWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/OrderSuccess':
        return MaterialPageRoute(
          builder: (_) => OrderSuccessWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      // case '/Languages':
      //   return MaterialPageRoute(builder: (_) => LanguagesWidget());
      case '/Help':
        return MaterialPageRoute(builder: (_) => HelpWidget());
      case '/Settings':
        return MaterialPageRoute(builder: (_) => SettingsWidget());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: SafeArea(child: Text('Route Error')),
          ),
        );
    }
  }
}
