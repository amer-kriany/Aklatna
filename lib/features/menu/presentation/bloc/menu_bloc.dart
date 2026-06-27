import 'package:aklatna/features/menu/domain/entity/menuCategoryEntity.dart';
import 'package:aklatna/features/menu/domain/entity/menuItemEntity.dart';
import 'package:aklatna/features/menu/domain/usecases/getCategoriesUseCase.dart';
import 'package:aklatna/features/menu/domain/usecases/getItemsUsecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
    final Getcategoriesusecase menuCategoriesusecase;
  final Getitemsusecase menuItemsusecase;
  MenuBloc({required this.menuCategoriesusecase, required this.menuItemsusecase}) : super(MenuInitial()) {
    on<GetMenu>(_getMenu);
  }
   // get menu categories and items
  Future<void> _getMenu(
    GetMenu event,
    Emitter<MenuState> emit,
  ) async {
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
