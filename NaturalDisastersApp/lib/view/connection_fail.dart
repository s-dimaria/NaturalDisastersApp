import 'package:flutter/material.dart';

class ConnectionDown extends StatelessWidget {
  const ConnectionDown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/no_connection.png"),
                      ),
                    ),
                  ),
                  Text("No Internet Connection",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 15, left: 15, right: 15, bottom: 1),
                    child: Text(
                      "You are not connected to the internet.",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    "Make sure Wi-fi or Mobile Data is on.",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ])));
  }
}
