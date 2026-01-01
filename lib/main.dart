// Copyright (c) 2024 suesitran. All rights reserved.
// Original project: Auto Translated Chat
// Author: suesitran
// Repository: https://github.com/suesitran/auto_translated_chat

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_chat/_shared/bloc/authentication/authentication_cubit.dart';
import 'package:public_chat/features/chat/ui/public_chat_screen.dart';
import 'package:public_chat/features/genai_setting/bloc/genai_bloc.dart';
import 'package:public_chat/features/login/ui/login_screen.dart';
import 'package:public_chat/firebase_options.dart';
import 'package:public_chat/service_locator/service_locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'utils/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //   const ip = "127.0.0.1";//192.168.1.25,192.168.1.255
  // final instance = FirebaseFirestore.instance;
  // // Cấu hình Firestore
  // instance.settings = const Settings(
  //   host: '$ip:4000', // Thay đổi port thành 4000
  //   sslEnabled: false,
  //   persistenceEnabled: false,
  // );
  // instance.useFirestoreEmulator(ip, 8080);
  // instance.collection('a').doc().set({'b': 'd'});
  // if (kDebugMode) {
  //   /// NOTE: This setting is to run on Flutter web only
  //   /// to run on Flutter mobile, please set host to be your machine's IP address
  //   /// and update host in file firebase.json
  FirebaseAuth.instance.useAuthEmulator('localhost', 8000);
  FirebaseFirestore.instance
      .useFirestoreEmulator('localhost', 8080); //8002//ok
  FirebaseFirestore.instance.collection('a').doc().set({'b': 'd'});
  FirebaseFunctions.instance.useFunctionsEmulator('192.168.1.25', 5001);
  // }
  ServiceLocator.instance.initialise();
  Global().init();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<AuthenticationCubit>(
      create: (context) => AuthenticationCubit(),
    ),
    BlocProvider<GenaiBloc>(
      create: (context) => GenaiBloc(),
    )
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, state) {
          return const PublicChatScreen();
          if (state is Authenticated) {
          } else {
            return const LoginScreen();
          }
        }));
  }
}
