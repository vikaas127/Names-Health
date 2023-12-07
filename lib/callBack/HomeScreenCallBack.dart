abstract class HomeScreenCallBackListener {
  callBack(dynamic value);
}

class HomeScreenCallBack {
  static HomeScreenCallBackListener homeScreenCallBackListener;

  static HomeScreenCallBackListener getHomeScreenCallBack() {
    return homeScreenCallBackListener;
  }

  static void setHomeScreenCallBack(
      HomeScreenCallBackListener homeScreenCallBackListener) {
    HomeScreenCallBack.homeScreenCallBackListener = homeScreenCallBackListener;
  }
}
