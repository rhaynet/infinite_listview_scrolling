import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infinite_scrolling/api.dart';
import 'package:infinite_scrolling/models/image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  late int totalPages;
  List<Images> imageList = [];


  final RefreshController refreshController = RefreshController(initialRefresh: true);

  Future<bool> fetchImages({bool isRefresh = false}) async {

    if(isRefresh){
      currentPage = 1;
    }else{
      //dont load any data if the number of images returned from the api request has been exceeded
      if(currentPage >= totalPages){
        refreshController.loadNoData();
        return false;
      }
    }
    final response = await http.get(Uri.parse(
        'https://api.unsplash.com/search/photos?per_page=10&page=$currentPage&query=office&client_id=$ACCESS_KEY'));

    if (response.statusCode == 200) {
      final jsonData = imageDataFromJson(response.body);

      //if laoding data for the first time
      if(isRefresh){
        imageList = jsonData.result;
      }
      //when adding data to the existing list
      else{
        imageList.addAll(jsonData.result);
      }

      currentPage++;
      totalPages = jsonData.totalPages;

      setState(() {});
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite-scrolling-test'),
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: ()async{
          final result = await fetchImages(isRefresh: true);
          if(result){
            refreshController.refreshCompleted();
          }else{
            refreshController.refreshFailed();
          }
        },
        onLoading: ()async{
          final result = await fetchImages();
          if(result){
            refreshController.loadComplete();
          }else{
            refreshController.loadFailed();
          }
        },
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: imageList.length,
          itemBuilder: (context, index) {
            return Container(
              child: Image.network(
                imageList[index].imageUrl,
              ),
            );
          },
        ),
      ),
    );
  }
}
