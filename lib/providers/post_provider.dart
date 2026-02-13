import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flavour/models/post.dart';

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  List<Post> get sortedPosts {
    final sorted  = List<Post>.from(_posts);
    sorted.sort((a,b)=> b.cookedAt.compareTo(a.cookedAt));
    return sorted;
  }
  PostProvider(){
    _loadPosts();
  }
  Future<void> _loadPosts() async{
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getStringList('user_posts') ?? [];

    _posts = postsJson.map((json)=> Post.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }
  Future<void> _savePosts() async{
    final prefs = await SharedPreferences.getInstance();
    final postsJson = _posts.map((post)=> jsonEncode(post.toJson())).toList();
    await prefs.setStringList('user_posts', postsJson);
  }
  Future<void> addPost({
    required String recipeName,
    required String recipeId,
    required String photoPath,
}) async {
    final post = Post(id: DateTime.now().millisecondsSinceEpoch.toString(), recipeName: recipeName, recipeId: recipeId, photoPath: photoPath, cookedAt: DateTime.now());
    _posts.insert(0, post);
    await _savePosts();
    notifyListeners();
  }
  void toggleLike(String postId) {
    final index = _posts.indexWhere((p)=> p.id == postId);
    if(index !=-1) {
      final post = _posts[index];
      if(post.isLikedByMe){
        post.likes--;
        post.isLikedByMe = false;
      } else{
        post.likes++;
        post.isLikedByMe = true;
      }
      _savePosts();
      notifyListeners();
    }
  }
  Future<void> deletePost(String postId) async{
    _posts.removeWhere((p)=>p.id == postId);
    await _savePosts();
    notifyListeners();
  }
}