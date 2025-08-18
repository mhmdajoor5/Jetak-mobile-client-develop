import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../helpers/helper.dart';
import '../models/setting.dart';
import '../models/user.dart' as user_model;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';
import '../services/intercom_service.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  _DrawerWidgetState() : super(ProfileController());

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (context, user, _) {
        return Drawer(
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  user.apiToken != null
                      ? Navigator.of(context).pushNamed('/Profile')
                      : Navigator.of(context).pushNamed('/Login');
                },
                child: user.apiToken != null
                    ? UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.1)),
                  accountName: Text(user.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
                  accountEmail: Text(user.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                  currentAccountPicture: Stack(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(80)),
                          child: CachedNetworkImage(
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: user.image?.thumb ?? '',
                            placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, width: double.infinity, height: 80),
                            errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      if (user.verifiedPhone ?? false)
                        Positioned(top: 0, right: 0, child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 24)),
                    ],
                  ),
                )
                    : Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.1)),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.secondary.withOpacity(1)),
                      const SizedBox(width: 30),
                      Text(S.of(context).guest, style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
              ),
              _buildTile(context, '/Pages', S.of(context).home, Icons.home, 0),
              _buildTile(context, '/Notifications', S.of(context).notifications, Icons.notifications),
              _buildTile(context, '/RecentOrders', S.of(context).my_orders, Icons.local_mall),
              _buildTile(context, '/Favorites', S.of(context).favorite_foods, Icons.favorite),
              _buildIntercomTile(context, S.of(context).messages, Icons.chat),
              _buildDividerTile(context, S.of(context).application_preferences),
              _buildTile(context, '/Help', S.of(context).help__support, Icons.help),
              ListTile(
                onTap: () {
                  if (user.apiToken != null) {
                    Navigator.of(context).pushNamed('/Settings');
                  } else {
                    Navigator.of(context).pushReplacementNamed('/Login');
                  }
                },
                leading: Icon(Icons.settings, color: Theme.of(context).focusColor.withOpacity(1)),
                title: Text(S.of(context).settings, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (user.apiToken != null)
                ListTile(
                  onTap: () {
                    _showDeleteAccountDialog(context, user);
                  },
                  leading: Icon(Icons.delete_forever, color: Colors.red.withOpacity(0.8)),
                  title: Text('Delete Account', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red)),
                ),
              ListTile(
                onTap: () {
                  if (user.apiToken != null) {
                    logout().then((_) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: 0);
                    });
                  } else {
                    Navigator.of(context).pushNamed('/Login');
                  }
                },
                leading: Icon(Icons.exit_to_app, color: Theme.of(context).focusColor.withOpacity(1)),
                title: Text(user.apiToken != null ? S.of(context).log_out : S.of(context).login, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (user.apiToken == null) _buildTile(context, '/SignUp', S.of(context).register, Icons.person_add),
              if (setting.value.enableVersion)
                ListTile(
                  dense: true,
                  title: Text('${S.of(context).version} ${setting.value.appVersion}', style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Icon(Icons.remove, color: Theme.of(context).focusColor.withOpacity(0.3)),
                ),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildTile(BuildContext context, String route, String title, IconData icon, [int? arguments]) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(route, arguments: arguments);
      },
      leading: Icon(icon, color: Theme.of(context).focusColor.withOpacity(1)),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  ListTile _buildIntercomTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      onTap: () {
        IntercomService.displayCustomMessenger();
      },
      leading: Icon(icon, color: Theme.of(context).focusColor.withOpacity(1)),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  ListTile _buildDividerTile(BuildContext context, String title) {
    return ListTile(dense: true, title: Text(title, style: Theme.of(context).textTheme.bodyMedium), trailing: Icon(Icons.remove, color: Theme.of(context).focusColor.withOpacity(0.3)));
  }

  void _showDeleteAccountDialog(BuildContext context, user_model.User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This action will:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text('• Permanently delete your account'),
              Text('• Remove all your data'),
              Text('• Cancel all active orders'),
              Text('• This action cannot be undone'),
              SizedBox(height: 12),
              Text(
                'Please type "DELETE" to confirm:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(context, user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context, user_model.User user) async {
    BuildContext? dialogContext;
    try {
      print('Starting account deletion for user: ${user.email}');

      // إظهار مؤشر التحميل (نحتفظ بسياق الـ dialog لإغلاقه بأمان لاحقاً)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                const Text('Deleting account...'),
              ],
            ),
          );
        },
      );

      // طباعة معلومات المستخدم للتشخيص
      print('User info for deletion:');
      print('- Email: ${user.email}');
      print('- ID: ${user.id}');
      print('- API Token: ${user.apiToken?.substring(0, 10)}...');
      
      // استدعاء API حذف الحساب
      final requestBody = {
        'api_token': user.apiToken,
        'user_id': user.id, // إضافة user_id للتأكد من تحديد المستخدم الصحيح
      };
      
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('https://carrytechnologies.co/api/users/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user.apiToken}',
        },
        body: json.encode(requestBody),
      );

      print('Delete account response: ${response.statusCode} - ${response.body}');

      // إخفاء مؤشر التحميل أولاً عبر سياق الـ dialog
      if (dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      if (response.statusCode == 200) {
        // تحقق من محتوى الاستجابة
        try {
          final responseData = json.decode(response.body);
          final success = responseData['success'] ?? false;
          final message = responseData['message']?.toString() ?? '';
          final data = responseData['data'];
          
          // تحقق من وجود خطأ في البيانات
          final hasError = data != null && data['error'] == true;
          final errorCode = data != null ? data['code'] : null;
          
          print('Response analysis: success=$success, hasError=$hasError, errorCode=$errorCode, message=$message');
          
          if (success && !hasError) {
            // نجح حذف الحساب فعلياً
            print('Account deleted successfully');
            
            // تسجيل الخروج من التطبيق
            await logout();
            
            if (mounted) {
              // إظهار رسالة النجاح أولاً
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              
              // الانتقال إلى صفحة تسجيل الدخول بعد قليل
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/Login', (Route<dynamic> route) => false);
                }
              });
            }
          } else {
            // فشل حذف الحساب
            String errorMessage = message.isNotEmpty ? message : 'Failed to delete account. Please try again.';
            
            if (errorCode == 404) {
              errorMessage = 'API Error: User not found. This might be a server issue. Please contact support.';
            }
            
            print('Failed to delete account: $errorMessage');
            
            if (mounted) {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              } catch (e) {
                print('Error showing SnackBar: $e');
              }
            }
          }
        } catch (e) {
          print('Error parsing response: $e');
          if (mounted) {
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Server response error: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            } catch (e) {
              print('Error showing SnackBar: $e');
            }
          }
        }
      } else {
        // فشل في الاتصال
        String errorMessage = 'Failed to delete account. Please try again.';
        
        try {
          final responseData = json.decode(response.body);
          errorMessage = responseData['message']?.toString() ?? errorMessage;
        } catch (e) {
          print('Error parsing error response: $e');
        }
        
        print('Failed to delete account: $errorMessage');
        
        if (mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          } catch (e) {
            print('Error showing SnackBar: $e');
          }
        }
      }
    } catch (e) {
      print('Error deleting account: $e');
      
      // إخفاء مؤشر التحميل في حالة الخطأ عبر سياق الـ dialog إن وجد
      if (dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }
      
      if (mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network error. Please check your connection and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        } catch (e) {
          print('Error showing SnackBar: $e');
        }
      }
    }
  }
}
