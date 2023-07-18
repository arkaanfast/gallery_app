import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_workshop/pages/gallery_screen/gallery_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ImageItem {
  final String id;
  final String name;
  final String imageUrl;
  bool isLiked;

  ImageItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isLiked,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  final List<ImageItem> _imageItemList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    getImagesList();
    super.initState();
  }

  Future<void> getImagesList() async {
    List<String> userGalleryIds = [];
    Response responseBody = await http.get(
      Uri.parse(
          'https://api.unsplash.com/photos/?client_id=6mvXv-vEEVRa4msi3aYggI66pbWXc138wIO8yIG12_g'),
    );
    final userData = await _firestore
        .doc('user/${_auth.currentUser!.uid}')
        .collection('userGallery')
        .get();
    for (var data in userData.docs) {
      userGalleryIds.add(data.id);
    }
    List<dynamic> response = jsonDecode(responseBody.body);
    for (int i = 0; i < response.length; i++) {
      int index = userGalleryIds.indexWhere(
        (element) => element == response[i]['id'],
      );
      ImageItem imageItem = ImageItem(
        id: response[i]['id'],
        imageUrl: response[i]['urls']['raw'],
        name: response[i]['user']['name'],
        isLiked: index == -1 ? false : true,
      );
      _imageItemList.add(imageItem);
    }
    setState(() {
      _isLoading = false;
    });
  }

  // List<TempListItem> tempList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture Gallery'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GalleryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.photo,
            ),
          )
        ],
        backgroundColor: Colors.grey,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: ListView.builder(
                  // cacheExtent: 200,
                  addAutomaticKeepAlives: true,
                  itemCount: _imageItemList.length,
                  padding: const EdgeInsets.all(26.0),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(
                        top: 20.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            child: CachedNetworkImage(
                              memCacheHeight: 800,
                              memCacheWidth: 800,
                              fit: BoxFit.cover,
                              imageUrl: _imageItemList[index].imageUrl,
                              placeholder: (context, url) => const SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 150.0,
                                  padding: const EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: Text(
                                    _imageItemList[index].name,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      await _firestore
                                          .doc(
                                              'user/${_auth.currentUser!.uid}/userGallery/${_imageItemList[index].id}')
                                          .set(
                                        {
                                          'imageUrl':
                                              _imageItemList[index].imageUrl,
                                          'name': _imageItemList[index].name
                                        },
                                      );
                                      setState(() {
                                        _imageItemList[index].isLiked =
                                            !_imageItemList[index].isLiked;
                                      });
                                    },
                                    icon: _imageItemList[index].isLiked
                                        ? const Icon(
                                            size: 30,
                                            Icons.thumb_up_sharp,
                                          )
                                        : const Icon(
                                            size: 30,
                                            Icons.thumb_up_alt_outlined,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
    );
  }
}
