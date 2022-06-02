import 'dart:io';

import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:distivity_ctiat/database/my_prefs.dart';
import 'package:distivity_ctiat/todo.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'icon_pack_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;





 
void main() {runApp(new MyApp());}

class MyApp extends StatefulWidget{

  
  static restartApp(BuildContext context) {
    final MyAppState state =
        context.ancestorStateOfType(const TypeMatcher<MyAppState>());
    state.restartApp();
  }

  @override
  MyAppState createState() {
    return MyAppState();
  }

}

class MyAppState extends State<MyApp>{

  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  static bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context,snapshot){

        isDarkTheme=snapshot.hasData?MyPrefs(snapshot.data).getBoolSetting(MyPrefs.settingDarkMode):false;
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            key: key,
            themeMode:snapshot.hasData?MyPrefs(snapshot.data).getBoolSetting(MyPrefs.settingDarkMode)?ThemeMode.dark:ThemeMode.light:ThemeMode.dark,
            darkTheme: ThemeData(
              primaryColor: MyColors.colorPrimary,
              backgroundColor: MyColors.black202020,
              accentColor: MyColors.colorSecondary,
              bottomAppBarColor: MyColors.black161616,
              scaffoldBackgroundColor: MyColors.black202020
            ),

            theme: ThemeData(
              primaryColor: MyColors.colorPrimary,
              backgroundColor: MyColors.black202020,
              bottomAppBarColor: MyColors.theWhitest,
              accentColor: MyColors.colorSecondary,
        ),
          title: "Distivity C.T.I.A.T.",
          home: snapshot.hasData?MyPrefs(snapshot.data).isFirstOpened()?WelcomePage():HomePage():CircularProgressIndicator(),
        );
        
      },
    );

  }

}

class HomePage extends StatefulWidget{@override HomePageState createState()=>HomePageState();}
class WelcomePage extends StatefulWidget{@override WelcomePageState createState()=>WelcomePageState();}
class SettingsPage extends StatefulWidget{@override _SettingsPageState createState()=>_SettingsPageState();}



class HomePageState extends State<HomePage>{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  MyPrefs prefs ;
  TodoDatabase todoDatabase;
  FirebaseUser firebaseUser;

  List<Todo> todos = List() ;


  List<int> itemToDelete = List();


  bool areUncheckedTodos= true;

  

  bool snapToEnd = true;
  

  //Timer screen
  TextEditingController todoGoalTextEditingController = TextEditingController();

  Duration timerDuration = Duration();
  bool isTimerStart = false;
  int todoIndex = 0;
  int checkedTodoCounter = 0;
  int goalOfTodos = 0 ;




  Future<bool> initApp()async{
    
    HttpClient().get("127.0.0.1", 8000, "/todos/1").then((v){
      v.close().then((onValue){
        print(onValue.transform(Utf8Decoder()));
      });
    });

    //print(Todo.fromMap(Map.from(json.decode(response.body))));
    

    prefs = MyPrefs(await SharedPreferences.getInstance());
    
    if(todoDatabase==null){
      int deviceId = prefs.getDeviceId();
      todoDatabase = await TodoDatabase.initAndGetDatabase(deviceId, prefs.getTodoId(),await _auth.currentUser());
    }

    if(todos.length ==0){
      todos = await todoDatabase.querryTodos();
      if(todos.length==0){
        areUncheckedTodos=false;
      }
    }
    

    if(firebaseUser==null){
      firebaseUser = await _auth.currentUser();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:initApp() ,
      builder: (context,snapshot){
        if(snapshot.hasData){
          print(todos.length);
          return Scaffold(
                    body : Padding(
                      padding: const EdgeInsets.only(top: 20,left: 5,right: 5),
                      child: isTimerStart? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CountdownFormatted(
                              duration: timerDuration,
                              builder: (ctx,str){
                                return Text(str,style: TextStyle(fontSize: 75,color: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),);
                              },
                              onFinish: (){
                                setState(() {
                                 isTimerStart=false;
                                 todoIndex=0;
                                 checkedTodoCounter=0;
                                 goalOfTodos=0;
                                });
                                showDistivityDialog(context,MyAppState.isDarkTheme, [
                                  getButton1("Start another one", (){
                                    Navigator.pop(context);
                                    setState(() {
                                      isTimerStart=true;
                                      timerDuration=Duration(minutes: prefs.getTimerValue());
                                    });
                                  }),
                                  getButton2("Finish", (){
                                    Navigator.pop(context);
                                  },MyAppState.isDarkTheme),
                                ], "You finished the timer", Column(
                                  children: <Widget>[
                                    getText("You finished $checkedTodoCounter out of $goalOfTodos", MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),

                                  ],
                                ));
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Card(
                                color: MyAppState.isDarkTheme?MyColors.black161616:MyColors.colorWhite,
                                elevation: 15,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child:Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 8),
                                  child: areUncheckedTodos? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: getText(todos[todoIndex].name, MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Visibility(visible: goalOfTodos!=0,child: getText("$checkedTodoCounter/$goalOfTodos",MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616)),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              getButton2("Skip", (){incrementTodoCounter();},MyAppState.isDarkTheme),
                                              getButton2("Complete", (){
                                                if(prefs.getBoolSetting(MyPrefs.settingDeleteTodoOnCheck)){
                                                  todoDatabase.delete(todos[todoIndex].id);
                                                  todos.removeAt(todoIndex);
                                                }else{
                                                  todos[todoIndex].checked=true;
                                                  todoDatabase.update(todos[todoIndex]);
                                                }
                                                checkedTodoCounter++;
                                                if(checkedTodoCounter==goalOfTodos){
                                                  Scaffold.of(context).showSnackBar(SnackBar(
                                                    content: getText("You've reached your goal. Congrats!!", MyColors.black161616),
                                                  ));
                                                }
                                                incrementTodoCounter();
                                                },MyAppState.isDarkTheme)
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ):Center(
                                    child: getText("No more todos. You are killing it!", MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ):todos.length!=0? ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (ctx,index){
                          Todo currentItem = todos[index];

                          return ControlledAnimation(
                            playback: itemToDelete.contains(currentItem.id) ? Playback.PLAY_FORWARD : Playback.PAUSE,
                            startPosition: itemToDelete.contains(currentItem.id) ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 500),
                            tween: Tween(begin: 50.0, end: 0.0),
                            builder: (context, tweenValue) {
                              return Opacity(
                                opacity: tweenValue/50,
                                child: Container(
                                  height: tweenValue,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: getFlareCheckbox(currentItem.checked,
                                            snapToEnd,
                                            onCallbackCompleted:(checked){
                                              if(prefs.getBoolSetting(MyPrefs.settingDeleteTodoOnCheck)){

                                                  setState(() {
                                                    itemToDelete.add(currentItem.id);
                                                  });
                                                 todoDatabase.delete(todos[index].id);
                                                 todos.removeAt(index); 
                                                
                                              }else{
                                                todoDatabase.update(todos[index]); 
                                              }
                                            },
                                            onTap: (){
                                              setState(() {
                                                currentItem.checked=!currentItem.checked;
                                                todos[index]=currentItem;
                                                snapToEnd=false;
                                              });
                                            } ),
                                          ),
                                          Container(width: 250,child: Text("${currentItem.name} with id : ${currentItem.id}",style: getTextStyle(title: false,textColor:MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,textDecoration:currentItem.checked? TextDecoration.lineThrough:null),))
                                        ],
                                      ),
                                      PopupMenuButton(
                                        onSelected: (value) {
                                          switch(value){
                                            case 0:
                                            showTodoBottomSheet(todo: currentItem,index: index);
                                            break;
                                            case 2:
                                              setState(() {
                                                int id = prefs.getTodoId();
                                                todos.insert(index+1,currentItem.getCopy(id));
                                                todoDatabase.insert(currentItem.getCopy(id));
                                              });
                                            break;
                                            case 1:
                                              setState(() {
                                               itemToDelete.add(currentItem.id); 
                                              });
                                              todoDatabase.delete(todos[index].id);
                                              todos.removeAt(index); 
                                            break;
                                          }
                                        },
                                        itemBuilder: (BuildContext context) =>[
                                          getPopupMenuButton(0, IconPack.edit, "Edit todo"),
                                          getPopupMenuButton(1, IconPack.trash, "Delete todo"),
                                          getPopupMenuButton(2, IconPack.todo, "Duplicate Todo")
                                        ],
                                        icon: Icon(IconPack.dots_vertical,color: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,),

                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ):Center(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(width: 250,height: 250,child: SvgPicture.asset(AssetsPath.emptyIllustrationDarkSvg)),
                          getText("No more todos. You are killing it", MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,)
                        ],
                      ),
                      )
                    ),
                    appBar: getAppBar(isTimerStart?"Work!!":"Todos",MyAppState.isDarkTheme,centered: isTimerStart),
                      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                      floatingActionButton: FloatingActionButton.extended(
                        label: getText(isTimerStart?"Cancel timer":"Start timer", MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),
                        icon: Icon(isTimerStart?IconPack.close:IconPack.play,color: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,),
                        backgroundColor: MyAppState.isDarkTheme?MyColors.colorPrimary:MyColors.colorSecondary,
                        onPressed: (){
                          if(isTimerStart){
                              setState(() {
                                isTimerStart=false;
                                goalOfTodos = 0;
                              });
                            }else{
                              showGoalPickerBottomSheet();
                                
                            }
                        },
                      ),
                      bottomNavigationBar: BottomAppBar(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: IconButton(
                                icon: Icon(IconPack.add,color: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,),
                                onPressed: (){
                                  showTodoBottomSheet();
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: PopupMenuButton(
                                  
                                  icon: Icon(IconPack.dots_vertical,color: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,),
                                  onSelected: (val){
                                    switch(val){
                                      case 0: launchPage(context, SettingsPage());break;
                                      case 1: showHowItWorksPopup(context,MyAppState.isDarkTheme); break;
                                      case 2: if(firebaseUser ==null) launchPage(context, WelcomePage()); else{
                                        _auth.signOut(); launchPage(context, WelcomePage());
                                      }break;
                                      case 3: prefs.setBoolSetting(MyPrefs.settingDarkMode,!MyAppState.isDarkTheme);
                                      MyApp.restartApp(context); break;
                                      case 4:LaunchReview.launch();break;
                                      case 5: showFeedbackPopup(context,MyAppState.isDarkTheme); break;
                                      case 6: showYesNoPopup(context,MyAppState.isDarkTheme,
                                        "Delete checked todos?",
                                        "P.S. : This action is irreversible", (){
                                          setState(() { 
                                            todos.forEach((f){
                                              if(f.checked){
                                                todos.remove(f);
                                                todoDatabase.delete(f.id);
                                              }
                                            });
                                          });
                                        });break;
                                    }
                                  },
                                  itemBuilder: (context)=>[
                                    getPopupMenuButton(1, IconPack.todo, "How it works?"),
                                    getPopupMenuButton(3, IconPack.todo, "Change Theme"),
                                    getPopupMenuButton(4, IconPack.todo, "Rate ( ͡° ͜ʖ ͡°)"),
                                    getPopupMenuButton(5, IconPack.todo, "Send Feedback"),
                                    getPopupMenuButton(6, IconPack.trash, "Delete Checked Todos"),
                                    getPopupMenuButton(0, IconPack.settings, "Settings"),
                                    getPopupMenuButton(2, IconPack.todo, firebaseUser==null?"Log in":"Log out"),
                                  ],
                                ),
                            )
                          ],
                        ),
                      ),
                    );
                                        
              }else{
                return Scaffold(
                  floatingActionButton: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: MyColors.colorGray,
                    ),
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                  bottomNavigationBar: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MyColors.colorGray
                    ),
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 40, top: 70),
                        child: getSkeletonView(60, 40),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 5),
                        child: getSkeletonView(75, 50),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 5),
                        child: getSkeletonView(75, 50),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 5),
                        child: getSkeletonView(75, 50),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 5),
                        child: getSkeletonView(75, 50),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 5),
                        child: getSkeletonView(75, 50),
                      ),
                    ],
                  ),
                );
              }
              
            },
            
            );
        }
      
        void incrementTodoCounter() {

          if(todos.length==0){
            areUncheckedTodos=false;
            return;
          }

          todos.forEach((item){
            if(!item.checked){areUncheckedTodos=true;}
          });

          setState(() {
            while(todos[todoIndex].checked==true && areUncheckedTodos){
              todoIndex++;
              if(todoIndex >= todos.length){
                todoIndex=0;
                break;
              }
            }
          });
        }

      void showTodoBottomSheet({Todo todo,int index}) {
        TextEditingController todoTextEditingController = TextEditingController();
        if(todo!=null){
          todoTextEditingController.text=todo.name;
        }
        showDistivityModalBottomSheet(context, Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: getTextField("Fight bears, Go to the moon, or do homework",MyAppState.isDarkTheme,
                     todoTextEditingController, TextInputType.text, 250,autofocus: true)
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: IconButton(icon: Icon(IconPack.carret_foward,color: MyAppState.isDarkTheme?MyColors.colorSecondary:MyColors.colorPrimary,),onPressed: (){ 
                      setState(() {
                        if(todo ==null){
                          todo = Todo(prefs.getTodoId(),
                            todoTextEditingController.text, false,0);
                          todos.add(todo); 
                          todoDatabase.insert(todo);
                        }else{
                            todo.name=todoTextEditingController.text;
                            todos[index] = todo;
                            todoDatabase.update(todo);
                            Navigator.pop(context);
                        }
                        todoTextEditingController.text="";
                        todo=null;
                      });
                    },),
                  )
                ],
              ), MyAppState.isDarkTheme);
      }

      showGoalPickerBottomSheet(){
        showDistivityModalBottomSheet(context, Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: getTextField("Enter goal of tasks to complete", MyAppState.isDarkTheme,todoGoalTextEditingController, TextInputType.number, 250,autofocus: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  getButton2("Start with no goal", (){
                    Navigator.pop(context);
                      setState(() {
                        timerDuration=Duration(minutes: prefs.getTimerValue());
                        isTimerStart=true;
                        goalOfTodos=0;
                        todoGoalTextEditingController.text="";
                        checkedTodoCounter=0;
                        todoIndex=0;
                        if(todos[todoIndex].checked){
                          incrementTodoCounter();
                        } 
                      });
                  },MyAppState.isDarkTheme),
                  getButton2("Start", (){
                    Navigator.pop(context);
                      setState(() {
                        timerDuration=Duration(minutes: prefs.getTimerValue());
                        isTimerStart=true;
                        goalOfTodos=int.parse(todoGoalTextEditingController.text);
                        todoGoalTextEditingController.text="";
                        checkedTodoCounter=0;
                        todoIndex=0;
                        if(todos[todoIndex].checked){
                          incrementTodoCounter();
                        } 
                      });
                  },MyAppState.isDarkTheme)
                ],
              ),
            )
          ],
        ), MyAppState.isDarkTheme);
      }

}
class WelcomePageState extends State<WelcomePage>{

  final FirebaseAuth _auth = FirebaseAuth.instance;


  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);

    DatabaseReference databaseReference =
     FirebaseDatabase.instance.reference().child("u").child(( await _auth.currentUser()).uid);

    DataSnapshot deviceIdCountDataSnapshot = await databaseReference.child("d").once();

    int deviceId ;

    if(deviceIdCountDataSnapshot.value==null){
      deviceId=0;
    }else{
      deviceId = deviceIdCountDataSnapshot.value+1;
    }

    databaseReference.child("d").set(deviceId);
    MyPrefs myPrefs = MyPrefs(await SharedPreferences.getInstance());
    myPrefs.setDeviceId(deviceId);

    return user;
  }



  @override
  Widget build(BuildContext context) {
    return  WillPopScope(//forbidden swipe in iOS(my ThemeData(platform: TargetPlatform.iOS,)
                  onWillPop: ()async {
                    if (Navigator.of(context).userGestureInProgress)
                      return false;
                    else
                      return true;
                  },
                  child: Container(
                    child: Scaffold(
                      appBar: PreferredSize(
                      preferredSize: Size.fromHeight(100),
                      child:  Align(
                        alignment: Alignment.bottomCenter,
                        child: Text("Welcome to Distivity C.T.I.A.T",
                         style: getTextStyle(textColor: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,title: true),
                         textAlign: TextAlign.center,),
                      ),
                      ),
                      body: Column(
                        //login buttons 4 later

                        children: <Widget>[

                          Padding(
                            padding: const EdgeInsets.only(top: 40,bottom: 5),
                            child: InkWell(
                              onTap: ()async{
                                  FirebaseUser user = await _handleSignIn();
                                  if(user != null){
                                    launchPage(context, MyApp());
                                  }else{
                                    Scaffold.of(context).showSnackBar(SnackBar(content: Text(
                                      "Error occured, try again",
                                      style: getTextStyle(title: false,textColor:MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),
                                    ),));
                                  }
                                },
                                child: Container(
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Image.asset(AssetsPath.googleIcon,width: 30,height: 30,),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Sign in with google"
                                              ,style: getTextStyle(title: false, textColor: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5,bottom: 10),
                            child: FlatButton(
                              onPressed: (){
                                launchPage(context, MyApp());
                              },
                              child: Text("Sign in later!",style: getTextStyle(title:false,textColor: MyColors.colorGray),),
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: SvgPicture.asset(AssetsPath.welcomeActivityIllustration),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: FlatButton(
                                  child: Text(
                                    "How it works",
                                    style: getTextStyle(title: false,textColor: MyColors.colorGray),
                                ),onPressed: (){
                                  showHowItWorksPopup(context,MyAppState.isDarkTheme);
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                );
  }

}

class _SettingsPageState extends State<SettingsPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Scaffold(
         appBar: getAppBar("Settings",MyAppState.isDarkTheme,centered: false,backEnabled: true,context: context),
         body : FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (ctx, snapshot){
              if(snapshot.hasData){
                MyPrefs myPrefs = MyPrefs(snapshot.data);

                TextEditingController timerMinutesController = TextEditingController(text: myPrefs.getTimerValue().toString());

                timerMinutesController.addListener((){
                  print(timerMinutesController.text);
                  myPrefs.timerChanged(int.parse(timerMinutesController.text));
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Todos",style: getTextStyle(title: false, textColor: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,textDecoration: TextDecoration.underline),),
                              ),
                              getSwitch(myPrefs.getBoolSetting(MyPrefs.settingDeleteTodoOnCheck),MyAppState.isDarkTheme,(val){
                                setState(() {
                                  myPrefs.setBoolSetting(MyPrefs.settingDeleteTodoOnCheck, val);
                                });
                              }, "Delete Todo on check"),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Timer",style: getTextStyle(title: false, textColor: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,textDecoration: TextDecoration.underline),),
                              ),
                              getSwitch(myPrefs.getBoolSetting(MyPrefs.settingDisableSkip),MyAppState.isDarkTheme,(val){
                                setState(() {
                                  myPrefs.setBoolSetting(MyPrefs.settingDisableSkip, val);
                                });
                              }, "Disable skip todo in timer mode"),

                              getTextField("Timer minutes",MyAppState.isDarkTheme, timerMinutesController,TextInputType.number,170),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("General",style: getTextStyle(title: false, textColor: MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616,textDecoration: TextDecoration.underline),),
                              ),
                              getSwitch(myPrefs.getBoolSetting(MyPrefs.settingDarkMode),MyAppState.isDarkTheme,(val){
                                myPrefs.setBoolSetting(MyPrefs.settingDarkMode, val);
                                MyApp.restartApp(context);
                              }, "Dark Mode"),
                            ],
                          );
              }else{
                return Column(
                    children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 30,left: 10,bottom: 30),
                                child: getTitle("Settings", MyAppState.isDarkTheme?MyColors.theWhitest:MyColors.black161616),
                              ),
                              getSkeletonView(60, 30),
                              getSkeletonView(75, 30),
                              getSkeletonView(55, 30),
                              getSkeletonView(65, 30),
                              getSkeletonView(70, 30),
                            ],
                          );
              }
            },
         )

       ),
    );
  }
}

  
 

