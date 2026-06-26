import 'package:aklatna/features/menu/domain/entity/menuCategoryEntity.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final Getcategoriesusecase menuCategoriesusecase;
  final Getitemsusecase menuItemsusecase;
  MenuCubit({required this.menuCategoriesusecase, required this.menuItemsusecase}) : super(MenuInitial());
  
  // get menu categories and items
  Future<void> getMenu() async {
    emit(MenuLoading());
    try {
      final categories = await menuCategoriesusecase();
      final items = await menuItemsusecase();
      emit(MenuLoaded(categories: categories, items: items));
    } catch (e) {
      emit(MenuError(message: e.toString()));
    }
  }
}
