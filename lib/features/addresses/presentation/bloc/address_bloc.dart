import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/domain/usecases/useCases.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddressesUsecase getAddressesUsecase;
  final AddAddressUsecase addAddressUsecase;
  final DeleteAddressUsecase deleteAddressUsecase;
  final SetDefaultAddressUsecase setDefaultAddressUsecase;

  AddressBloc({
    required this.getAddressesUsecase,
    required this.addAddressUsecase,
    required this.deleteAddressUsecase,
    required this.setDefaultAddressUsecase,
  }) : super(AddressInitial()) {
    on<LoadAddressesEvent>(_onLoad);
    on<AddAddressEvent>(_onAdd);
    on<DeleteAddressEvent>(_onDelete);
    on<SetDefaultAddressEvent>(_onSetDefault);
    on<UpdateAddressEvent>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadAddressesEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await getAddressesUsecase(event.userId);
      emit(AddressLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }
  Future<void> _onUpdate(
  UpdateAddressEvent event,
  Emitter<AddressState> emit,
) async {
  try {
    emit(AddressLoading());

    // Delete old address first
    await deleteAddressUsecase(event.addressId);

    // Add updated address
    await addAddressUsecase(
      userId: event.userId,
      label: event.label,
      street: event.street,
      city: event.city,
      apartment: event.apartment,
      isDefault: event.isDefault,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    // Reload
    final addresses = await getAddressesUsecase(event.userId);

    emit(AddressLoaded(addresses: addresses));
  } catch (e) {
    emit(AddressError(message: e.toString()));
  }
}

  Future<void> _onAdd(
  AddAddressEvent event,
  Emitter<AddressState> emit,
) async {
  try {
    emit(AddressLoading());

    await addAddressUsecase(
  userId: event.userId,
  label: event.label,
  street: event.street,
  city: event.city,
  apartment: event.apartment,
  isDefault: event.isDefault,
  latitude: event.latitude,
  longitude: event.longitude,
);

    final addresses = await getAddressesUsecase(event.userId);

    emit(AddressLoaded(addresses: addresses));
  } catch (e) {
    emit(AddressError(message: e.toString()));
  }
}

 Future<void> _onDelete(
  DeleteAddressEvent event,
  Emitter<AddressState> emit,
) async {
  try {
    // 1. Delete address
    await deleteAddressUsecase(event.addressId);

    // 2. Fetch updated address list
    final addresses = await getAddressesUsecase(event.userId);

    // 3. Emit updated list
    emit(AddressLoaded(addresses: addresses));
  } catch (e) {
    emit(AddressError(message: e.toString()));
  }
}

  Future<void> _onSetDefault(
    SetDefaultAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    try {
      emit(AddressLoading());

      await setDefaultAddressUsecase(
        userId: event.userId,
        addressId: event.addressId,
      );

      final addresses = await getAddressesUsecase(event.userId);

      emit(AddressLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }
}
