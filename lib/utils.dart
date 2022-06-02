import 'package:distivity_ctiat/icon_pack_icons.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';


getTextStyle({bool title, Color textColor,TextDecoration textDecoration}) {

    return TextStyle(fontSize: title?40:20, color:textColor,decoration: textDecoration);
}

getSkeletonView(int width,int height){
  return Container(
                        height: height.toDouble(),
                        width: width.toDouble(),
                        decoration: BoxDecoration( color: MyColors.colorGray,borderRadius: BorderRadius.circular(5)),
                      );
}

Widget getAppBar(String title,bool darkmode,{bool backEnabled,bool centered, BuildContext context}){
  if(centered==null){
    centered=false;
  }
  if(backEnabled==null){
    backEnabled=false;
  }
  return PreferredSize(
                        preferredSize: Size.fromHeight(75),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: centered?Alignment.bottomCenter:Alignment.bottomLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Visibility(
                                  visible: backEnabled,
                                  child: IconButton(icon: Icon(IconPack.carret_backward,color: darkmode?MyColors.theWhitest:MyColors.black161616,),onPressed: (){Navigator.pop(context);},),
                                ),
                                getTitle(title, darkmode?MyColors.theWhitest:MyColors.black161616)
                              ],
                            ),
                          ),
                        ),
                      );
}

getTextField(String hint,bool isDarkMode, TextEditingController textEditingController,TextInputType textInputType,double width,{bool autofocus}){
  if(autofocus==null)autofocus=false;
   return Container(
                      width: width,
                      child: TextField(
                        autofocus: autofocus,
                        controller: textEditingController,
                        keyboardType: textInputType,
                        style: getTextStyle(title: false,textColor: isDarkMode?MyColors.theWhitest:MyColors.black161616),
                        decoration: InputDecoration.collapsed(
                          
                          hintText: hint,
                          hintStyle: getTextStyle(title: false,textColor: MyColors.colorGray)
                        ),
                      ),
                    );
}


showFeedbackPopup(BuildContext buildContext,bool isDarkTheme){

  FirebaseDatabase firebaseDatabase =  FirebaseDatabase.instance;
  TextEditingController textEditingController = TextEditingController();

  showDistivityDialog(buildContext,isDarkTheme, [
    getButton2("Cancel", (){
      Navigator.pop(buildContext);
    },isDarkTheme),
    getButton1("Send Feedback", (){
      firebaseDatabase.reference().child("f").child(textEditingController.text).set(1);
      Navigator.pop(buildContext);
    }),
  ], "Send FeedBack", getTextField("Feedback goes here",isDarkTheme, textEditingController, TextInputType.text, 150));

}

showYesNoPopup(BuildContext buildContext,bool theme,  String title, String question , Function onYesPressed,
   {String yesButtonText, String noButtonText}){

  showDistivityDialog(buildContext,theme , [
    getButton2(noButtonText ?? "Cancel", (){
      Navigator.pop(buildContext);
    },theme),
    getButton1(yesButtonText ?? "Confirm", (){
      Navigator.pop(buildContext);
      onYesPressed();
    }),
  ], title, getText(question, MyColors.black161616));
}

PopupMenuItem getPopupMenuButton(int value,IconData iconPath , String name){

  return PopupMenuItem(
                                      value: value,
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Icon(iconPath),
                                          ),
                                          Text(name),
                                        ],
                                      ),
                                      
                                    );

}

showDistivityDialog(BuildContext context,bool isDarkTheme,List<Widget> actions ,String title,Widget content){

  showDialog(context: context,builder: (ctx){
    return AlertDialog(
      backgroundColor: isDarkTheme?MyColors.black161616:MyColors.theWhitest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      actions: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: actions
          ),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(title,textAlign: TextAlign.center,style: getTextStyle(title: true,textColor:isDarkTheme?MyColors.theWhitest:MyColors.black161616),),
          ),
          content
        ],
      ),
    );
  });
}

Widget getButton1(String text, Function onPressed){
  return FlatButton(
    color: MyColors.colorSecondary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    child:  Padding(
      padding: EdgeInsets.symmetric(horizontal: 7,vertical: 5),
      child: Text(
        text, style: getTextStyle(title: false , textColor: MyColors.black161616),
      ),
    ),
    onPressed: onPressed,
  );
}

Widget getButton2(String text, Function onPressed,bool isDarkTheme,{EdgeInsets padding}){
  return FlatButton(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    child:  Padding(
      padding: padding??EdgeInsets.all(0),
      child: Text(
        text, style: getTextStyle(title: false , textColor: isDarkTheme?MyColors.colorSecondary:MyColors.colorPrimaryLight),
      ),
    ),
    onPressed: onPressed,
  );
}

Widget getTitle(String text, Color color){
  return Text(text,style: getTextStyle(title: true,textColor: color),);
}

Widget getText(String text, Color color){
  return Text(text,style: getTextStyle(title: false,textColor: color),);
}

Widget getTabLayout(int position,bool theme, List<String> entries, Function(int position) onPressedPlusSetState){
  return Row(
    children: List<FlatButton>.generate(entries.length, (pos){
      return pos==position? getButton1(entries[pos], (){
      }):
      getButton2(entries[pos], (){
        onPressedPlusSetState(pos);
      },theme);
    }),
  );
}

Widget getRadioGroup(int checkedPos ,List<String> entries,Function(int position) onChangedPlusSetState){
  int crossAxisCount = 0;

  if (entries.length % 3 == 0){
    crossAxisCount = 3;
  }else{
    crossAxisCount = 2;
  }

  return GridView.builder(
    itemCount: entries.length,
    gridDelegate:
      new SliverGridDelegateWithFixedCrossAxisCount(
                                   crossAxisCount: crossAxisCount),
    itemBuilder: (BuildContext context, int index) {
      return getRadioButton(entries[index], index== checkedPos, (){
        onChangedPlusSetState(index);
      });
    });

}

Widget getSwitch(bool isChecked,bool isDarkMode, Function(bool isChecked) onCheckedChangedPlusSetState, String text){
  return Row(
    children: <Widget>[
      Switch(
        onChanged: onCheckedChangedPlusSetState,
        value: isChecked,
      ),
      getText(text, isDarkMode?MyColors.theWhitest:MyColors.black161616)
    ],
  );
}

Widget getCheckBox(bool isChecked,bool isDarkMode, Function(bool isChecked) onCheckedChangedPlusSetState, String text){
  return Row(
    children: <Widget>[
      Checkbox(
        onChanged: onCheckedChangedPlusSetState,
        value: isChecked,
      ),
      getText(text, isDarkMode?MyColors.theWhitest:MyColors.black161616)
    ],
  );
}

showHowItWorksPopup(BuildContext context,bool theme){
  showDistivityDialog(context,theme, [
    getButton2("I got it", (){Navigator.pop(context);},theme, padding : EdgeInsets.symmetric(vertical: 5,horizontal: 8))
    
    ], "How it works", Column(
      mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: getText("This app stands for Check Tasks In A Timer.", MyColors.black161616),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: getText("Once you start the timer, you can only see 1 task at a time for distractionless productivity. You can either skip it or complete it", MyColors.black161616),
      ),
    ],
  ));
}

Widget getRadioButton(String text, bool checked, Function onPress){
  return FlatButton(
    shape: RoundedRectangleBorder(
      side: checked? BorderSide(
        color: MyColors.colorPrimary,
        width: 2,
        style: BorderStyle.solid
      ): null,
      borderRadius: BorderRadius.circular(10)
    ),
    color: checked? MyColors.colorSecondary:Colors.transparent,
    onPressed: onPress,
    child: getText(text, MyColors.black161616),
  );
}

showDistivityModalBottomSheet(BuildContext context, Widget content, bool isDarkMode){
  showModalBottomSheet(shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))),
                                    backgroundColor: isDarkMode?MyColors.black161616:MyColors.theWhitest,
                                    isScrollControlled: true,context: context,builder: (ctx){
                                      return SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                          child: content,
                                        ),
                                      );
                                  });
}


Widget getFlareCheckbox(bool enabled,bool snapToEnd,{Function(bool) onCallbackCompleted,Function onTap}){
    return Container(
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: onTap,
        child: FlareActor(AssetsPath.checkboxAnimation,snapToEnd: snapToEnd,
          animation: enabled?'onCheck':'onUncheck',
          callback: (name){
            if(onCallbackCompleted!=null)onCallbackCompleted(name=='onCheck');
          },
        ),
      ),
    );
  }



class MyColors{
  static Color black161616 = Color(0xff161616);
  static Color black202020 = Color(0xff202020);
  static Color colorWhite = Color(0xffF7F7F7);
  static Color theWhitest = Color(0xffffffff);
  static Color colorGray = Color(0xff999999);
  static Color colorPrimary = Color(0xff142d4c);
  static Color colorPrimaryLight = Color(0xff2b517a);
  static Color colorSecondary = Color(0xffffe161);
  static Color theBlackest = Color(0xff000000);
  
}

class AssetsPath{
  static var checkboxAnimation = "assets/animations/checkbox.flr";
  static var emptyIllustrationDarkSvg = "assets/empty.svg";
  static var welcomeActivityIllustration = "assets/welcome.svg";
  static var googleIcon= "assets/pictures/google_icon.png";
  static var add = "assets/icons/add.svg/add.svg";
  static var carretBackward = "assets/icons/carret_backward.svg";
  static var carretFoward= "assets/icons/carret_foward.svg";
  static var close= "assets/icons/close.svg";
  static var dotsVertical= "assets/icons/dots_vertical.svg";
  static var edit= "assets/icons/edot.svg";
  static var info= "assets/icons/info.svg";
  static var play= "assets/icons/play.svg";
  static var settings= "assets/icons/settings.svg";
  static var timer= "assets/icons/timer.svg";
  static var todo= "assets/icons/todo.svg";
  static var trash= "assets/icons/trash.svg";
  static var icon= "assets/pictures/icon.png";
}

launchPage(BuildContext context , Widget page){
  Navigator.push(context, MaterialPageRoute(
    builder: (context){
      return page;
   }
        ));
}