import 'package:aklatna/features/auth/data/datasources/auth_datasource.dart';
import 'package:aklatna/features/auth/data/models/appuser_model.dart';
import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';
import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;
  AuthRepositoryImpl({required this.datasource});

  @override
  Future<AppuserEntity> signUp({
   required String email,
   required  String password,
   required  String username,
    required String phone,
  }) async {
    final formattedPhone =  phone.startsWith('+')?phone:
    phone.startsWith('0')
        ? '+963${phone.substring(1)}'
        : '+963$phone';
    final user = await datasource.signUp(
      email: email,
      password: password,
      username: username,
      phone: formattedPhone,
    );
    if (user == null) throw Exception("Failed to sign up");
    return mapToEntity(user);
  }

  @override
  Future<AppuserEntity> signIn(
    String? email,
    String? phone,
    String password,
  ) async {
    final AppuserModel? user;
    
    if (phone == null) {
       user = await datasource.signIn( email, phone,  password);
    } else {
      final formattedPhone = phone.startsWith('0')
          ? '+963${phone.substring(1)}'
          : phone;
       user = await datasource.signIn( email,  formattedPhone,  password);
    }

    if (user == null) throw Exception("Failed to sign in");
    return mapToEntity(user);
  }

  @override
  Future<AppuserEntity> getCurrentUser() async {
    final user = await datasource.getCurrentUser();
    if (user == null) throw Exception("No user found");
    return mapToEntity(user);
  }

  @override
  Future<void> signOut() {
    return datasource.signOut();
  }

  mapToEntity(AppuserModel model) {
    return AppuserEntity(
      id: model.id,
      userName: model.userName,
      email: model.email,
      phone: model.phone,
      isPhoneverified: model.isPhoneverified,
    );
  }
}
