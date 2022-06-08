import 'package:get/state_manager.dart';

class PostController extends GetxController {
  final RxList upvotes = [].obs;
  final RxList downvotes = [].obs;
  final RxList reposters = [].obs;
  final RxList comments = [].obs;
  final RxInt lenComments = 0.obs;
  final RxBool showMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    
  }
}
