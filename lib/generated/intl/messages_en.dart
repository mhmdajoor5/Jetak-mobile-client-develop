// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(foodName) => "${foodName} has been added to the cart";

  static String m1(error) => "API connection failed: ${error}";

  static String m2(count) =>
      "API connection successful. Found ${count} notifications";

  static String m3(phone) => "Enter the 4-digit code sent to ${phone}";

  static String m4(error) => "Error fetching notifications: ${error}";

  static String m5(time) => "Open until ${time}";

  static String m8(id) => "Order: #${id} has been canceled";

  static String m6(seconds) => "Resend available in ${seconds} seconds";

  static String m9(foodname) => "The ${foodname} was removed from your cart";

  static String m7(phone) =>
      "Enter the 4-digit verification code sent to ${phone}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addNewAddress":
            MessageLookupByLibrary.simpleMessage("Add New Address"),
        "addOrCreateAddressLabelsToEasilyChooseBetweenDeliveryAddresses":
            MessageLookupByLibrary.simpleMessage(
                "Add or create address labels to easily choose between delivery addresses"),
        "addToCart": MessageLookupByLibrary.simpleMessage("Add to Cart"),
        "add_a_promo_code":
            MessageLookupByLibrary.simpleMessage("Add a promo code"),
        "add_courier_tip":
            MessageLookupByLibrary.simpleMessage("Add courier tip"),
        "add_credit_card":
            MessageLookupByLibrary.simpleMessage("Add Credit Card"),
        "add_delivery_address":
            MessageLookupByLibrary.simpleMessage("Add Delivery Address"),
        "add_new_card": MessageLookupByLibrary.simpleMessage("Add New Card"),
        "add_new_credit_card":
            MessageLookupByLibrary.simpleMessage("Add New Credit Card"),
        "add_new_delivery_address":
            MessageLookupByLibrary.simpleMessage("Add new delivery address"),
        "add_to_cart": MessageLookupByLibrary.simpleMessage("Add to Cart"),
        "added_to_cart": m0,
        "addingExactAddressDetailsHelpsUsFindYouFaster":
            MessageLookupByLibrary.simpleMessage(
                "Adding exact address details helps us find you faster"),
        "additions": MessageLookupByLibrary.simpleMessage("Additions"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "addressDetails":
            MessageLookupByLibrary.simpleMessage("Address Details"),
        "addressTypeAndLabel":
            MessageLookupByLibrary.simpleMessage("Address type and label"),
        "address_required":
            MessageLookupByLibrary.simpleMessage("Address is required"),
        "addresses_refreshed_successfuly": MessageLookupByLibrary.simpleMessage(
            "Addresses refreshed successfuly"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "allMenu": MessageLookupByLibrary.simpleMessage("All Menu"),
        "already_logged_in":
            MessageLookupByLibrary.simpleMessage("You are already logged in"),
        "apartment": MessageLookupByLibrary.simpleMessage("Apartment"),
        "apiConnectionFailed": m1,
        "apiConnectionSuccess": m2,
        "apiEndpoint": MessageLookupByLibrary.simpleMessage("API Endpoint"),
        "apiInfoTitle": MessageLookupByLibrary.simpleMessage("API Information"),
        "apiToken": MessageLookupByLibrary.simpleMessage("API Token"),
        "appLanguage": MessageLookupByLibrary.simpleMessage("App Language"),
        "app_settings": MessageLookupByLibrary.simpleMessage("App Settings"),
        "application_preferences":
            MessageLookupByLibrary.simpleMessage("Application Preferences"),
        "apply_filters": MessageLookupByLibrary.simpleMessage("Apply Filters"),
        "areYouSureYouWantToCancelThisOrder":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to cancel this order?"),
        "back_to_edit_number":
            MessageLookupByLibrary.simpleMessage("Back to edit number"),
        "buildingName": MessageLookupByLibrary.simpleMessage("Building Name"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelOrder": MessageLookupByLibrary.simpleMessage("Cancel Order"),
        "canceled": MessageLookupByLibrary.simpleMessage("Canceled"),
        "cannot_add_from_different_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "Cannot add from different restaurant"),
        "cardNumber": MessageLookupByLibrary.simpleMessage("CARD NUMBER"),
        "card_added_successfully":
            MessageLookupByLibrary.simpleMessage("Card added successfully"),
        "card_already_exist":
            MessageLookupByLibrary.simpleMessage("The card is Already Exist"),
        "card_deleted_successfully":
            MessageLookupByLibrary.simpleMessage("Card deleted successfully"),
        "card_number": MessageLookupByLibrary.simpleMessage("Card Number"),
        "cart": MessageLookupByLibrary.simpleMessage("Cart"),
        "cartIsEmpty": MessageLookupByLibrary.simpleMessage("Cart is empty"),
        "cartsRefreshedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Carts refreshed successfully"),
        "carts_refreshed_successfuly": MessageLookupByLibrary.simpleMessage(
            "Carts refreshed successfully"),
        "cash": MessageLookupByLibrary.simpleMessage("Cash"),
        "cash_on_delivery":
            MessageLookupByLibrary.simpleMessage("Cash on delivery"),
        "category": MessageLookupByLibrary.simpleMessage("Category"),
        "categoryRefreshedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Category refreshed successfully"),
        "category_refreshed_successfuly": MessageLookupByLibrary.simpleMessage(
            "Category refreshed successfully"),
        "change": MessageLookupByLibrary.simpleMessage("Change"),
        "chats": MessageLookupByLibrary.simpleMessage("Chats"),
        "check_on_waze": MessageLookupByLibrary.simpleMessage("Check on Waze:"),
        "checkout": MessageLookupByLibrary.simpleMessage("Checkout"),
        "chooseOrderType":
            MessageLookupByLibrary.simpleMessage("Choose Order Type"),
        "choose_your_location": MessageLookupByLibrary.simpleMessage(
            "Please , Choose Your Location"),
        "clear": MessageLookupByLibrary.simpleMessage("Clear"),
        "clickOnTheFoodToGetMoreDetailsAboutIt":
            MessageLookupByLibrary.simpleMessage(
                "Click on the food to get more details about it"),
        "clickToPayWithRazorpayMethod": MessageLookupByLibrary.simpleMessage(
            "Click to pay with RazorPay method"),
        "click_on_the_stars_below_to_leave_comments":
            MessageLookupByLibrary.simpleMessage(
                "Click on the stars below to leave comments"),
        "click_to_confirm_your_address_and_pay_or_long_press":
            MessageLookupByLibrary.simpleMessage(
                "Click to confirm your address and pay or Long press to edit your address"),
        "click_to_pay_cash_on_delivery": MessageLookupByLibrary.simpleMessage(
            "Click to pay cash on delivery"),
        "click_to_pay_on_pickup":
            MessageLookupByLibrary.simpleMessage("Click to pay on pickup"),
        "click_to_pay_with_icredit": MessageLookupByLibrary.simpleMessage(
            "Click to pay with your iCredit"),
        "click_to_pay_with_your_mastercard":
            MessageLookupByLibrary.simpleMessage(
                "Click to pay with your MasterCard"),
        "click_to_pay_with_your_paypal_account":
            MessageLookupByLibrary.simpleMessage(
                "Click to pay with your PayPal account"),
        "click_to_pay_with_your_visa_card":
            MessageLookupByLibrary.simpleMessage(
                "Click to pay with your Visa Card"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "closed": MessageLookupByLibrary.simpleMessage("Closed"),
        "codeSent":
            MessageLookupByLibrary.simpleMessage("We sent you a code 🧏‍♂️"),
        "completeYourProfileDetailsToContinue":
            MessageLookupByLibrary.simpleMessage(
                "Complete your profile details to continue"),
        "complete_order":
            MessageLookupByLibrary.simpleMessage("Complete Order"),
        "complete_payment":
            MessageLookupByLibrary.simpleMessage("Complete Payment"),
        "confirmPayment":
            MessageLookupByLibrary.simpleMessage("Confirm Payment"),
        "confirm_payment":
            MessageLookupByLibrary.simpleMessage("Confirm Payment"),
        "confirm_your_delivery_address": MessageLookupByLibrary.simpleMessage(
            "Confirm your delivery address"),
        "confirmation": MessageLookupByLibrary.simpleMessage("Confirmation"),
        "continueBtn": MessageLookupByLibrary.simpleMessage("Continue"),
        "continueText": MessageLookupByLibrary.simpleMessage("Continue"),
        "continue_button": MessageLookupByLibrary.simpleMessage("Continue"),
        "credit_card": MessageLookupByLibrary.simpleMessage("Credit card"),
        "cuisines": MessageLookupByLibrary.simpleMessage("Cuisines"),
        "current_location":
            MessageLookupByLibrary.simpleMessage("Current Location"),
        "cvc": MessageLookupByLibrary.simpleMessage("CVC"),
        "cvv": MessageLookupByLibrary.simpleMessage("CVV"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "dateTimeFormatDdMmYyyyHhMm":
            MessageLookupByLibrary.simpleMessage("dd-MM-yyyy | HH:mm"),
        "dateTimeFormatMmmDdYyyyHhMm":
            MessageLookupByLibrary.simpleMessage("MMM dd, yyyy • HH:mm"),
        "ddMMyyyy": MessageLookupByLibrary.simpleMessage("dd/MM/yyyy"),
        "debug": MessageLookupByLibrary.simpleMessage("Debug"),
        "default_credit_card":
            MessageLookupByLibrary.simpleMessage("Default Credit Card"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deliverable": MessageLookupByLibrary.simpleMessage("Deliverable"),
        "delivery": MessageLookupByLibrary.simpleMessage("Delivery"),
        "deliveryAddressOutsideRange": MessageLookupByLibrary.simpleMessage(
            "Your address is out of the delivery range. Please select pickup or change your address."),
        "deliveryAddressOutsideTheDeliveryRangeOfThisRestaurants":
            MessageLookupByLibrary.simpleMessage(
                "Delivery address outside the delivery range of this restaurants."),
        "deliveryMethodNotAllowed": MessageLookupByLibrary.simpleMessage(
            "Delivery method not allowed!"),
        "delivery_20_30_mnt":
            MessageLookupByLibrary.simpleMessage("Delivery 20–30 min"),
        "delivery_address":
            MessageLookupByLibrary.simpleMessage("Delivery Address"),
        "delivery_address_removed_successfully":
            MessageLookupByLibrary.simpleMessage(
                "Delivery Address removed successfully"),
        "delivery_addresses":
            MessageLookupByLibrary.simpleMessage("Delivery Addresses"),
        "delivery_fee": MessageLookupByLibrary.simpleMessage("Delivery Fee"),
        "delivery_or_pickup":
            MessageLookupByLibrary.simpleMessage("Delivery or Pickup"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "description_max_length": MessageLookupByLibrary.simpleMessage(
            "Description must be less than 50 characters"),
        "description_min_length": MessageLookupByLibrary.simpleMessage(
            "Description must be at least 3 characters"),
        "description_required":
            MessageLookupByLibrary.simpleMessage("Description is required"),
        "details": MessageLookupByLibrary.simpleMessage("Details"),
        "didntReceiveTheCodeResendit": MessageLookupByLibrary.simpleMessage(
            "Didn\'t receive the code? Resend it"),
        "discount": MessageLookupByLibrary.simpleMessage("Discount"),
        "discover__explorer":
            MessageLookupByLibrary.simpleMessage("Discover & Explorer"),
        "do_not_have_account":
            MessageLookupByLibrary.simpleMessage("Don’t have an account?"),
        "dont_have_any_item_in_the_notification_list":
            MessageLookupByLibrary.simpleMessage(
                "Don\'t have any item in the notification list"),
        "dont_have_any_item_in_your_cart": MessageLookupByLibrary.simpleMessage(
            "Don\'t have any item in your cart"),
        "doorCode": MessageLookupByLibrary.simpleMessage("Door code"),
        "doorIsOpen": MessageLookupByLibrary.simpleMessage("Door is open"),
        "doorbellIntercom":
            MessageLookupByLibrary.simpleMessage("Doorbell / Intercom"),
        "doubleClickOnTheFoodToAddItToTheCart":
            MessageLookupByLibrary.simpleMessage(
                "Double click on the food to add it to the cart"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "email_address": MessageLookupByLibrary.simpleMessage("Email Address"),
        "email_to_reset_password":
            MessageLookupByLibrary.simpleMessage("Email to reset password"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enterAnotherAddress":
            MessageLookupByLibrary.simpleMessage("Enter another address"),
        "enterPassword": MessageLookupByLibrary.simpleMessage("Enter password"),
        "enterThe4DigitCodeSentTo": m3,
        "enterTheDoorCode":
            MessageLookupByLibrary.simpleMessage("Enter the door code"),
        "enterYourEmail":
            MessageLookupByLibrary.simpleMessage("Enter your email"),
        "enter_here": MessageLookupByLibrary.simpleMessage("Enter here"),
        "entranceStaircase":
            MessageLookupByLibrary.simpleMessage("Entrance / Staircase"),
        "errorFetchingNotifications": m4,
        "errorRemovingProduct":
            MessageLookupByLibrary.simpleMessage("Error removing product"),
        "error_verify_email_settings": MessageLookupByLibrary.simpleMessage(
            "Error! Verify email settings"),
        "estimatedTime":
            MessageLookupByLibrary.simpleMessage("Estimated time:"),
        "estimated_time":
            MessageLookupByLibrary.simpleMessage("Estimated time"),
        "exp_date": MessageLookupByLibrary.simpleMessage("Exp Date"),
        "expiryDate": MessageLookupByLibrary.simpleMessage("EXPIRY DATE"),
        "expiry_date": MessageLookupByLibrary.simpleMessage("Expiry Date"),
        "extras": MessageLookupByLibrary.simpleMessage("Extras"),
        "faq": MessageLookupByLibrary.simpleMessage("Faq"),
        "faqsRefreshedSuccessfuly":
            MessageLookupByLibrary.simpleMessage("Faqs refreshed successfully"),
        "favoriteFoods": MessageLookupByLibrary.simpleMessage("Favorite Foods"),
        "favorite_foods":
            MessageLookupByLibrary.simpleMessage("Favorite Foods"),
        "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "favorites_refreshed_successfuly": MessageLookupByLibrary.simpleMessage(
            "Favorites refreshed successfully"),
        "featuredFoods": MessageLookupByLibrary.simpleMessage("Featured Foods"),
        "featured_foods":
            MessageLookupByLibrary.simpleMessage("Featured Foods"),
        "fetchAllNotifications":
            MessageLookupByLibrary.simpleMessage("Fetch All Notifications"),
        "fields": MessageLookupByLibrary.simpleMessage("Fields"),
        "filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "first_name": MessageLookupByLibrary.simpleMessage("First Name"),
        "floor": MessageLookupByLibrary.simpleMessage("Floor"),
        "foodCategories":
            MessageLookupByLibrary.simpleMessage("Food Categories"),
        "foodRefreshedSuccessfuly":
            MessageLookupByLibrary.simpleMessage("Food refreshed successfully"),
        "foods_result": MessageLookupByLibrary.simpleMessage("Foods result"),
        "foods_results": MessageLookupByLibrary.simpleMessage("Foods Results"),
        "forMoreDetailsPleaseChatWithOurManagers":
            MessageLookupByLibrary.simpleMessage(
                "For more details, please chat with our managers"),
        "forgot_password":
            MessageLookupByLibrary.simpleMessage("Forgot password?"),
        "forgot_passwordd":
            MessageLookupByLibrary.simpleMessage("Forgot password"),
        "fullAddress": MessageLookupByLibrary.simpleMessage("Full Address"),
        "full_address": MessageLookupByLibrary.simpleMessage("Full Address"),
        "full_name": MessageLookupByLibrary.simpleMessage("Full Name"),
        "g": MessageLookupByLibrary.simpleMessage("g"),
        "goToNotificationsPage":
            MessageLookupByLibrary.simpleMessage("Go to Notifications Page"),
        "go_back_checkout":
            MessageLookupByLibrary.simpleMessage("Go back to checkout"),
        "guest": MessageLookupByLibrary.simpleMessage("Guest"),
        "haveCouponCode":
            MessageLookupByLibrary.simpleMessage("Have Coupon Code?"),
        "helpAndSupports":
            MessageLookupByLibrary.simpleMessage("Help & Supports"),
        "help__support":
            MessageLookupByLibrary.simpleMessage("Help & Supports"),
        "help_support": MessageLookupByLibrary.simpleMessage("Help & Support"),
        "help_supports": MessageLookupByLibrary.simpleMessage("Help & Support"),
        "hi": MessageLookupByLibrary.simpleMessage("Hi 👋"),
        "hint_full_address":
            MessageLookupByLibrary.simpleMessage("Enter your full address"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "homeAddress": MessageLookupByLibrary.simpleMessage("Home Address"),
        "home_address": MessageLookupByLibrary.simpleMessage("Home Address"),
        "house": MessageLookupByLibrary.simpleMessage("House"),
        "howDoWeGetIn":
            MessageLookupByLibrary.simpleMessage("How do we get in?"),
        "how_would_you_rate_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "How would you rate this restaurant ?"),
        "how_would_you_rate_this_restaurant_":
            MessageLookupByLibrary.simpleMessage(
                "How would you rate this restaurant?"),
        "iCredit": MessageLookupByLibrary.simpleMessage("Pay now"),
        "iDontHaveAnAccount":
            MessageLookupByLibrary.simpleMessage("I don\'t have an account?"),
        "iForgotPassword":
            MessageLookupByLibrary.simpleMessage("I forgot password ?"),
        "i_dont_have_an_account":
            MessageLookupByLibrary.simpleMessage("I don\'t have an account"),
        "i_have_account_back_to_login": MessageLookupByLibrary.simpleMessage(
            "I have account? Back to login"),
        "i_remember_my_password_return_to_login":
            MessageLookupByLibrary.simpleMessage(
                "I remember my password return to login"),
        "include_tax": MessageLookupByLibrary.simpleMessage("Include tax"),
        "information": MessageLookupByLibrary.simpleMessage("Information"),
        "ingredients": MessageLookupByLibrary.simpleMessage("Ingredients"),
        "invalidCouponCode":
            MessageLookupByLibrary.simpleMessage("Invalid Coupon"),
        "item_subtotal": MessageLookupByLibrary.simpleMessage("Item Subtotal"),
        "items": MessageLookupByLibrary.simpleMessage("Items"),
        "itemsInCart": MessageLookupByLibrary.simpleMessage("Items in Cart"),
        "john_doe": MessageLookupByLibrary.simpleMessage("John Doe"),
        "keep_your_old_meals_of_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "Keep your old meals from this restaurant"),
        "km": MessageLookupByLibrary.simpleMessage("km"),
        "languages": MessageLookupByLibrary.simpleMessage("Languages"),
        "last_name": MessageLookupByLibrary.simpleMessage("Last Name"),
        "lets_start_with_login":
            MessageLookupByLibrary.simpleMessage("Let\'s Start with Login!"),
        "lets_start_with_register":
            MessageLookupByLibrary.simpleMessage("Let\'s Start with register!"),
        "light_mode": MessageLookupByLibrary.simpleMessage("Light Mode"),
        "loadingRoute":
            MessageLookupByLibrary.simpleMessage("Loading route..."),
        "locationBasedMessage": MessageLookupByLibrary.simpleMessage(
            "Based on your phone\'s location, it looks like you\'re here:"),
        "locationFetchError": MessageLookupByLibrary.simpleMessage(
            "Unable to determine location"),
        "locationPermissionDeniedForever": MessageLookupByLibrary.simpleMessage(
            "Location permission denied permanently"),
        "locationServiceDisabled": MessageLookupByLibrary.simpleMessage(
            "Location service is disabled"),
        "locationType": MessageLookupByLibrary.simpleMessage("Location Type"),
        "locationTypeHint":
            MessageLookupByLibrary.simpleMessage("Select location type"),
        "location_type_hint":
            MessageLookupByLibrary.simpleMessage("Select location type"),
        "log_out": MessageLookupByLibrary.simpleMessage("Log out"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "login_icon_delivery": MessageLookupByLibrary.simpleMessage("Delivery"),
        "login_icon_quality": MessageLookupByLibrary.simpleMessage("Quality"),
        "login_icon_restaurants":
            MessageLookupByLibrary.simpleMessage("Restaurants"),
        "login_subtitle": MessageLookupByLibrary.simpleMessage(
            "Order from top restaurants and get fast delivery"),
        "login_success":
            MessageLookupByLibrary.simpleMessage("Login successful!"),
        "login_successful":
            MessageLookupByLibrary.simpleMessage("Login successful"),
        "login_welcome":
            MessageLookupByLibrary.simpleMessage("Welcome to Jetak"),
        "login_with_apple":
            MessageLookupByLibrary.simpleMessage("Login with Apple"),
        "login_with_facebook":
            MessageLookupByLibrary.simpleMessage("Login with Facebook"),
        "login_with_google":
            MessageLookupByLibrary.simpleMessage("Login with Google"),
        "long_press_to_edit_item_swipe_item_to_delete_it":
            MessageLookupByLibrary.simpleMessage(
                "Long press to edit item, swipe item to delete it"),
        "longpressOnTheFoodToAddSuplements":
            MessageLookupByLibrary.simpleMessage(
                "Longpress on the food to add suplements"),
        "makeItDefault":
            MessageLookupByLibrary.simpleMessage("Make it default"),
        "maps": MessageLookupByLibrary.simpleMessage("Maps"),
        "mapsExplorer": MessageLookupByLibrary.simpleMessage("Maps Explorer"),
        "maps_explorer": MessageLookupByLibrary.simpleMessage("Maps Explorer"),
        "mastercard": MessageLookupByLibrary.simpleMessage("MasterCard"),
        "menu": MessageLookupByLibrary.simpleMessage("Menu"),
        "messages": MessageLookupByLibrary.simpleMessage("Messages"),
        "mi": MessageLookupByLibrary.simpleMessage("mi"),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "mostPopular": MessageLookupByLibrary.simpleMessage("Most Popular"),
        "most_ordered": MessageLookupByLibrary.simpleMessage("Most ordered"),
        "most_popular": MessageLookupByLibrary.simpleMessage("Most Popular"),
        "multirestaurants":
            MessageLookupByLibrary.simpleMessage("Multi-Restaurants"),
        "my_orders": MessageLookupByLibrary.simpleMessage("My Orders"),
        "near_to": MessageLookupByLibrary.simpleMessage("Near to"),
        "near_to_your_current_location": MessageLookupByLibrary.simpleMessage(
            "Near to your current location"),
        "near_you": MessageLookupByLibrary.simpleMessage("🔹 Near you"),
        "nearby_stores":
            MessageLookupByLibrary.simpleMessage("🔹 Nearby Stores"),
        "newMessageFrom":
            MessageLookupByLibrary.simpleMessage("New message from"),
        "new_address_added_successfully": MessageLookupByLibrary.simpleMessage(
            "New Address added successfully"),
        "new_order_from_client":
            MessageLookupByLibrary.simpleMessage("New order from client"),
        "no_items_in_this_category": MessageLookupByLibrary.simpleMessage(
            "No items found in this category"),
        "no_restaurants_found":
            MessageLookupByLibrary.simpleMessage("No restaurants found"),
        "no_saved_cards":
            MessageLookupByLibrary.simpleMessage("No saved cards"),
        "no_stores_found":
            MessageLookupByLibrary.simpleMessage("No stores found"),
        "notAvailableNow":
            MessageLookupByLibrary.simpleMessage("Not available now"),
        "notValidAddress":
            MessageLookupByLibrary.simpleMessage("Not valid address"),
        "not_a_valid_address":
            MessageLookupByLibrary.simpleMessage("Not a valid address"),
        "not_a_valid_biography":
            MessageLookupByLibrary.simpleMessage("Not a valid biography"),
        "not_a_valid_cvc":
            MessageLookupByLibrary.simpleMessage("Not a valid CVC"),
        "not_a_valid_date":
            MessageLookupByLibrary.simpleMessage("Not a valid date"),
        "not_a_valid_email":
            MessageLookupByLibrary.simpleMessage("Not a valid email"),
        "not_a_valid_full_name":
            MessageLookupByLibrary.simpleMessage("Not a valid full name"),
        "not_a_valid_number":
            MessageLookupByLibrary.simpleMessage("Not a valid number"),
        "not_a_valid_phone":
            MessageLookupByLibrary.simpleMessage("Not a valid phone"),
        "not_deliverable":
            MessageLookupByLibrary.simpleMessage("Not Deliverable"),
        "notificationWasRemoved":
            MessageLookupByLibrary.simpleMessage("Notification was removed"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "notificationsTestTitle":
            MessageLookupByLibrary.simpleMessage("Notifications Test"),
        "notifications_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage(
                "Notifications refreshed successfully"),
        "number": MessageLookupByLibrary.simpleMessage("Number"),
        "nutrition": MessageLookupByLibrary.simpleMessage("Nutrition"),
        "offers_near_you":
            MessageLookupByLibrary.simpleMessage("Offers near you"),
        "office": MessageLookupByLibrary.simpleMessage("Office"),
        "oneOrMoreFoodsInYourCartNotDeliverable":
            MessageLookupByLibrary.simpleMessage(
                "One or more foods in your cart not deliverable."),
        "open": MessageLookupByLibrary.simpleMessage("Open"),
        "open_until": m5,
        "opened_restaurants":
            MessageLookupByLibrary.simpleMessage("Opened Restaurants"),
        "optional": MessageLookupByLibrary.simpleMessage("Optional"),
        "orCheckoutWith":
            MessageLookupByLibrary.simpleMessage("Or Checkout With"),
        "or_checkout_with":
            MessageLookupByLibrary.simpleMessage("Or checkout with"),
        "order": MessageLookupByLibrary.simpleMessage("Order"),
        "orderDetails": MessageLookupByLibrary.simpleMessage("Order Details"),
        "orderId": MessageLookupByLibrary.simpleMessage("Order Id"),
        "orderThisorderidHasBeenCanceled": m8,
        "order_id": MessageLookupByLibrary.simpleMessage("Order ID"),
        "order_refreshed_successfuly": MessageLookupByLibrary.simpleMessage(
            "Order refreshed successfully"),
        "order_status_changed":
            MessageLookupByLibrary.simpleMessage("Order status changed"),
        "order_summary": MessageLookupByLibrary.simpleMessage("Order Summary"),
        "orderedByNearbyFirst":
            MessageLookupByLibrary.simpleMessage("Ordered by Nearby first"),
        "ordered_by_nearby_first":
            MessageLookupByLibrary.simpleMessage("Ordered by nearby first"),
        "orderingFromAnotherRestaurantWillClearYourCart":
            MessageLookupByLibrary.simpleMessage(
                "Ordering from another restaurant will clear your current cart. Do you want to continue?"),
        "orders_refreshed_successfuly": MessageLookupByLibrary.simpleMessage(
            "Orders refreshed successfully"),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "otherInstructionsForCourier": MessageLookupByLibrary.simpleMessage(
            "Other instructions for courier"),
        "otherInstructionsForTheCourier": MessageLookupByLibrary.simpleMessage(
            "Other instructions for the courier"),
        "otherTellUsHow":
            MessageLookupByLibrary.simpleMessage("Other (tell us how)"),
        "otp_send_error": MessageLookupByLibrary.simpleMessage(
            "An error occurred while sending the OTP"),
        "otp_sent_error":
            MessageLookupByLibrary.simpleMessage("❌ Failed to send OTP code"),
        "otp_sent_success":
            MessageLookupByLibrary.simpleMessage("📩 OTP code has been sent"),
        "otp_verification_error": MessageLookupByLibrary.simpleMessage(
            "An error occurred during verification"),
        "otp_verification_invalid":
            MessageLookupByLibrary.simpleMessage("❌ Invalid or expired code"),
        "otp_verification_success":
            MessageLookupByLibrary.simpleMessage("✅ Verification successful"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pay": MessageLookupByLibrary.simpleMessage("Pay"),
        "payNow": MessageLookupByLibrary.simpleMessage("Pay Now"),
        "pay_now": MessageLookupByLibrary.simpleMessage("Pay now"),
        "pay_on_pickup": MessageLookupByLibrary.simpleMessage("Pay on Pickup"),
        "payment": MessageLookupByLibrary.simpleMessage("Payment"),
        "paymentMode": MessageLookupByLibrary.simpleMessage("Payment Mode"),
        "payment_card_updated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "Payment card updated successfully"),
        "payment_method":
            MessageLookupByLibrary.simpleMessage("Payment method"),
        "payment_mode": MessageLookupByLibrary.simpleMessage("Payment Mode"),
        "payment_options":
            MessageLookupByLibrary.simpleMessage("Payment Options"),
        "payment_settings":
            MessageLookupByLibrary.simpleMessage("Payment Settings"),
        "payment_settings_updated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "Payment settings updated successfully"),
        "payments": MessageLookupByLibrary.simpleMessage("Payments"),
        "payments_settings":
            MessageLookupByLibrary.simpleMessage("Payments Settings"),
        "paypal": MessageLookupByLibrary.simpleMessage("PayPal"),
        "paypal_payment":
            MessageLookupByLibrary.simpleMessage("PayPal Payment"),
        "pending_payment":
            MessageLookupByLibrary.simpleMessage("Pending Payment"),
        "phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone Number"),
        "pickup": MessageLookupByLibrary.simpleMessage("Pickup"),
        "pickup_your_food_from_the_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "Pickup your food from the restaurant"),
        "pleaseEnterOrSelectAddress": MessageLookupByLibrary.simpleMessage(
            "Please enter or select an address"),
        "pleaseWait": MessageLookupByLibrary.simpleMessage("Please wait..."),
        "please_correct_form_errors": MessageLookupByLibrary.simpleMessage(
            "Please correct the form errors"),
        "please_enter_phone_number": MessageLookupByLibrary.simpleMessage(
            "Please enter your phone number"),
        "please_fill_all_fields": MessageLookupByLibrary.simpleMessage(
            "Please fill all fields correctly"),
        "productRemovedFromCart":
            MessageLookupByLibrary.simpleMessage("Product removed from cart"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "profile_settings":
            MessageLookupByLibrary.simpleMessage("Profile Settings"),
        "profile_settings_updated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "Profile settings updated successfully"),
        "promo": MessageLookupByLibrary.simpleMessage("Promo"),
        "providePhoneNumber": MessageLookupByLibrary.simpleMessage(
            "Provide us with your phone number 🙅‍♂️"),
        "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
        "razorpay": MessageLookupByLibrary.simpleMessage("RazorPay"),
        "razorpayPayment":
            MessageLookupByLibrary.simpleMessage("Razorpay Payment"),
        "recentReviews": MessageLookupByLibrary.simpleMessage("Recent Reviews"),
        "recent_orders": MessageLookupByLibrary.simpleMessage("Recent Orders"),
        "recentsSearch": MessageLookupByLibrary.simpleMessage("Recents Search"),
        "refreshNotificationCount":
            MessageLookupByLibrary.simpleMessage("Refresh Notification Count"),
        "register": MessageLookupByLibrary.simpleMessage("Register"),
        "register_successful":
            MessageLookupByLibrary.simpleMessage("Registration successful"),
        "resend_available_in": m6,
        "resend_code": MessageLookupByLibrary.simpleMessage(
            "Didn\'t receive the code? Resend"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "reset_cart": MessageLookupByLibrary.simpleMessage("Reset Cart"),
        "reset_your_cart_and_order_meals_form_this_restaurant":
            MessageLookupByLibrary.simpleMessage(
                "Reset your cart and order meals from this restaurant"),
        "restaurant_refreshed_successfuly":
            MessageLookupByLibrary.simpleMessage(
                "Restaurant refreshed successfully"),
        "restaurants": MessageLookupByLibrary.simpleMessage("Restaurants"),
        "restaurants_near_to":
            MessageLookupByLibrary.simpleMessage("Restaurants near to"),
        "restaurants_near_to_your_current_location":
            MessageLookupByLibrary.simpleMessage(
                "Restaurants near to your current location"),
        "restaurants_results":
            MessageLookupByLibrary.simpleMessage("Restaurants Results"),
        "reviews": MessageLookupByLibrary.simpleMessage("Reviews"),
        "reviews_refreshed_successfully": MessageLookupByLibrary.simpleMessage(
            "Reviews refreshed successfully!"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "searchForRestaurantsOrFoods":
            MessageLookupByLibrary.simpleMessage("Search for food, chef, etc"),
        "search_for_restaurants_or_foods": MessageLookupByLibrary.simpleMessage(
            "Search for restaurants or foods"),
        "searching_for_nearby_stores": MessageLookupByLibrary.simpleMessage(
            "Searching for nearby stores..."),
        "see_all": MessageLookupByLibrary.simpleMessage("See all"),
        "select": MessageLookupByLibrary.simpleMessage("Select"),
        "selectExtrasToAddThemOnTheFood": MessageLookupByLibrary.simpleMessage(
            "Select extras to add them on the food"),
        "selectLocationType":
            MessageLookupByLibrary.simpleMessage("Select location type"),
        "selectYourPreferredLanguages": MessageLookupByLibrary.simpleMessage(
            "Select your preferred languages"),
        "selectYourPreferredPaymentMode": MessageLookupByLibrary.simpleMessage(
            "Select your preferred payment mode"),
        "select_extras": MessageLookupByLibrary.simpleMessage("Select Extras"),
        "select_your_preferred_payment_mode":
            MessageLookupByLibrary.simpleMessage(
                "Select your preferred payment mode"),
        "send_password_reset_link":
            MessageLookupByLibrary.simpleMessage("Send link"),
        "service_fee": MessageLookupByLibrary.simpleMessage("Service Fee"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "shopping": MessageLookupByLibrary.simpleMessage("Shopping"),
        "shopping_cart": MessageLookupByLibrary.simpleMessage("Shopping Cart"),
        "shops_near_you":
            MessageLookupByLibrary.simpleMessage("Shops Near You"),
        "should_be_a_valid_email":
            MessageLookupByLibrary.simpleMessage("Should be a valid email"),
        "should_be_more_than_3_characters":
            MessageLookupByLibrary.simpleMessage(
                "Should be more than 3 characters"),
        "should_be_more_than_3_letters": MessageLookupByLibrary.simpleMessage(
            "Should be more than 3 letters"),
        "should_be_more_than_6_letters": MessageLookupByLibrary.simpleMessage(
            "Should be more than 6 letters"),
        "sign": MessageLookupByLibrary.simpleMessage("Sign"),
        "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
        "signinToChatWithOurManagers": MessageLookupByLibrary.simpleMessage(
            "Sign-In to chat with our managers"),
        "skip": MessageLookupByLibrary.simpleMessage("Skip"),
        "smsHasBeenSentTo":
            MessageLookupByLibrary.simpleMessage("SMS has been sent to"),
        "start_exploring":
            MessageLookupByLibrary.simpleMessage("Start Exploring"),
        "stores": MessageLookupByLibrary.simpleMessage("Stores"),
        "streetCityCountry":
            MessageLookupByLibrary.simpleMessage("Street, City, Country"),
        "submit": MessageLookupByLibrary.simpleMessage("Submit"),
        "subtotal": MessageLookupByLibrary.simpleMessage("Subtotal"),
        "swipeLeftTheNotificationToDeleteOrReadUnreadIt":
            MessageLookupByLibrary.simpleMessage(
                "Swipe left the notification to delete or read / unread it"),
        "tapAgainToLeave":
            MessageLookupByLibrary.simpleMessage("Tap again to leave"),
        "tax": MessageLookupByLibrary.simpleMessage("TAX"),
        "tell_us_about_this_food":
            MessageLookupByLibrary.simpleMessage("Tell us about this food"),
        "tell_us_about_this_restaurant": MessageLookupByLibrary.simpleMessage(
            "Tell us about this restaurant"),
        "testApiConnection":
            MessageLookupByLibrary.simpleMessage("Test API Connection"),
        "testLocalNotification":
            MessageLookupByLibrary.simpleMessage("Test Local Notification"),
        "testNotification":
            MessageLookupByLibrary.simpleMessage("Test Notification"),
        "testNotificationBody":
            MessageLookupByLibrary.simpleMessage("This is a test notification"),
        "testNotificationSent": MessageLookupByLibrary.simpleMessage(
            "Test notification sent successfully"),
        "testNotifications":
            MessageLookupByLibrary.simpleMessage("Test Notifications"),
        "testingApiConnection":
            MessageLookupByLibrary.simpleMessage("Testing API connection..."),
        "theFoodWasRemovedFromYourCart": m9,
        "the_address_updated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "The address updated successfully"),
        "the_food_has_been_rated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "The food has been rated successfully"),
        "the_restaurant_has_been_rated_successfully":
            MessageLookupByLibrary.simpleMessage(
                "The restaurant has been rated successfully"),
        "thisFoodWasAddedToFavorite": MessageLookupByLibrary.simpleMessage(
            "This food was added to favorite"),
        "thisFoodWasRemovedFromFavorites": MessageLookupByLibrary.simpleMessage(
            "This food was removed from favorites"),
        "thisNotificationHasMarkedAsRead": MessageLookupByLibrary.simpleMessage(
            "This notification has marked as read"),
        "thisNotificationHasMarkedAsUnread":
            MessageLookupByLibrary.simpleMessage(
                "This notification has marked as unread"),
        "thisRestaurantNotSupportDeliveryMethod":
            MessageLookupByLibrary.simpleMessage(
                "This restaurant not support delivery method."),
        "this_account_not_exist":
            MessageLookupByLibrary.simpleMessage("This account not exist"),
        "this_email_account_exists":
            MessageLookupByLibrary.simpleMessage("This email account exists"),
        "this_food_was_added_to_cart":
            MessageLookupByLibrary.simpleMessage("This food was added to cart"),
        "this_restaurant_is_closed_":
            MessageLookupByLibrary.simpleMessage("This restaurant is closed"),
        "timeFormatHhMm": MessageLookupByLibrary.simpleMessage("HH:mm"),
        "tip_check_card_info": MessageLookupByLibrary.simpleMessage(
            "• Double-check your card information."),
        "tip_contact_issuer": MessageLookupByLibrary.simpleMessage(
            "• Contact your card issuer to verify your account."),
        "tip_use_different_card": MessageLookupByLibrary.simpleMessage(
            "• Use a different card or alternative method."),
        "tips_complete_order":
            MessageLookupByLibrary.simpleMessage("Tips to complete your order"),
        "topRestaurants":
            MessageLookupByLibrary.simpleMessage("Top Restaurants"),
        "top_restaurants":
            MessageLookupByLibrary.simpleMessage("Top Restaurants"),
        "total": MessageLookupByLibrary.simpleMessage("Total"),
        "tracking": MessageLookupByLibrary.simpleMessage("Tracking"),
        "tracking_order":
            MessageLookupByLibrary.simpleMessage("Tracking Order"),
        "tracking_refreshed_successfuly": MessageLookupByLibrary.simpleMessage(
            "Tracking refreshed successfully"),
        "transaction_declined": MessageLookupByLibrary.simpleMessage(
            "Transaction has been declined"),
        "trendingThisWeek":
            MessageLookupByLibrary.simpleMessage("Trending This Week"),
        "trending_this_week":
            MessageLookupByLibrary.simpleMessage("Trending This Week"),
        "twentyToThirtyMin": MessageLookupByLibrary.simpleMessage("20-30 min"),
        "typeToStartChat":
            MessageLookupByLibrary.simpleMessage("Type to start chat"),
        "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "unreadNotifications":
            MessageLookupByLibrary.simpleMessage("Unread Notifications"),
        "useThisAddress":
            MessageLookupByLibrary.simpleMessage("Use this address"),
        "validCouponCode": MessageLookupByLibrary.simpleMessage("Valid Coupon"),
        "verification_failed":
            MessageLookupByLibrary.simpleMessage("Verification failed"),
        "verification_instruction": m7,
        "verification_title":
            MessageLookupByLibrary.simpleMessage("Verification Code"),
        "verify": MessageLookupByLibrary.simpleMessage("Verify"),
        "verifyCode": MessageLookupByLibrary.simpleMessage("Verify Code"),
        "verifyPhoneNumber":
            MessageLookupByLibrary.simpleMessage("Verify Phone Number"),
        "verifyYourInternetConnection": MessageLookupByLibrary.simpleMessage(
            "Verify your internet connection"),
        "verify_your_internet_connection": MessageLookupByLibrary.simpleMessage(
            "Verify your internet connection"),
        "verify_your_quantity_and_click_checkout":
            MessageLookupByLibrary.simpleMessage(
                "Verify your quantity and click checkout"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "view": MessageLookupByLibrary.simpleMessage("View"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
        "visa_card": MessageLookupByLibrary.simpleMessage("Visa Card"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning"),
        "weAreSendingOtpToValidateYourMobileNumberHang":
            MessageLookupByLibrary.simpleMessage(
                "We are sending OTP to validate your mobile number"),
        "welcome": MessageLookupByLibrary.simpleMessage("Welcome"),
        "whatTheySay": MessageLookupByLibrary.simpleMessage("What They Say ?"),
        "what_they_say": MessageLookupByLibrary.simpleMessage("What They Say"),
        "what_would_you_like_today": MessageLookupByLibrary.simpleMessage(
            "🔹 What would you like today?"),
        "work": MessageLookupByLibrary.simpleMessage("Work"),
        "writeEmailAndPassword": MessageLookupByLibrary.simpleMessage(
            "Write your email and password 💁‍♂️"),
        "wrong_email_or_password":
            MessageLookupByLibrary.simpleMessage("Wrong email or password"),
        "wrong_password":
            MessageLookupByLibrary.simpleMessage("Incorrect password"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "youDontHaveAnyConversations": MessageLookupByLibrary.simpleMessage(
            "You don\'t have any conversations"),
        "youDontHaveAnyOrder":
            MessageLookupByLibrary.simpleMessage("You don\'t have any order"),
        "you_can_discover_restaurants": MessageLookupByLibrary.simpleMessage(
            "You can discover restaurants & fastfood arround you and choose you best meal after few minutes we prepare and delivere it for you"),
        "you_must_add_foods_of_the_same_restaurants_choose_one":
            MessageLookupByLibrary.simpleMessage(
                "You must add foods from the same restaurant"),
        "you_must_signin_to_access_to_this_section":
            MessageLookupByLibrary.simpleMessage(
                "You must sign in to access this section"),
        "yourCreditCardNotValid":
            MessageLookupByLibrary.simpleMessage("Your credit card not valid"),
        "yourOrderHasBeenSuccessfullySubmitted":
            MessageLookupByLibrary.simpleMessage(
                "Your order has been successfully submitted!"),
        "your_address": MessageLookupByLibrary.simpleMessage("Your Address"),
        "your_biography":
            MessageLookupByLibrary.simpleMessage("Your biography"),
        "your_credit_card_not_valid": MessageLookupByLibrary.simpleMessage(
            "Your credit card is not valid"),
        "your_location": MessageLookupByLibrary.simpleMessage("Your location"),
        "your_order_has_been_successfully_submitted":
            MessageLookupByLibrary.simpleMessage(
                "Your order has been successfully submitted"),
        "your_reset_link_has_been_sent_to_your_email":
            MessageLookupByLibrary.simpleMessage(
                "Your reset link has been sent to your email")
      };
}
