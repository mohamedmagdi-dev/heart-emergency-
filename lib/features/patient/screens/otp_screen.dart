// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// import '../../../core/constants/app_colors.dart';
// import '../widgets/custom_alert_dialog.dart';
//
//
// class OtpScreen extends StatelessWidget {
//
//   // ignore: prefer_const_constructors_in_immutables
//   final phoneNumber;
//   OtpScreen({super.key,required this.phoneNumber});
//   late String otpCode;
//
// //late final String phoneNumber;
//   Widget  _buildIntoText(){
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "verfiy your phone number ",
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(
//           height: 30,
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 2),
//           child: RichText(text: TextSpan( text: "Enter your 6 digits code numbers sent to",style: TextStyle(
//             color: Colors.black,fontSize: 18,
//             height: 1.4,
//
//           ),
//               children:<TextSpan> [
//                 TextSpan(
//                     text: "  ",style: TextStyle(
//                   color: Colors.blue,
//
//                 )
//                 ),
//               ]
//           ),),
//         )
//       ],
//     );
//   }
//   Widget    _buildPinCodeFields(BuildContext context){
//     return Container(
//       child: PinCodeTextField(
//         appContext: context,
//         length: 6,
//         autoFocus: true,
//         cursorColor: Colors.black,
//         keyboardType: TextInputType.number,
//         obscureText: false,
//         animationType: AnimationType.fade,
//         pinTheme: PinTheme(
//           shape: PinCodeFieldShape.box,
//           borderRadius: BorderRadius.circular(5),
//           fieldHeight: 50,
//           borderWidth: 1,
//           fieldWidth: 40,
//
//           activeColor: AppColor.blue,
//           activeFillColor:AppColor.lightBlue,
//           inactiveColor: AppColor.blue,
//           inactiveFillColor:  Colors.white,
//           selectedColor: AppColor.blue,
//           selectedFillColor: Colors.white,
//         ),
//         animationDuration: Duration(milliseconds: 300),
//         backgroundColor: Colors.white,
//         enableActiveFill: true,
//         // errorAnimationController: errorController,
//         // controller: textEditingController,
//         onCompleted: (code) {
//           otpCode=code;
//           print("Completed");
//         },
//         onChanged: (value) {
//           print(value);
//
//         },
//         // beforeTextPaste: (text) {
//         //   print("Allowing to paste $text");
//         //   //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
//         //   //but you can show anything you want here, like your pop up saying wrong paste format or etc
//         //   return true;
//         // },
//
//       ),
//
//     );
//   }
//   _login(BuildContext context) {
//     BlocProvider.of<PhoneAuthCubit>(context).submitOtp(otpCode);
//   }
//   Widget _buildVerfiyButton(context){
//     return Align(
//       alignment: Alignment.centerRight,
//       child:ElevatedButton(onPressed:() {
//         showProgressIndactor(context);
//         _login(context);
//       },
//         style: ButtonStyle(
//           minimumSize: WidgetStatePropertyAll(Size(110,50)),
//           backgroundColor: WidgetStatePropertyAll<Color>(Colors.black,),
//           shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),),),
//         ),
//         child:Text("Verify",style: TextStyle(
//             color: Colors.white,
//             fontSize: 16
//         ),
//
//         ) ,
//       ),
//     );
//   }
//   Widget _buildPhoneVerfiycationBloc(){
//     return BlocListener<PhoneAuthCubit, PhoneAuthState>(
//       listenWhen: (previous, current) {
//         return previous != current;
//       },
//       listener: (context, state) {
//         if (state is PhoneLoadingState) {
//           return showProgressIndactor(context);
//         } else if (state is PhoneOtpVerify) {
//           Navigator.pop(context);
//           Navigator.pushReplacementNamed(context, mapScreen,/*  arguments: phoneNumber */);
//         } else if (state is PhoneErrorState) {
//           String errorMessage = state.errorMessage;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(errorMessage),
//               backgroundColor: Colors.black,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         }
//       },
//       child: Container(),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 32,vertical: 88),
//             child: Column(
//               children: [
//                 _buildIntoText(),
//                 const SizedBox(height: 66,),
//                 _buildPinCodeFields(context),
//                 const SizedBox(height: 66,),
//                 _buildVerfiyButton(context),
//                 const SizedBox(height: 40,),
//                 _buildPhoneVerfiycationBloc(),
//
//               ],
//
//             ),
//
//           ),
//         ),
//       ),
//     );
//   }
// }