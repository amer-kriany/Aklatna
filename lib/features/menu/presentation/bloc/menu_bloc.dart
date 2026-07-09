import 'package:aklatna/features/menu/domain/entity/menuCategoryEntity.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final Getcategoriesusecase menuCategoriesusecase;
  final Getitemsusecase menuItemsusecase;
  MenuBloc({
    required this.menuCategoriesusecase,
    required this.menuItemsusecase,
  }) : super(MenuInitial()) {
    on<GetMenu>(_getMenu);
    on<GetAllMenu>(_getAllMenu);
  }
  // get menu categories and items
  Future<void> _getMenu(GetMenu event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final categories = await menuCategoriesusecase();
      final items = await menuItemsusecase();
      Menuitementity? item;
      Menucategoryentity? category;
      for (int i = 0; i < items.length; i++) {
        if (items[i].id == event.id) {
          item = items[i];
          final categoryId = item.categoryId;
          for (int j = 0; j < categories.length; j++) {
            if (categories[j].id == categoryId) {
               category = categories[j];
            }
          }
          break;
        }
      }
      if (item == null || category == null) {
        throw Exception('Menu item with id ${event.id} not found');
      }
      emit(MenuLoaded(category: category, item: item));
    } catch (e) {
      emit(MenuError(message: e.toString()));
    }
  }

Future<void> _getAllMenu(GetAllMenu event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final categories = await menuCategoriesusecase();
      final items = await menuItemsusecase();
      emit(MenuAllLoaded(items: items, categories: categories));
    } catch (e) {
      emit(MenuError(message: e.toString()));
    }
  }
}
