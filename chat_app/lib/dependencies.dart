import 'package:get_it/get_it.dart';
import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_app/features/auth/domain/services/auth_service.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/check_login_status_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:chat_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/domain/services/chat_service.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:chat_app/features/chat/domain/usecases/send_voice_message_usecase.dart';
import 'package:chat_app/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:chat_app/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';
import 'package:chat_app/features/friends/domain/services/friends_service.dart';
import 'package:chat_app/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:chat_app/features/friends/domain/usecases/search_users_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/get_users_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/get_friend_requests_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/get_friends_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/send_friend_request_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/accept_friend_request_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/reject_friend_request_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<AuthService>(() => AuthServiceImpl(sl()));
  sl.registerLazySingleton<ChatService>(() => ChatServiceImpl());
  sl.registerLazySingleton<FriendsService>(() => FriendsServiceImpl(
    getUsers: sl(),
    getFriendRequests: sl(),
    getFriends: sl(),
    sendFriendRequest: sl(),
    acceptFriendRequest: sl(),
    rejectFriendRequest: sl(),
    searchUsers: sl(),
  ));

  // Blocs
  sl.registerLazySingleton(() => AuthBloc(authService: sl()));
  sl.registerLazySingleton(() => ChatBloc(chatService: sl()));
  sl.registerLazySingleton(() => FriendsBloc(friendsService: sl()));

  // Use cases
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckLoginStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => SendVoiceMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendsUseCase(sl()));
  sl.registerLazySingleton(() => SendFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => AcceptFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FriendsRepository>(
    () => FriendsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<FriendsRemoteDataSource>(
    () => FriendsRemoteDataSourceImpl(),
  );
}