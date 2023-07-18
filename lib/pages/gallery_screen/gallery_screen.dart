import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_screen/home_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  final List<ImageItem> _userGalleryList = [];
  bool _isEmpty = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    getUserGalleryList();
    super.initState();
  }

  Future<void> getUserGalleryList() async {
    final userData = await _firestore
        .doc('user/${_auth.currentUser!.uid}')
        .collection('userGallery')
        .get();
    if (userData.docs.isNotEmpty) {
      for (var data in userData.docs) {
        ImageItem imageItem = ImageItem(
          id: data.id,
          name: data['name'],
          imageUrl: data['imageUrl'],
          isLiked: false,
        );
        _userGalleryList.add(imageItem);
      }
    } else {
      _isEmpty = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Gallery',
        ),
        backgroundColor: Colors.grey,
      ),
      body: Container(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _isEmpty
                ? const Center(
                    child: Text('Add stuff to the gallery'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20.0),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      // childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _userGalleryList.length,
                    itemBuilder: (BuildContext context, index) {
                      return Container(
                        width: 800,
                        height: 800,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        child: SizedBox(
                          child: CachedNetworkImage(
                            memCacheHeight: 800,
                            memCacheWidth: 800,
                            fit: BoxFit.cover,
                            imageUrl: _userGalleryList[index].imageUrl,
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
                      );
                    },
                  ),
      ),
    );
  }
}
