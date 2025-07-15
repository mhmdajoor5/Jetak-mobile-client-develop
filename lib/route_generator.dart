import 'package:flutter/material.dart';
import 'package:restaurantcustomer/src/pages/auth/signup/SignUpEmailPasswordScreen.dart';
import 'package:restaurantcustomer/src/pages/auth/signup/SignUpPhoneNumberScreen.dart';
import 'package:restaurantcustomer/src/pages/auth/signup/SignUpVerificationScreen.dart';
import 'package:restaurantcustomer/src/pages/auth/signup/sign_up_name_screen.dart';
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
import 'src/pages/test_notifications.dart';
import 'src/pages/notifications.dart';
import 'src/controllers/home_controller.dart';
// Import the new address pages
import 'src/pages/new_address/AddressDetailsPage.dart';
import 'src/pages/new_address/DeliveryAddressFormPage.dart';
import 'src/models/address.dart';

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
      case '/TestNotifications':
        return MaterialPageRoute(builder: (_) => TestNotificationsPage());
      case '/Notifications':
        return MaterialPageRoute(builder: (_) => NotificationsWidget());
      case '/SignUp':
      case '/MobileVerification':
      // case '/MobileVerification2':
      //   return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/MobileVerification2':
         return MaterialPageRoute(builder: (_) => SignUpNameScreen());
      case '/SignUpEmailPassword':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => SignUpEmailPasswordScreen(
            firstName: args['firstName'] ?? '',
            lastName: args['lastName'] ?? '',
          ),
        );

      case '/SignUpPhoneNumber':
        final args = settings.arguments as Map<String, String>? ?? {};
        return MaterialPageRoute(
          builder: (_) => SignUpPhoneNumberScreen(
            firstName: args['firstName'] ?? '',
            lastName: args['lastName'] ?? '',
            email: args['email'] ?? '',
            password: args['password'] ?? '',
          ),
        );

      case '/SignUpVerificationScreen':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => SignUpVerificationScreen(
            verificationId: args['verificationId'] ?? '',
            phoneNumber: args['phoneNumber'] ?? '',
          ),
        );

      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());

      // case '/Login':
      //    return MaterialPageRoute(builder: (_) => WelcomePage());
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
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Container(),
          transitionDuration: Duration(milliseconds: 400),
          reverseTransitionDuration: Duration(milliseconds: 300),
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // إنشاء animation للخلفية (fade)
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ));
            
            // إنشاء animation للـ bottom sheet (slide from bottom)
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            
            return SlideTransition(
              position: slideAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    // إذا كان السحب لأسفل أكبر من 5 بكسل، قم بإغلاق الـ bottom sheet
                    if (details.delta.dy > 5) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      child: FoodWidget(
                        routeArgument: args is RouteArgument ? args : RouteArgument(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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
      case '/DeliveryAddressForm':
        final Map<String, dynamic> arguments = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DeliveryAddressFormPage(
            address: arguments['address'] as Address,
            onChanged: arguments['onChanged'] as Function(Address),
          ),
        );
      case '/AddressDetails':
        final String address = args as String;
        return MaterialPageRoute(
          builder: (_) => AddressDetailsPage(address: address),
        );
      case '/DeliveryPickup':
        return MaterialPageRoute(
          builder: (_) => DeliveryPickupWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/cart':
        return MaterialPageRoute(
          builder: (_) => CartWidget(
            routeArgument: args is RouteArgument ? args : RouteArgument(),
          ),
        );
      case '/Checkout':
        return MaterialPageRoute(builder: (_) => CheckoutWidget());
      // Cash payment option disabled
      // case '/CashOnDelivery':
      //   return MaterialPageRoute(
      //     builder: (_) => OrderSuccessWidget(
      //       routeArgument: RouteArgument(param: 'Cash on Delivery'),
      //     ),
      //   );
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
