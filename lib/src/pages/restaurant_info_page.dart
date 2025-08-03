import 'package:flutter/material.dart';
import '../models/order.dart';

class RestaurantInfoPage extends StatelessWidget {
  final Order order;

  const RestaurantInfoPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات المطعم'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المطعم
            if (order.restaurant?.image.url != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(order.restaurant!.image.url!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // اسم المطعم
            Text(
              order.getRestaurantName(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // عنوان المطعم
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.getRestaurantAddress(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // معلومات إضافية
            if (order.restaurant != null) ...[
              // تقييم المطعم
              if (order.restaurant!.rate.isNotEmpty && order.restaurant!.rate != '0')
                _buildInfoRow(
                  icon: Icons.star,
                  title: 'التقييم',
                  value: '${order.restaurant!.rate}/5',
                  color: Colors.orange,
                ),
              
              // رسوم التوصيل
              if (order.restaurant!.deliveryFee > 0)
                _buildInfoRow(
                  icon: Icons.delivery_dining,
                  title: 'رسوم التوصيل',
                  value: '${order.restaurant!.deliveryFee.toStringAsFixed(2)} د.ك',
                  color: Colors.green,
                ),
              
              // رقم الهاتف
              if (order.restaurant!.phone.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.phone,
                  title: 'رقم الهاتف',
                  value: order.restaurant!.phone,
                  color: Colors.blue,
                ),
              
              // الهاتف المحمول
              if (order.restaurant!.mobile.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.mobile_friendly,
                  title: 'الهاتف المحمول',
                  value: order.restaurant!.mobile,
                  color: Colors.blue,
                ),
              
              // وقت الإغلاق
              if (order.restaurant!.closingTime.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.access_time,
                  title: 'وقت الإغلاق',
                  value: order.restaurant!.closingTime,
                  color: Colors.purple,
                ),
              
              // نطاق التوصيل
              if (order.restaurant!.deliveryRange > 0)
                _buildInfoRow(
                  icon: Icons.place,
                  title: 'نطاق التوصيل',
                  value: '${order.restaurant!.deliveryRange.toStringAsFixed(1)} كم',
                  color: Colors.teal,
                ),
            ],
            
            const SizedBox(height: 24),
            
            // زر العودة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'العودة',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 