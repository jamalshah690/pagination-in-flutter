import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginationflutter/model.dart';
import 'package:http/http.dart' as http;

enum Status { LOADING, COMPELETD, ERROR }

class PaginationController extends GetxController {
  final RxInt _page = 0.obs;
  RxInt _limit = 10.obs;
  final RxBool _hasNextPage = true.obs;
  // final RxBool _isFirstLoadRunning = false.obs;
  // final RxBool _isLoadMoreRunning = false.obs;
  final Rx<List<PostModel>> _posts = Rx<List<PostModel>>([]);
  Rx<Status> initAPPSate = Status.LOADING.obs;
  RxBool _isFirstLoadRunning = false.obs;
  RxBool _isLoadMoreRunning = false.obs;
  setAppSate(Status val) => initAPPSate.value = val;

  int get page => _page.value;
  int get countLimit => _limit.value;
  bool get hasNextPage => _hasNextPage.value;
  bool get isFirstLoadRunning => _isFirstLoadRunning.value;
  bool get isLoadMoreRunning => _isLoadMoreRunning.value;
  List<PostModel> get postList => _posts.value;

  ScrollController scrollController = ScrollController();
  final _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  @override
  void onInit() {
    super.onInit();
    _firstLoad();
    scrollController.addListener(_loadMore);
  }

  void _firstLoad() async {
    setAppSate(Status.LOADING);
    _isFirstLoadRunning.value = true;

    String url = "$_baseUrl?_page=$_page&_limit=$_limit";
    log(url);
    try {
      final res = await http.get(Uri.parse(url));
      var data = json.decode(res.body);
      for (var element in data) {
        _posts.value.add(PostModel.fromJson(element as Map<String, dynamic>));
      }
      setAppSate(Status.COMPELETD);
      _isFirstLoadRunning.value = false;
    } catch (err) {
      log('Oops!! _firstLoad Something went wrong! $err');
      setAppSate(Status.ERROR);
    }

    // setAppSate(Status.COMPELETD);
  }

  void _loadMore() async {
    if (_hasNextPage.value &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        scrollController.position.extentAfter < 300) {
      _isLoadMoreRunning.value = true;
      _page.value += 1;

      try {
        String url = "$_baseUrl?_page=$_page&_limit=$_limit";
        log(url);
        final res = await http.get(Uri.parse(url));

        var data = json.decode(res.body);
        List<PostModel> postsLoadMoreList = [];
        if (data.isNotEmpty) {
          for (var element in data) {
            postsLoadMoreList
                .add(PostModel.fromJson(element as Map<String, dynamic>));
          }
          _posts.value.addAll(postsLoadMoreList);
        } else {
          _hasNextPage.value = false;
        }
      } catch (err) {
        log('Oops!! Something went wrong! $err');
      }

      _isLoadMoreRunning.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_loadMore);
    super.onClose();
  }
}
