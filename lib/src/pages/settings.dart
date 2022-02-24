import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/settings_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/ProfileSettingsDialog.dart';
import '../../core/utils/helper.dart';
import '../repository/user_repository.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateMVC<SettingsWidget> {
  late SettingsController _con;
  TextEditingController passwordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();

  _SettingsWidgetState() : super(SettingsController()) {
    _con = controller as SettingsController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context)!.settings,
            style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: currentUser.value.id == null
            ? CircularLoadingWidget(height: 500)
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  currentUser.value.name!,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                Text(
                                  currentUser.value.email!,
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                          SizedBox(
                              width: 55,
                              height: 55,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(300),
                                onTap: () {
                                  Navigator.of(context).pushNamed('/Pages', arguments: 0);
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(currentUser.value.image!.thumb!),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                              S.of(context)!.profile_settings,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            trailing: ButtonTheme(
                              padding: EdgeInsets.all(0),
                              minWidth: 50.0,
                              height: 25.0,
                              child: ProfileSettingsDialog(
                                user: currentUser.value,
                                onChanged: () {
                                  _con.update(currentUser.value);
                                  //setState(() {});
                                },
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context)!.full_name,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            trailing: Text(
                              currentUser.value.name!,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context)!.email,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            trailing: Text(
                              currentUser.value.email!,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context)!.phone,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            trailing: Text(
                              currentUser.value.phone!,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context)!.address,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            trailing: Text(
                              Helper.limitString(currentUser.value.address??""),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context)!.about,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            trailing: Text(
                              Helper.limitString(currentUser.value.bio!),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text(
                              S.of(context)!.app_settings,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    title: new Text(S.of(context)!.change_password),
                                    content: Container(
                                      height: 100,
                                      child: Column(
                                      children: [
                                        TextField(
                                          obscureText: true,
                                          controller: passwordController,
                                          decoration: InputDecoration(
                                            hintText: 'ادخل كلمة المرور الحاليا ',
                                          ),
                                        ),
                                        TextField(
                                          obscureText: true,
                                          controller: newPasswordController,
                                          decoration: InputDecoration(
                                            hintText: 'ادخل كلمة المرور الجديدة ',
                                          ),
                                        ),
                                      ],
                                    ),
                                    ),
                                    actions: <Widget>[
                                      // usually buttons at the bottom of the dialog
                                      Row(
                                        children: <Widget>[
                                          new FlatButton(
                                            child: new Text("الغاء"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          new FlatButton(
                                            onPressed: () {
                                              currentUser.value.password = passwordController.text;
                                              currentUser.value.newPassword = newPasswordController.text;
                                              _con.updatePass(currentUser.value);
                                              Navigator.pop(context);
                                              passwordController.clear();
                                              newPasswordController.clear();
                                            },
                                            child: new Text("حفظ"),
                                          )
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.lock,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context)!.change_password,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Languages');
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.translate,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context)!.languages,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                            // trailing: Text(
                            //   S.of(context).english,
                            //   style: TextStyle(color: Theme.of(context).focusColor),
                            // ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Help');
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.help,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context)!.help_support,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }
}
