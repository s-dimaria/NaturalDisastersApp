import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';
import 'package:natural_disaster_app/constant/constant.dart';
import 'package:natural_disaster_app/constant/enumtype.dart';
import 'package:natural_disaster_app/model/user.dart';

class AccessScreen extends StatefulWidget {
  AccessScreen({required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  /** CONTROLLER **/
  final _controllerPass = TextEditingController();
  final _controllerRepPass = TextEditingController();

  /** VARIABLE **/
  final formKey = new GlobalKey<FormState>();
  bool viewPass = true;
  bool viewConfPass = true;

  String _email = "";
  String _password = "";
  FormType _formType = FormType.login;

  /** MOVE TO REGISTER/LOGIN/FORGOT STATE **/
  void moveToRegister() {
    formKey.currentState!.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState!.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  void moveToForgot() {
    formKey.currentState!.reset();
    setState(() {
      _formType = FormType.forgot;
    });
  }

  /*** AUTHENTICATION FIREBASE ***/
  bool validateAndSave() {
    final form = formKey.currentState;

    if (_formType == FormType.login) {
      if (form!.validate()) {
        form.save();
        return true;
      }
    } else if (_formType == FormType.register) {
      if (form!.validate()) {
        form.save();
        if (_controllerPass.text == _controllerRepPass.text) {
          return true;
        } else {
          Fluttertoast.showToast(
              msg: "Passwords not matches!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          _controllerPass.clear();
          _controllerRepPass.clear();
          return false;
        }
      }
    } else {
      if (form!.validate()) {
        form.save();
        return true;
      }
    }
    return false;
  }

  /* LOGIN / REGISTER / FORGOT */
  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        var auth = MultipleProvider.of(context).auth;
        var dbStorage = MultipleProvider.of(context).dbRealtime;
        if (_formType == FormType.login) {
          String userId =
              await auth.signInWithEmailAndPassword(_email, _password);
          print('Saved user id: $userId');
          if (userId.isNotEmpty) {
            formKey.currentState!.reset();
            _controllerPass.clear();
            widget.onSignedIn();
          }
        } else if (_formType == FormType.register) {
          String userId =
              await auth.createUserWithEmailAndPassword(_email, _password);
          if (userId.isNotEmpty) {
            formKey.currentState!.reset();
            ModelUser _user = ModelUser(
                _email, _email.substring(0, _email.lastIndexOf('@')), "utente");
            dbStorage.createUser(_user);
            widget.onSignedIn();
          }
        } else {
          if (await auth.sendPasswordResetEmail(_email)) {
            moveToLogin();
          }
        }
      } catch (e) {
        formKey.currentState!.reset();
        _controllerRepPass.clear();
        _controllerPass.clear();
      }
    }
  }

  /*** WIDGET BUILD***/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Form(
          key: formKey,
          child: GestureDetector(
            child: Stack(
              children: <Widget>[
                Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Color(0xfffc4a1a),
                          Color(0xfff7b733),
                          //Color(0xffFDC830),
                        ])),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 80,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buildInputs() + buildSubmitButton(),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  /** WIDGET **/
  List<Widget> buildInputs() {
    if (_formType != FormType.forgot) {
      return [
        Image.asset(
          Constants.LOGOAPP,
          height: 200,
        ),
        buildEmail(),
        SizedBox(height: 30),
        buildPassword(),
      ];
    } else {
      return [
        Image.asset(
          Constants.LOGOAPP,
          height: 200,
        ),
        buildEmail(),
        SizedBox(height: 30),
      ];
    }
  }

  List<Widget> buildSubmitButton() {
    if (_formType == FormType.login) {
      return [
        buildLabelForgotPassword(),
        buildLoginBtn(),
        buildLabelSignUp(),
      ];
    } else if (_formType == FormType.register) {
      return [
        SizedBox(height: 30),
        buildRepeatPassword(),
        SizedBox(height: 30),
        buildRegisterBtn(),
        buildLabelSignIn(),
      ];
    } else {
      return [
        buildForgotPassBtn(),
        buildLabelSignIn(),
      ];
    }
  }

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ]),
            height: 60,
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value!.isEmpty ? 'Email can\'t be empty' : null,
              onSaved: (value) => _email = value!,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                    fontSize: 15.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 15, left: 50),
                  prefixIcon: Icon(Icons.email, color: Color(0xffF37335)),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.black38)),
            ))
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ]),
            height: 60,
            child: TextFormField(
              obscureText: viewPass,
              validator: (value) =>
                  value!.isEmpty ? 'Password can\'t be empty' : null,
              onSaved: (value) => _password = value!,
              controller: _controllerPass,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                    fontSize: 15.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 15, left: 50),
                  prefixIcon: Icon(Icons.lock, color: Color(0xffF37335)),
                  suffixIcon: IconButton(
                    color: Color(0xffF37335),
                    icon: Icon(
                        viewPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        viewPass = !viewPass;
                      });
                    },
                  ),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.black38)),
            ))
      ],
    );
  }

  Widget buildRepeatPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Confirm Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ]),
            height: 60,
            child: TextFormField(
              obscureText: viewConfPass,
              validator: (value) =>
                  value!.isEmpty ? 'Password can\'t be empty' : null,
              controller: _controllerRepPass,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                    fontSize: 15.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 15, left: 50),
                  prefixIcon: Icon(Icons.lock, color: Color(0xffF37335)),
                  suffixIcon: IconButton(
                    color: Color(0xffF37335),
                    icon: Icon(
                        viewConfPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        viewConfPass = !viewConfPass;
                      });
                    },
                  ),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.black38)),
            ))
      ],
    );
  }

  Widget buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: validateAndSubmit,
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.orange,
          shadowColor: Colors.orange,
          elevation: 5,
          padding: EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'LOGIN',
          style: TextStyle(
              color: Color(0xffF37335),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildRegisterBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: validateAndSubmit,
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.orange,
          shadowColor: Colors.orange,
          elevation: 5,
          padding: EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'SIGN IN',
          style: TextStyle(
              color: Color(0xffF37335),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildForgotPassBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: validateAndSubmit,
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.orange,
          shadowColor: Colors.orange,
          elevation: 5,
          padding: EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'FORGOT PASSWORD',
          style: TextStyle(
              color: Color(0xffF37335),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildLabelSignUp() {
    return GestureDetector(
      onTap: moveToRegister, //your login class name
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400)),
          TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget buildLabelSignIn() {
    return GestureDetector(
      onTap: moveToLogin, //your login class name
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: 'Have an Account? ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400)),
          TextSpan(
              text: 'Login',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget buildLabelForgotPassword() {
    return Container(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
            onPressed: moveToForgot,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.only(right: 0),
              primary: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Text('Forgot Password?',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))));
  }
}
