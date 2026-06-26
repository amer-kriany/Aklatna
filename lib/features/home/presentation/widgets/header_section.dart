import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/presentation/widgets/HomeSearchBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HeaderSection extends StatelessWidget {
  final BusinessEntity businessEntity;
  const HeaderSection({super.key, required this.businessEntity});

  @override
  Widget build(BuildContext context) {
    String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صباح الخير';
    if (hour >= 12 && hour < 17) return 'مساء الخير';
    if (hour >= 17 && hour < 21) return 'مساء النور';
    return 'أهلاً';
  }
    return Scaffold(
      body:  Column(
          spacing: 22,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Delivery to "),
                    Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.location_on_sharp, color: Colors.black),
                        // user adress after adding profile
                        Text("jableh,syria"),
                      ],
                    ),
                  ],
                ),
                ClipRRect(borderRadius: BorderRadius.circular(20),
                // user photo after adding profile 
                child:Container() ,)
              ],

            ),
            Text(_getGreeting()),

            

          ],
        ),
      
    );
  }
}
