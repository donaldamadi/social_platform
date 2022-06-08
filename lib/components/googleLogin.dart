// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:student_paddy_mobile/components/simpleButton.dart';
// import 'package:student_paddy_mobile/network/requestHandler.dart';
// import 'package:student_paddy_mobile/utils/colors.dart';
// import 'package:student_paddy_mobile/utils/helpers.dart';

// class GLogin extends StatefulWidget {
//   @override
//   _GLoginState createState() => _GLoginState();
// }

// class _GLoginState extends State<GLogin> {
//   bool loading = false;

//   GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email', 'profile'],
//   );

//   submit() async {
//     try {
//       await _googleSignIn.signOut();
//       final response = await _googleSignIn.signIn().catchError((e){//  print("Error: $e");});
//       final googleKey = await response!.authentication;
//       setState(() {
//         loading = true;
//       });
//       bool status = await socialAuth(context, googleKey.idToken!, type: "google");
//       if (!status) {
//         setState(() {
//           loading = false;
//         });
//       }
//     } catch (error) {
//       //  print(error);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return simpleButton("Continue with google", context, backColor: colors.googleRed, padH: getWidth(context), onTap: submit, loading: loading, disabled: loading);
//   }
// }
