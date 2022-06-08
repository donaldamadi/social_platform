import 'package:get/get.dart';

class CounterController extends GetxController {
  var notifCount = 0.obs;
  var notificationData = {}.obs;

  void clearNotif() {
    notificationData.value = {}.obs;
    update();
    // notifyListeners();
  }

  void setNotifCount(var value) {
    this.notifCount = value;
    //  print(this.notifCount);
    update();
  }

  setNotificationData(Map<String, dynamic> value) {
    this.notificationData.value = value;
    //  print(this.notificationData);
    update();
  }

  void increment() {
    //  print(this.notifCount);
    //  print("increasing");
    this.notifCount = this.notifCount + 1;
    //  print(this.notifCount);
    update(); // Tell your widgets that you have changed the counter
  }

  void decrease() {
    //  print(this.notifCount);
    //  print("decreasing");
    this.notifCount = this.notifCount - 1;
    //  print(this.notifCount);
    update(); // Tell your widgets that you have changed the counter
  }

  void setNotificationCountToZero() {
    this.notifCount = 0.obs;
    update();
  }

  void reset() {
    this.notifCount = 0.obs;
    this.notificationData = {}.obs;
    update();
  }
}
