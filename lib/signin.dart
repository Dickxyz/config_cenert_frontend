import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_dashboard_ui/api/requests.dart';
import 'package:responsive_dashboard_ui/provider.dart';
import 'components/singinContainer.dart';
import 'signup.dart';

class SignInPage extends ConsumerWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignInPage({Key? key}) : super(key: key);

  Widget _usernameWidget(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        TextFormField(
          controller: _usernameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
                color: Color.fromRGBO(173, 183, 192, 1),
                fontWeight: FontWeight.bold),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(173, 183, 192, 1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordWidget(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        TextFormField(
          controller: _passwordController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(
                color: Color.fromRGBO(173, 183, 192, 1),
                fontWeight: FontWeight.bold),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(173, 183, 192, 1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () async {
          await login(_usernameController.value.text, _passwordController.value.text);
          ref.read(loginStateProvider.notifier).state = true;
          ref.refresh(myApplyListProvider);
          ref.refresh(otherApplyListProvider);
          ref.refresh(myTenantProvider);
          context.go("/home");
        },
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '登 入',
            style: TextStyle(
                color: Color.fromRGBO(76, 81, 93, 1),
                fontSize: 25,
                fontWeight: FontWeight.w500,
                height: 1.6),
          ),
          SizedBox.fromSize(
            size: Size.square(70.0), // button width and height
            child: ClipOval(
              child: Material(
                color: Color.fromRGBO(76, 81, 93, 1),
                child: Icon(Icons.arrow_forward,
                    color: Colors.white), // button color
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _createAccountLabel(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () => context.go("/signup"),
            child: Text(
              '注册新账号',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned(
                height: MediaQuery.of(context).size.height * 0.50,
                child: SigninContainer()),
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(height: height * .55),
                        _usernameWidget(context, ref),
                        SizedBox(height: 20),
                        _passwordWidget(context, ref),
                        SizedBox(height: 30),
                        _submitButton(context, ref),
                        SizedBox(height: height * .050),
                        _createAccountLabel(context, ref),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(top: 60, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
