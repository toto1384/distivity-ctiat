import 'package:shared_preferences/shared_preferences.dart';


class MyPrefs{

  SharedPreferences sharedPreferences;


  MyPrefs(this.sharedPreferences);

    
   int getTimerValue() {
      int minutes = (sharedPreferences.getInt("counter") ?? 60 );
      return minutes;
      
    }

    int id ;

    int getTodoId(){
      if(id == null){
        id = sharedPreferences.getInt("todoId")??0;
      }
      id++;

      sharedPreferences.setInt("todoId", id+1);

      return id-1;

    }


    setTodoId(int value)async {
      print(value);
      await sharedPreferences.setInt("todoId", value);
    }

  timerChanged(int value) {
      
      sharedPreferences.setInt('counter', value);
    }

   bool isFirstOpened(){

      bool isFirstOpened = sharedPreferences.getBool("isFirstOpened")??true;

      sharedPreferences.setBool("isFirstOpened", false);

      return isFirstOpened;
    }

   int getDeviceId(){

      return sharedPreferences.getInt("deviceId");
    }

   setDeviceId(int id){
     sharedPreferences.setInt("deviceId", id);
    }

    bool getBoolSetting(Map<String,bool> setting){

      return sharedPreferences.getBool(setting.keys.elementAt(0) ?? setting.values.elementAt(0))?? false;
    }
    

    setBoolSetting(Map<String,bool> setting, bool value){

      sharedPreferences.setBool(setting.keys.elementAt(0), value);


    }

  static final Map<String,bool> settingDeleteTodoOnCheck = {"dtodooncheck":false};
   static final Map<String,bool> settingDarkMode = {"darkmode":true};
    static final Map<String,bool> settingDisableSkip = {"disableskip":false};


}