import 'dart:math';

import 'package:flutter/material.dart';
import 'package:paginationflutter/controler.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final PaginationController controller = Get.put(PaginationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination In Flutter'),
      ),
      body: Obx(() {
        if (controller.initAPPSate == Status.LOADING) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (controller.initAPPSate == Status.COMPELETD) {
          if (!controller.hasNextPage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have fetched all of the content'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            });
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  controller: controller.scrollController,
                  itemCount: controller.postList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var data = controller.postList[index];

                    return Card(
                      color: getRandomColor(),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(data.title.toString()),
                        subtitle: Text(data.body.toString()),
                      ),
                    );
                  },
                ),
              ),
              if (controller.isLoadMoreRunning == true)
                const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        } else {
          return const Center(
            child: Text('Oops!! Something went wrong! '),
          );
        }
      }),
    );
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      150,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
