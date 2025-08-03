import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('he'),
  ];

  /// No description provided for @searchForRestaurantsOrFoods.
  ///
  /// In en, this message translates to:
  /// **'Search for food, chef, etc'**
  String get searchForRestaurantsOrFoods;

  /// No description provided for @topRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Top Restaurants'**
  String get topRestaurants;

  /// No description provided for @orderedByNearbyFirst.
  ///
  /// In en, this message translates to:
  /// **'Ordered by Nearby first'**
  String get orderedByNearbyFirst;

  /// No description provided for @trendingThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending This Week'**
  String get trendingThisWeek;

  /// No description provided for @doubleClickOnTheFoodToAddItToTheCart.
  ///
  /// In en, this message translates to:
  /// **'Double click on the food to add it to the cart'**
  String get doubleClickOnTheFoodToAddItToTheCart;

  /// No description provided for @foodCategories.
  ///
  /// In en, this message translates to:
  /// **'Food Categories'**
  String get foodCategories;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @recentReviews.
  ///
  /// In en, this message translates to:
  /// **'Recent Reviews'**
  String get recentReviews;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @selectYourPreferredLanguages.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred languages'**
  String get selectYourPreferredLanguages;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order Id'**
  String get orderId;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentMode;

  /// No description provided for @selectYourPreferredPaymentMode.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred payment mode'**
  String get selectYourPreferredPaymentMode;

  /// No description provided for @orCheckoutWith.
  ///
  /// In en, this message translates to:
  /// **'Or Checkout With'**
  String get orCheckoutWith;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time:'**
  String get estimatedTime;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @featuredFoods.
  ///
  /// In en, this message translates to:
  /// **'Featured Foods'**
  String get featuredFoods;

  /// No description provided for @whatTheySay.
  ///
  /// In en, this message translates to:
  /// **'What They Say ?'**
  String get whatTheySay;

  /// No description provided for @favoriteFoods.
  ///
  /// In en, this message translates to:
  /// **'Favorite Foods'**
  String get favoriteFoods;

  /// No description provided for @g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get g;

  /// No description provided for @extras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;

  /// No description provided for @selectExtrasToAddThemOnTheFood.
  ///
  /// In en, this message translates to:
  /// **'Select extras to add them on the food'**
  String get selectExtrasToAddThemOnTheFood;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Faq'**
  String get faq;

  /// No description provided for @helpAndSupports.
  ///
  /// In en, this message translates to:
  /// **'Help & Supports'**
  String get helpAndSupports;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @iForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'I forgot password ?'**
  String get iForgotPassword;

  /// No description provided for @iDontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have an account?'**
  String get iDontHaveAnAccount;

  /// No description provided for @mapsExplorer.
  ///
  /// In en, this message translates to:
  /// **'Maps Explorer'**
  String get mapsExplorer;

  /// No description provided for @allMenu.
  ///
  /// In en, this message translates to:
  /// **'All Menu'**
  String get allMenu;

  /// No description provided for @longpressOnTheFoodToAddSuplements.
  ///
  /// In en, this message translates to:
  /// **'Longpress on the food to add suplements'**
  String get longpressOnTheFoodToAddSuplements;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @yourOrderHasBeenSuccessfullySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your order has been successfully submitted!'**
  String get yourOrderHasBeenSuccessfullySubmitted;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'TAX'**
  String get tax;

  /// No description provided for @my_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get my_orders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @payment_options.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get payment_options;

  /// No description provided for @cash_on_delivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cash_on_delivery;

  /// No description provided for @paypal_payment.
  ///
  /// In en, this message translates to:
  /// **'PayPal Payment'**
  String get paypal_payment;

  /// No description provided for @recent_orders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recent_orders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profile_settings;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get full_name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @payments_settings.
  ///
  /// In en, this message translates to:
  /// **'Payments Settings'**
  String get payments_settings;

  /// No description provided for @default_credit_card.
  ///
  /// In en, this message translates to:
  /// **'Default Credit Card'**
  String get default_credit_card;

  /// No description provided for @app_settings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get app_settings;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @lets_start_with_register.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start with register!'**
  String get lets_start_with_register;

  /// No description provided for @should_be_more_than_3_letters.
  ///
  /// In en, this message translates to:
  /// **'Should be more than 3 letters'**
  String get should_be_more_than_3_letters;

  /// No description provided for @john_doe.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get john_doe;

  /// No description provided for @should_be_a_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Should be a valid email'**
  String get should_be_a_valid_email;

  /// No description provided for @should_be_more_than_6_letters.
  ///
  /// In en, this message translates to:
  /// **'Should be more than 6 letters'**
  String get should_be_more_than_6_letters;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @i_have_account_back_to_login.
  ///
  /// In en, this message translates to:
  /// **'I have account? Back to login'**
  String get i_have_account_back_to_login;

  /// No description provided for @multirestaurants.
  ///
  /// In en, this message translates to:
  /// **'Multi-Restaurants'**
  String get multirestaurants;

  /// No description provided for @tracking_order.
  ///
  /// In en, this message translates to:
  /// **'Tracking Order'**
  String get tracking_order;

  /// No description provided for @discover__explorer.
  ///
  /// In en, this message translates to:
  /// **'Discover & Explorer'**
  String get discover__explorer;

  /// No description provided for @you_can_discover_restaurants.
  ///
  /// In en, this message translates to:
  /// **'You can discover restaurants & fastfood arround you and choose you best meal after few minutes we prepare and delivere it for you'**
  String get you_can_discover_restaurants;

  /// No description provided for @reset_cart.
  ///
  /// In en, this message translates to:
  /// **'Reset Cart?'**
  String get reset_cart;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @shopping_cart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shopping_cart;

  /// No description provided for @verify_your_quantity_and_click_checkout.
  ///
  /// In en, this message translates to:
  /// **'Verify your quantity and click checkout'**
  String get verify_your_quantity_and_click_checkout;

  /// No description provided for @lets_start_with_login.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start with Login!'**
  String get lets_start_with_login;

  /// No description provided for @should_be_more_than_3_characters.
  ///
  /// In en, this message translates to:
  /// **'Should be more than 3 characters'**
  String get should_be_more_than_3_characters;

  /// No description provided for @you_must_add_foods_of_the_same_restaurants_choose_one.
  ///
  /// In en, this message translates to:
  /// **'You must add foods of the same restaurants choose one restaurants only!'**
  String get you_must_add_foods_of_the_same_restaurants_choose_one;

  /// No description provided for @reset_your_cart_and_order_meals_form_this_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Reset your cart and order meals form this restaurant'**
  String get reset_your_cart_and_order_meals_form_this_restaurant;

  /// No description provided for @keep_your_old_meals_of_this_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Keep your old meals of this restaurant'**
  String get keep_your_old_meals_of_this_restaurant;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @application_preferences.
  ///
  /// In en, this message translates to:
  /// **'Application Preferences'**
  String get application_preferences;

  /// No description provided for @help__support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help__support;

  /// No description provided for @pending_payment.
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get pending_payment;

  /// No description provided for @light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get light_mode;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get log_out;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @dont_have_any_item_in_your_cart.
  ///
  /// In en, this message translates to:
  /// **'D\'ont have any item in your cart'**
  String get dont_have_any_item_in_your_cart;

  /// No description provided for @start_exploring.
  ///
  /// In en, this message translates to:
  /// **'Start Exploring'**
  String get start_exploring;

  /// No description provided for @dont_have_any_item_in_the_notification_list.
  ///
  /// In en, this message translates to:
  /// **'D\'ont have any item in the notification list'**
  String get dont_have_any_item_in_the_notification_list;

  /// No description provided for @payment_settings.
  ///
  /// In en, this message translates to:
  /// **'Payment Settings'**
  String get payment_settings;

  /// No description provided for @not_a_valid_number.
  ///
  /// In en, this message translates to:
  /// **'Not a valid number'**
  String get not_a_valid_number;

  /// No description provided for @not_a_valid_date.
  ///
  /// In en, this message translates to:
  /// **'Not a valid date'**
  String get not_a_valid_date;

  /// No description provided for @not_a_valid_cvc.
  ///
  /// In en, this message translates to:
  /// **'Not a valid CVC'**
  String get not_a_valid_cvc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @not_a_valid_full_name.
  ///
  /// In en, this message translates to:
  /// **'Not a valid full name'**
  String get not_a_valid_full_name;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @not_a_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Not a valid email'**
  String get not_a_valid_email;

  /// No description provided for @not_a_valid_phone.
  ///
  /// In en, this message translates to:
  /// **'Not a valid phone'**
  String get not_a_valid_phone;

  /// No description provided for @not_a_valid_address.
  ///
  /// In en, this message translates to:
  /// **'Not a valid address'**
  String get not_a_valid_address;

  /// No description provided for @not_a_valid_biography.
  ///
  /// In en, this message translates to:
  /// **'Not a valid biography'**
  String get not_a_valid_biography;

  /// No description provided for @your_biography.
  ///
  /// In en, this message translates to:
  /// **'Your biography'**
  String get your_biography;

  /// No description provided for @your_address.
  ///
  /// In en, this message translates to:
  /// **'Your Address'**
  String get your_address;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @recentsSearch.
  ///
  /// In en, this message translates to:
  /// **'Recents Search'**
  String get recentsSearch;

  /// No description provided for @verifyYourInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Verify your internet connection'**
  String get verifyYourInternetConnection;

  /// No description provided for @cartsRefreshedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Carts refreshed successfully'**
  String get cartsRefreshedSuccessfully;

  /// No description provided for @theFoodWasRemovedFromYourCart.
  ///
  /// In en, this message translates to:
  /// **'The {foodname} was removed from your cart'**
  String theFoodWasRemovedFromYourCart(Object foodname);

  /// No description provided for @categoryRefreshedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category refreshed successfully'**
  String get categoryRefreshedSuccessfully;

  /// No description provided for @notifications_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Notifications refreshed successfully'**
  String get notifications_refreshed_successfuly;

  /// No description provided for @order_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Order refreshed successfully'**
  String get order_refreshed_successfuly;

  /// No description provided for @orders_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Orders refreshed successfully'**
  String get orders_refreshed_successfuly;

  /// No description provided for @restaurant_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Restaurant refreshed successfully'**
  String get restaurant_refreshed_successfuly;

  /// No description provided for @profile_settings_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Profile settings updated successfully'**
  String get profile_settings_updated_successfully;

  /// No description provided for @payment_settings_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Payment settings updated successfully'**
  String get payment_settings_updated_successfully;

  /// No description provided for @tracking_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Tracking refreshed successfully'**
  String get tracking_refreshed_successfuly;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @wrong_email_or_password.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get wrong_email_or_password;

  /// No description provided for @addresses_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Addresses refreshed successfuly'**
  String get addresses_refreshed_successfuly;

  /// No description provided for @delivery_addresses.
  ///
  /// In en, this message translates to:
  /// **'Delivery Addresses'**
  String get delivery_addresses;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @new_address_added_successfully.
  ///
  /// In en, this message translates to:
  /// **'New Address added successfully'**
  String get new_address_added_successfully;

  /// No description provided for @the_address_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'The address updated successfully'**
  String get the_address_updated_successfully;

  /// No description provided for @long_press_to_edit_item_swipe_item_to_delete_it.
  ///
  /// In en, this message translates to:
  /// **'Long press to edit item, swipe item to delete it'**
  String get long_press_to_edit_item_swipe_item_to_delete_it;

  /// No description provided for @add_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Add Delivery Address'**
  String get add_delivery_address;

  /// No description provided for @home_address.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get home_address;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @hint_full_address.
  ///
  /// In en, this message translates to:
  /// **'12 Street, City 21663, Country'**
  String get hint_full_address;

  /// No description provided for @full_address.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get full_address;

  /// No description provided for @email_to_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Email to reset password'**
  String get email_to_reset_password;

  /// No description provided for @send_password_reset_link.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get send_password_reset_link;

  /// No description provided for @i_remember_my_password_return_to_login.
  ///
  /// In en, this message translates to:
  /// **'I remember my password return to login'**
  String get i_remember_my_password_return_to_login;

  /// No description provided for @your_reset_link_has_been_sent_to_your_email.
  ///
  /// In en, this message translates to:
  /// **'Your reset link has been sent to your email'**
  String get your_reset_link_has_been_sent_to_your_email;

  /// No description provided for @error_verify_email_settings.
  ///
  /// In en, this message translates to:
  /// **'Error! Verify email settings'**
  String get error_verify_email_settings;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @you_must_signin_to_access_to_this_section.
  ///
  /// In en, this message translates to:
  /// **'You must sign-in to access to this section'**
  String get you_must_signin_to_access_to_this_section;

  /// No description provided for @tell_us_about_this_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Tell us about this restaurant'**
  String get tell_us_about_this_restaurant;

  /// No description provided for @how_would_you_rate_this_restaurant_.
  ///
  /// In en, this message translates to:
  /// **'How would you rate this restaurant ?'**
  String get how_would_you_rate_this_restaurant_;

  /// No description provided for @tell_us_about_this_food.
  ///
  /// In en, this message translates to:
  /// **'Tell us about this food'**
  String get tell_us_about_this_food;

  /// No description provided for @the_restaurant_has_been_rated_successfully.
  ///
  /// In en, this message translates to:
  /// **'The restaurant has been rated successfully'**
  String get the_restaurant_has_been_rated_successfully;

  /// No description provided for @the_food_has_been_rated_successfully.
  ///
  /// In en, this message translates to:
  /// **'The food has been rated successfully'**
  String get the_food_has_been_rated_successfully;

  /// No description provided for @reviews_refreshed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Reviews refreshed successfully!'**
  String get reviews_refreshed_successfully;

  /// No description provided for @delivery_fee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get delivery_fee;

  /// No description provided for @order_status_changed.
  ///
  /// In en, this message translates to:
  /// **'Order status changed'**
  String get order_status_changed;

  /// No description provided for @new_order_from_client.
  ///
  /// In en, this message translates to:
  /// **'New order from client'**
  String get new_order_from_client;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @delivery_or_pickup.
  ///
  /// In en, this message translates to:
  /// **'Delivery or Pickup'**
  String get delivery_or_pickup;

  /// No description provided for @payment_card_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Payment card updated successfully'**
  String get payment_card_updated_successfully;

  /// No description provided for @deliverable.
  ///
  /// In en, this message translates to:
  /// **'Deliverable'**
  String get deliverable;

  /// No description provided for @not_deliverable.
  ///
  /// In en, this message translates to:
  /// **'Not Deliverable'**
  String get not_deliverable;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @mi.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get mi;

  /// No description provided for @delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get delivery_address;

  /// No description provided for @current_location.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get current_location;

  /// No description provided for @delivery_address_removed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address removed successfully'**
  String get delivery_address_removed_successfully;

  /// No description provided for @add_new_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Add new delivery address'**
  String get add_new_delivery_address;

  /// No description provided for @restaurants_near_to_your_current_location.
  ///
  /// In en, this message translates to:
  /// **'Restaurants near to your current location'**
  String get restaurants_near_to_your_current_location;

  /// No description provided for @restaurants_near_to.
  ///
  /// In en, this message translates to:
  /// **'Restaurants near to'**
  String get restaurants_near_to;

  /// No description provided for @near_to.
  ///
  /// In en, this message translates to:
  /// **'Near to'**
  String get near_to;

  /// No description provided for @near_to_your_current_location.
  ///
  /// In en, this message translates to:
  /// **'Near to your current location'**
  String get near_to_your_current_location;

  /// No description provided for @pickup_your_food_from_the_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Pickup your food from the restaurant'**
  String get pickup_your_food_from_the_restaurant;

  /// No description provided for @confirm_your_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Confirm your delivery address'**
  String get confirm_your_delivery_address;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @opened_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Opened Restaurants'**
  String get opened_restaurants;

  /// No description provided for @fields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get fields;

  /// No description provided for @this_food_was_added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'This food was added to cart'**
  String get this_food_was_added_to_cart;

  /// No description provided for @foods_result.
  ///
  /// In en, this message translates to:
  /// **'Foods result'**
  String get foods_result;

  /// No description provided for @foods_results.
  ///
  /// In en, this message translates to:
  /// **'Foods Results'**
  String get foods_results;

  /// No description provided for @restaurants_results.
  ///
  /// In en, this message translates to:
  /// **'Restaurants Results'**
  String get restaurants_results;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @this_restaurant_is_closed_.
  ///
  /// In en, this message translates to:
  /// **'This restaurant is closed !'**
  String get this_restaurant_is_closed_;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @how_would_you_rate_this_restaurant.
  ///
  /// In en, this message translates to:
  /// **'How would you rate this restaurant ?'**
  String get how_would_you_rate_this_restaurant;

  /// No description provided for @click_on_the_stars_below_to_leave_comments.
  ///
  /// In en, this message translates to:
  /// **'Click on the stars below to leave comments'**
  String get click_on_the_stars_below_to_leave_comments;

  /// No description provided for @click_to_confirm_your_address_and_pay_or_long_press.
  ///
  /// In en, this message translates to:
  /// **'Click to confirm your address and pay or Long press to edit your address'**
  String get click_to_confirm_your_address_and_pay_or_long_press;

  /// No description provided for @visa_card.
  ///
  /// In en, this message translates to:
  /// **'Visa Card'**
  String get visa_card;

  /// No description provided for @iCredit.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get iCredit;

  /// No description provided for @mastercard.
  ///
  /// In en, this message translates to:
  /// **'MasterCard'**
  String get mastercard;

  /// No description provided for @paypal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// No description provided for @pay_on_pickup.
  ///
  /// In en, this message translates to:
  /// **'Pay on Pickup'**
  String get pay_on_pickup;

  /// No description provided for @click_to_pay_with_your_visa_card.
  ///
  /// In en, this message translates to:
  /// **'Click to pay with your Visa Card'**
  String get click_to_pay_with_your_visa_card;

  /// No description provided for @click_to_pay_with_icredit.
  ///
  /// In en, this message translates to:
  /// **'Click to pay with your iCredit'**
  String get click_to_pay_with_icredit;

  /// No description provided for @click_to_pay_with_your_mastercard.
  ///
  /// In en, this message translates to:
  /// **'Click to pay with your MasterCard'**
  String get click_to_pay_with_your_mastercard;

  /// No description provided for @click_to_pay_with_your_paypal_account.
  ///
  /// In en, this message translates to:
  /// **'Click to pay with your PayPal account'**
  String get click_to_pay_with_your_paypal_account;

  /// No description provided for @click_to_pay_cash_on_delivery.
  ///
  /// In en, this message translates to:
  /// **'Click to pay cash on delivery'**
  String get click_to_pay_cash_on_delivery;

  /// No description provided for @click_to_pay_on_pickup.
  ///
  /// In en, this message translates to:
  /// **'Click to pay on pickup'**
  String get click_to_pay_on_pickup;

  /// No description provided for @this_email_account_exists.
  ///
  /// In en, this message translates to:
  /// **'This email account exists'**
  String get this_email_account_exists;

  /// No description provided for @this_account_not_exist.
  ///
  /// In en, this message translates to:
  /// **'This account not exist'**
  String get this_account_not_exist;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'CARD NUMBER'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'EXPIRY DATE'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @yourCreditCardNotValid.
  ///
  /// In en, this message translates to:
  /// **'Your credit card not valid'**
  String get yourCreditCardNotValid;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @orderingFromAnotherRestaurantWillClearYourCart.
  ///
  /// In en, this message translates to:
  /// **'Ordering from another restaurant will clear your current cart. Do you want to continue?'**
  String get orderingFromAnotherRestaurantWillClearYourCart;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @exp_date.
  ///
  /// In en, this message translates to:
  /// **'Exp Date'**
  String get exp_date;

  /// No description provided for @cvc.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get cvc;

  /// No description provided for @cuisines.
  ///
  /// In en, this message translates to:
  /// **'Cuisines'**
  String get cuisines;

  /// No description provided for @favorites_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Favorites refreshed successfully'**
  String get favorites_refreshed_successfuly;

  /// No description provided for @completeYourProfileDetailsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile details to continue'**
  String get completeYourProfileDetailsToContinue;

  /// No description provided for @faqsRefreshedSuccessfuly.
  ///
  /// In en, this message translates to:
  /// **'Faqs refreshed successfully'**
  String get faqsRefreshedSuccessfuly;

  /// No description provided for @thisFoodWasAddedToFavorite.
  ///
  /// In en, this message translates to:
  /// **'This food was added to favorite'**
  String get thisFoodWasAddedToFavorite;

  /// No description provided for @thisFoodWasRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'This food was removed from favorites'**
  String get thisFoodWasRemovedFromFavorites;

  /// No description provided for @cannot_add_from_different_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Cannot add products from different restaurants in the same order. Do you want to clear the cart and add products from this restaurant?'**
  String get cannot_add_from_different_restaurant;

  /// No description provided for @foodRefreshedSuccessfuly.
  ///
  /// In en, this message translates to:
  /// **'Food refreshed successfully'**
  String get foodRefreshedSuccessfuly;

  /// No description provided for @deliveryAddressOutsideTheDeliveryRangeOfThisRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Delivery address outside the delivery range of this restaurants.'**
  String get deliveryAddressOutsideTheDeliveryRangeOfThisRestaurants;

  /// No description provided for @thisRestaurantNotSupportDeliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'This restaurant not support delivery method.'**
  String get thisRestaurantNotSupportDeliveryMethod;

  /// No description provided for @oneOrMoreFoodsInYourCartNotDeliverable.
  ///
  /// In en, this message translates to:
  /// **'One or more foods in your cart not deliverable.'**
  String get oneOrMoreFoodsInYourCartNotDeliverable;

  /// No description provided for @deliveryMethodNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Delivery method not allowed!'**
  String get deliveryMethodNotAllowed;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @youDontHaveAnyOrder.
  ///
  /// In en, this message translates to:
  /// **'You don\'t  have any order'**
  String get youDontHaveAnyOrder;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @areYouSureYouWantToCancelThisOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get areYouSureYouWantToCancelThisOrder;

  /// No description provided for @orderThisorderidHasBeenCanceled.
  ///
  /// In en, this message translates to:
  /// **'Order: #{id} has been canceled'**
  String orderThisorderidHasBeenCanceled(Object id);

  /// No description provided for @clickOnTheFoodToGetMoreDetailsAboutIt.
  ///
  /// In en, this message translates to:
  /// **'Click on the food to get more details about it'**
  String get clickOnTheFoodToGetMoreDetailsAboutIt;

  /// No description provided for @razorpayPayment.
  ///
  /// In en, this message translates to:
  /// **'RazorPay Payment'**
  String get razorpayPayment;

  /// No description provided for @razorpay.
  ///
  /// In en, this message translates to:
  /// **'RazorPay'**
  String get razorpay;

  /// No description provided for @clickToPayWithRazorpayMethod.
  ///
  /// In en, this message translates to:
  /// **'Click to pay with RazorPay method'**
  String get clickToPayWithRazorpayMethod;

  /// No description provided for @tapAgainToLeave.
  ///
  /// In en, this message translates to:
  /// **'Tap again to leave'**
  String get tapAgainToLeave;

  /// No description provided for @validCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Valid Coupon'**
  String get validCouponCode;

  /// No description provided for @invalidCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Coupon'**
  String get invalidCouponCode;

  /// No description provided for @haveCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Have Coupon Code?'**
  String get haveCouponCode;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @youDontHaveAnyConversations.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any conversations'**
  String get youDontHaveAnyConversations;

  /// No description provided for @newMessageFrom.
  ///
  /// In en, this message translates to:
  /// **'New message from'**
  String get newMessageFrom;

  /// No description provided for @forMoreDetailsPleaseChatWithOurManagers.
  ///
  /// In en, this message translates to:
  /// **'For more details, please chat with our managers'**
  String get forMoreDetailsPleaseChatWithOurManagers;

  /// No description provided for @signinToChatWithOurManagers.
  ///
  /// In en, this message translates to:
  /// **'Sign-In to chat with our managers'**
  String get signinToChatWithOurManagers;

  /// No description provided for @typeToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Type to start chat'**
  String get typeToStartChat;

  /// No description provided for @makeItDefault.
  ///
  /// In en, this message translates to:
  /// **'Make it default'**
  String get makeItDefault;

  /// No description provided for @notValidAddress.
  ///
  /// In en, this message translates to:
  /// **'Not valid address'**
  String get notValidAddress;

  /// No description provided for @swipeLeftTheNotificationToDeleteOrReadUnreadIt.
  ///
  /// In en, this message translates to:
  /// **'Swipe left the notification to delete or read / unread it'**
  String get swipeLeftTheNotificationToDeleteOrReadUnreadIt;

  /// No description provided for @thisNotificationHasMarkedAsUnread.
  ///
  /// In en, this message translates to:
  /// **'This notification has marked as unread'**
  String get thisNotificationHasMarkedAsUnread;

  /// No description provided for @notificationWasRemoved.
  ///
  /// In en, this message translates to:
  /// **'Notification was removed'**
  String get notificationWasRemoved;

  /// No description provided for @thisNotificationHasMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'This notification has marked as read'**
  String get thisNotificationHasMarkedAsRead;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @smsHasBeenSentTo.
  ///
  /// In en, this message translates to:
  /// **'SMS has been sent to'**
  String get smsHasBeenSentTo;

  /// No description provided for @weAreSendingOtpToValidateYourMobileNumberHang.
  ///
  /// In en, this message translates to:
  /// **'We are sending OTP to validate your mobile number. Hang on!'**
  String get weAreSendingOtpToValidateYourMobileNumberHang;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// No description provided for @check_on_waze.
  ///
  /// In en, this message translates to:
  /// **'Check on Waze:'**
  String get check_on_waze;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get payment_method;

  /// No description provided for @credit_card.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get credit_card;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @add_courier_tip.
  ///
  /// In en, this message translates to:
  /// **'Add courier tip'**
  String get add_courier_tip;

  /// No description provided for @add_a_promo_code.
  ///
  /// In en, this message translates to:
  /// **'Add a promo code'**
  String get add_a_promo_code;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @order_summary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get order_summary;

  /// No description provided for @include_tax.
  ///
  /// In en, this message translates to:
  /// **'Include tax ( if applicable )'**
  String get include_tax;

  /// No description provided for @item_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Item subtotal'**
  String get item_subtotal;

  /// No description provided for @service_fee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get service_fee;

  /// No description provided for @promo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get promo;

  /// No description provided for @pay_now.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get pay_now;

  /// No description provided for @enter_here.
  ///
  /// In en, this message translates to:
  /// **'Enter here'**
  String get enter_here;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @open_until.
  ///
  /// In en, this message translates to:
  /// **'Open until {time}'**
  String open_until(Object time);

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @no_items_in_this_category.
  ///
  /// In en, this message translates to:
  /// **'No items found in this category'**
  String get no_items_in_this_category;

  /// No description provided for @login_successful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_successful;

  /// No description provided for @already_logged_in.
  ///
  /// In en, this message translates to:
  /// **'You are already logged in'**
  String get already_logged_in;

  /// No description provided for @register_successful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get register_successful;

  /// No description provided for @please_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields correctly'**
  String get please_fill_all_fields;

  /// No description provided for @wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get wrong_password;

  /// No description provided for @login_with_facebook.
  ///
  /// In en, this message translates to:
  /// **'Login with Facebook'**
  String get login_with_facebook;

  /// No description provided for @login_with_google.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get login_with_google;

  /// No description provided for @login_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Login with Apple'**
  String get login_with_apple;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get login_success;

  /// No description provided for @maps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get maps;

  /// No description provided for @choose_your_location.
  ///
  /// In en, this message translates to:
  /// **'Please , Choose Your Location'**
  String get choose_your_location;

  /// No description provided for @deliveryAddressOutsideRange.
  ///
  /// In en, this message translates to:
  /// **'Your address is out of the delivery range. Please select pickup or change your address.'**
  String get deliveryAddressOutsideRange;

  /// No description provided for @card_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully'**
  String get card_deleted_successfully;

  /// No description provided for @card_added_successfully.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get card_added_successfully;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @no_restaurants_found.
  ///
  /// In en, this message translates to:
  /// **'No restaurants found'**
  String get no_restaurants_found;

  /// No description provided for @no_stores_found.
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get no_stores_found;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @enterThe4DigitCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to {phone}'**
  String enterThe4DigitCodeSentTo(Object phone);

  /// No description provided for @didntReceiveTheCodeResendit.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? Resend it'**
  String get didntReceiveTheCodeResendit;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @forgot_passwordd.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgot_passwordd;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @do_not_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get do_not_have_account;

  /// No description provided for @add_new_card.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get add_new_card;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @add_new_credit_card.
  ///
  /// In en, this message translates to:
  /// **'Add New Credit Card'**
  String get add_new_credit_card;

  /// No description provided for @add_credit_card.
  ///
  /// In en, this message translates to:
  /// **'Add Credit Card'**
  String get add_credit_card;

  /// No description provided for @no_saved_cards.
  ///
  /// In en, this message translates to:
  /// **'No saved cards'**
  String get no_saved_cards;

  /// No description provided for @select_extras.
  ///
  /// In en, this message translates to:
  /// **'Select extras to add them on the food'**
  String get select_extras;

  /// No description provided for @added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'{foodName} has been added to the cart'**
  String added_to_cart(Object foodName);

  /// No description provided for @complete_payment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get complete_payment;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @card_already_exist.
  ///
  /// In en, this message translates to:
  /// **'The card is Already Exist'**
  String get card_already_exist;

  /// No description provided for @complete_order.
  ///
  /// In en, this message translates to:
  /// **'Complete Order'**
  String get complete_order;

  /// No description provided for @transaction_declined.
  ///
  /// In en, this message translates to:
  /// **'Transaction has been declined'**
  String get transaction_declined;

  /// No description provided for @tips_complete_order.
  ///
  /// In en, this message translates to:
  /// **'Tips to complete your order'**
  String get tips_complete_order;

  /// No description provided for @tip_check_card_info.
  ///
  /// In en, this message translates to:
  /// **'• Double-check your card information.'**
  String get tip_check_card_info;

  /// No description provided for @tip_use_different_card.
  ///
  /// In en, this message translates to:
  /// **'• Use a different card or alternative method.'**
  String get tip_use_different_card;

  /// No description provided for @tip_contact_issuer.
  ///
  /// In en, this message translates to:
  /// **'• Contact your card issuer to verify your account.'**
  String get tip_contact_issuer;

  /// No description provided for @go_back_checkout.
  ///
  /// In en, this message translates to:
  /// **'Go back to checkout'**
  String get go_back_checkout;

  /// No description provided for @most_ordered.
  ///
  /// In en, this message translates to:
  /// **'Most ordered'**
  String get most_ordered;

  /// No description provided for @delivery_20_30_mnt.
  ///
  /// In en, this message translates to:
  /// **'Delivery 20–30 min'**
  String get delivery_20_30_mnt;

  /// No description provided for @testNotifications.
  ///
  /// In en, this message translates to:
  /// **'Test Notifications'**
  String get testNotifications;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test notification!'**
  String get testNotificationBody;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unread Notifications'**
  String get unreadNotifications;

  /// No description provided for @notificationsTestTitle.
  ///
  /// In en, this message translates to:
  /// **'🧪 Notification Test'**
  String get notificationsTestTitle;

  /// No description provided for @refreshNotificationCount.
  ///
  /// In en, this message translates to:
  /// **'Refresh Notification Count'**
  String get refreshNotificationCount;

  /// No description provided for @testLocalNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Local Notification'**
  String get testLocalNotification;

  /// No description provided for @fetchAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Fetch All Notifications'**
  String get fetchAllNotifications;

  /// No description provided for @goToNotificationsPage.
  ///
  /// In en, this message translates to:
  /// **'Go to Notifications Page'**
  String get goToNotificationsPage;

  /// No description provided for @testApiConnection.
  ///
  /// In en, this message translates to:
  /// **'Test API Connection'**
  String get testApiConnection;

  /// No description provided for @testingApiConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing API connection...'**
  String get testingApiConnection;

  /// No description provided for @apiConnectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Success! Notification count: {count}'**
  String apiConnectionSuccess(Object count);

  /// No description provided for @apiConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Connection failed: {error}'**
  String apiConnectionFailed(Object error);

  /// No description provided for @errorFetchingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error fetching notifications: {error}'**
  String errorFetchingNotifications(Object error);

  /// No description provided for @apiInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'API Info'**
  String get apiInfoTitle;

  /// No description provided for @apiEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint: https://carrytechnologies.co/api/notifications'**
  String get apiEndpoint;

  /// No description provided for @apiToken.
  ///
  /// In en, this message translates to:
  /// **'Token: fXLu7VeYgXDu82SkMxlLPG1mCAXc4EBIx6O5isgYVIKFQiHah0xiOHmzNsBv'**
  String get apiToken;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @loadingRoute.
  ///
  /// In en, this message translates to:
  /// **'Loading route...'**
  String get loadingRoute;

  /// No description provided for @notAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'Not available now'**
  String get notAvailableNow;

  /// No description provided for @twentyToThirtyMin.
  ///
  /// In en, this message translates to:
  /// **'20–30 min'**
  String get twentyToThirtyMin;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNow;

  /// No description provided for @timeFormatHhMm.
  ///
  /// In en, this message translates to:
  /// **'HH:mm'**
  String get timeFormatHhMm;

  /// No description provided for @ddMMyyyy.
  ///
  /// In en, this message translates to:
  /// **'dd-MM-yyyy'**
  String get ddMMyyyy;

  /// No description provided for @dateTimeFormatMmmDdYyyyHhMm.
  ///
  /// In en, this message translates to:
  /// **'MMM dd, yyyy HH:mm'**
  String get dateTimeFormatMmmDdYyyyHhMm;

  /// No description provided for @dateTimeFormatDdMmYyyyHhMm.
  ///
  /// In en, this message translates to:
  /// **'dd/MM/yyyy HH:mm'**
  String get dateTimeFormatDdMmYyyyHhMm;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @addingExactAddressDetailsHelpsUsFindYouFaster.
  ///
  /// In en, this message translates to:
  /// **'Adding exact address details helps us find you faster'**
  String get addingExactAddressDetailsHelpsUsFindYouFaster;

  /// No description provided for @buildingName.
  ///
  /// In en, this message translates to:
  /// **'Building Name'**
  String get buildingName;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @entranceStaircase.
  ///
  /// In en, this message translates to:
  /// **'Entrance / Staircase'**
  String get entranceStaircase;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @howDoWeGetIn.
  ///
  /// In en, this message translates to:
  /// **'How do we get in?'**
  String get howDoWeGetIn;

  /// No description provided for @doorbellIntercom.
  ///
  /// In en, this message translates to:
  /// **'Doorbell / Intercom'**
  String get doorbellIntercom;

  /// No description provided for @doorCode.
  ///
  /// In en, this message translates to:
  /// **'Door Code'**
  String get doorCode;

  /// No description provided for @doorIsOpen.
  ///
  /// In en, this message translates to:
  /// **'Door is Open'**
  String get doorIsOpen;

  /// No description provided for @otherTellUsHow.
  ///
  /// In en, this message translates to:
  /// **'Other (tell us how)'**
  String get otherTellUsHow;

  /// No description provided for @otherInstructionsForTheCourier.
  ///
  /// In en, this message translates to:
  /// **'Other instructions for the courier'**
  String get otherInstructionsForTheCourier;

  /// No description provided for @addressTypeAndLabel.
  ///
  /// In en, this message translates to:
  /// **'Address Type and Label'**
  String get addressTypeAndLabel;

  /// No description provided for @addOrCreateAddressLabelsToEasilyChooseBetweenDeliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Add or create address labels to easily choose between delivery addresses.'**
  String get addOrCreateAddressLabelsToEasilyChooseBetweenDeliveryAddresses;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get homeAddress;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @streetCityCountry.
  ///
  /// In en, this message translates to:
  /// **'Street, City, Country'**
  String get streetCityCountry;

  /// No description provided for @pleaseEnterOrSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter or select an address'**
  String get pleaseEnterOrSelectAddress;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service is disabled'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied permanently'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationFetchError.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine location'**
  String get locationFetchError;

  /// No description provided for @locationBasedMessage.
  ///
  /// In en, this message translates to:
  /// **'Based on your phone\'s location, it looks like you\'re here:'**
  String get locationBasedMessage;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @useThisAddress.
  ///
  /// In en, this message translates to:
  /// **'Use this address'**
  String get useThisAddress;

  /// No description provided for @enterAnotherAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter another address'**
  String get enterAnotherAddress;

  /// No description provided for @locationType.
  ///
  /// In en, this message translates to:
  /// **'Location Type'**
  String get locationType;

  /// No description provided for @locationTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select location type'**
  String get locationTypeHint;

  /// No description provided for @selectLocationType.
  ///
  /// In en, this message translates to:
  /// **'Select location type'**
  String get selectLocationType;

  /// No description provided for @login_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Jetak'**
  String get login_welcome;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Order from top restaurants and get fast delivery'**
  String get login_subtitle;

  /// No description provided for @login_icon_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get login_icon_restaurants;

  /// No description provided for @login_icon_delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get login_icon_delivery;

  /// No description provided for @login_icon_quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get login_icon_quality;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_button;

  /// No description provided for @please_enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get please_enter_phone_number;

  /// No description provided for @verification_title.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verification_title;

  /// Instruction shown on the OTP screen
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit verification code sent to {phone}'**
  String verification_instruction(Object phone);

  /// No description provided for @resend_code.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? Resend'**
  String get resend_code;

  /// No description provided for @resend_available_in.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {seconds} seconds'**
  String resend_available_in(Object seconds);

  /// No description provided for @back_to_edit_number.
  ///
  /// In en, this message translates to:
  /// **'Back to edit number'**
  String get back_to_edit_number;

  /// No description provided for @otp_sent_success.
  ///
  /// In en, this message translates to:
  /// **'📩 OTP code has been sent'**
  String get otp_sent_success;

  /// No description provided for @otp_sent_error.
  ///
  /// In en, this message translates to:
  /// **'❌ Failed to send OTP code'**
  String get otp_sent_error;

  /// No description provided for @otp_verification_success.
  ///
  /// In en, this message translates to:
  /// **'✅ Verification successful'**
  String get otp_verification_success;

  /// No description provided for @otp_verification_invalid.
  ///
  /// In en, this message translates to:
  /// **'❌ Invalid or expired code'**
  String get otp_verification_invalid;

  /// No description provided for @verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verification_failed;

  /// No description provided for @otp_verification_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during verification'**
  String get otp_verification_error;

  /// No description provided for @otp_send_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending the OTP'**
  String get otp_send_error;

  /// No description provided for @your_location.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get your_location;

  /// No description provided for @offers_near_you.
  ///
  /// In en, this message translates to:
  /// **'Offers near you'**
  String get offers_near_you;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @location_type_hint.
  ///
  /// In en, this message translates to:
  /// **'The location type helps us to find you better, house, office'**
  String get location_type_hint;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @chooseOrderType.
  ///
  /// In en, this message translates to:
  /// **'Choose order type'**
  String get chooseOrderType;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi 👋'**
  String get hi;

  /// No description provided for @writeEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Write your email and password 💁‍♂️'**
  String get writeEmailAndPassword;

  /// No description provided for @providePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Provide us with your phone number 🙅‍♂️'**
  String get providePhoneNumber;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'We have sent you a code 🧏‍♂️'**
  String get codeSent;

  /// No description provided for @enterTheDoorCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the door code'**
  String get enterTheDoorCode;

  /// No description provided for @otherInstructionsForCourier.
  ///
  /// In en, this message translates to:
  /// **'Other instructions for the courier'**
  String get otherInstructionsForCourier;

  /// No description provided for @verify_your_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'Verify your internet connection'**
  String get verify_your_internet_connection;

  /// No description provided for @carts_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Carts refreshed successfully'**
  String get carts_refreshed_successfuly;

  /// No description provided for @category_refreshed_successfuly.
  ///
  /// In en, this message translates to:
  /// **'Category refreshed successfully'**
  String get category_refreshed_successfuly;

  /// No description provided for @card_number.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get card_number;

  /// No description provided for @expiry_date.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiry_date;

  /// No description provided for @favorite_foods.
  ///
  /// In en, this message translates to:
  /// **'Favorite foods'**
  String get favorite_foods;

  /// No description provided for @order_id.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get order_id;

  /// No description provided for @i_dont_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have an account'**
  String get i_dont_have_an_account;

  /// No description provided for @search_for_restaurants_or_foods.
  ///
  /// In en, this message translates to:
  /// **'Search for restaurants or foods'**
  String get search_for_restaurants_or_foods;

  /// No description provided for @ordered_by_nearby_first.
  ///
  /// In en, this message translates to:
  /// **'Ordered by nearby first'**
  String get ordered_by_nearby_first;

  /// No description provided for @maps_explorer.
  ///
  /// In en, this message translates to:
  /// **'Maps Explorer'**
  String get maps_explorer;

  /// No description provided for @top_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Top Restaurants'**
  String get top_restaurants;

  /// No description provided for @most_popular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get most_popular;

  /// No description provided for @trending_this_week.
  ///
  /// In en, this message translates to:
  /// **'Trending this week'**
  String get trending_this_week;

  /// No description provided for @payment_mode.
  ///
  /// In en, this message translates to:
  /// **'Payment mode'**
  String get payment_mode;

  /// No description provided for @select_your_preferred_payment_mode.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred payment mode'**
  String get select_your_preferred_payment_mode;

  /// No description provided for @or_checkout_with.
  ///
  /// In en, this message translates to:
  /// **'Or checkout with'**
  String get or_checkout_with;

  /// No description provided for @estimated_time.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimated_time;

  /// No description provided for @your_credit_card_not_valid.
  ///
  /// In en, this message translates to:
  /// **'Your credit card is not valid'**
  String get your_credit_card_not_valid;

  /// No description provided for @confirm_payment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirm_payment;

  /// No description provided for @add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get add_to_cart;

  /// No description provided for @help_supports.
  ///
  /// In en, this message translates to:
  /// **'Help & Supports'**
  String get help_supports;

  /// No description provided for @your_order_has_been_successfully_submitted.
  ///
  /// In en, this message translates to:
  /// **'Your order has been successfully submitted'**
  String get your_order_has_been_successfully_submitted;

  /// No description provided for @featured_foods.
  ///
  /// In en, this message translates to:
  /// **'Featured Foods'**
  String get featured_foods;

  /// No description provided for @what_they_say.
  ///
  /// In en, this message translates to:
  /// **'What they say'**
  String get what_they_say;

  /// No description provided for @sign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get sign;

  /// No description provided for @payment_will_be_cash_on_delivery.
  ///
  /// In en, this message translates to:
  /// **'Payment will be made in cash upon delivery'**
  String get payment_will_be_cash_on_delivery;

  /// No description provided for @description_required.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get description_required;

  /// No description provided for @description_min_length.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 3 characters'**
  String get description_min_length;

  /// No description provided for @description_max_length.
  ///
  /// In en, this message translates to:
  /// **'Description must be less than 50 characters'**
  String get description_max_length;

  /// No description provided for @address_required.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get address_required;

  /// No description provided for @address_min_length.
  ///
  /// In en, this message translates to:
  /// **'Address must be at least 10 characters'**
  String get address_min_length;

  /// No description provided for @address_max_length.
  ///
  /// In en, this message translates to:
  /// **'Address must be less than 200 characters'**
  String get address_max_length;

  /// No description provided for @please_correct_form_errors.
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors in the form'**
  String get please_correct_form_errors;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
