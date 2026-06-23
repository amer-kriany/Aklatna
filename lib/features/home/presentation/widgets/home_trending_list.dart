import 'package:aklatna/features/home/presentation/cubit/business_cubit.dart';
import 'package:aklatna/features/home/presentation/widgets/trending_resturant_card.dart';
import 'package:flutter/material.dart';

import 'package:aklatna/features/home/presentation/widgets/home_empty_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeTrendingList extends StatelessWidget {
  const HomeTrendingList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessCubit, BusinessState>(
      listener: (context, state) {
         if (state is BusinessError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("error fetching data")));
        }
      },
      
   
      
      builder: (context, state) {
        if(state is BusinessError){
                    return const HomeEmptySection(height: 0);


        }
       
        if (state is BusinessLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is BusinessFetched) {
          if (state.businesses.isEmpty) {
            return const HomeEmptySection(height: 0);
          }
          return SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              scrollDirection: Axis.horizontal,
              itemCount: state.businesses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = state.businesses[index];
                return TrendingResturantCard(item: item);
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}
