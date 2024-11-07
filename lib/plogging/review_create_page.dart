import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ssoup_new/theme/text.dart';
import '../theme/color.dart';

class ReviewCreatePage extends StatefulWidget {
  final String courseId;

  ReviewCreatePage({super.key, required this.courseId});

  @override
  State<ReviewCreatePage> createState() => _ReviewCreatePageState();
}

class _ReviewCreatePageState extends State<ReviewCreatePage> {
  final TextEditingController reviewController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _image;
  String nickname = "";
  int currentLength = 0;
  double rating = 0;
  final int maxLength = 1000;

  @override
  void initState() {
    super.initState();
    _fetchNickname();
    reviewController.addListener(() {
      setState(() {
        currentLength = reviewController.text.length;
      });
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchNickname() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot documentSnapshot =
            await _firestore.collection('user').doc(user.uid).get();
        setState(() {
          nickname = documentSnapshot['nickName'];
        });
      } catch (e) {
        print("Error fetching nickname: $e");
      }
    } else {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Future<void> submitReview() async {
      if (reviewController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please provide review text'),
        ));
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User not logged in'),
        ));
        return;
      }

      String? reviewImageUrl;
      if (_image != null) {
        final imagePath = 'visitor/${DateTime.now()}.png';
        final ref = FirebaseStorage.instance.ref().child(imagePath);
        await ref.putFile(_image!);
        reviewImageUrl = await ref.getDownloadURL();
      }

      await _firestore
          .collection('course')
          .doc(widget.courseId)
          .collection('visitor')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'username': nickname,
        'reviewImageUrl': reviewImageUrl,
        'review': reviewController.text,
        'score': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context, true);
    }

    void reviewPopup() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(15)),
            width: 343,
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * (28 / 852)),
                const Text(
                  '리뷰가 성공적으로 등록되었어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'S-Core Dream',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.32,
                  ),
                ),
                const Text(
                  '소중한 후기 감사해요 !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'S-Core Dream',
                    fontWeight: FontWeight.w200,
                    letterSpacing: -0.32,
                  ),
                ),
                SizedBox(height: screenHeight * (22 / 852)),
                const Divider(),
                TextButton(
                  onPressed: () {
                    submitReview();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xFF007BFF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }

    Widget buildStarRating() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) => IconButton(
            onPressed: () {
              setState(() {
                rating = index + 1;
              });
            },
            icon: Icon(
              Icons.star,
              color: index < rating ? AppColor.button : Colors.grey,
              size: 35,
            ),
          ),
        ),
      );
    }

    Widget buildReviewField(double screenWidth, double screenHeight) {
      return Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.066),
        child: Stack(
          children: [
            Container(
              width: screenWidth * 0.873,
              height: screenHeight * 0.226,
              padding: EdgeInsets.only(left: screenWidth * 0.033),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: TextFormField(
                controller: reviewController,
                cursorColor: const Color(0xff50A2FF),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '$nickname님의 리뷰는 다른 참여자분들에게 큰 도움이 될 수 있어요.',
                  hintStyle: const TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    fontFamily: 'S-Core Dream',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.196,
              left: screenWidth * 0.761,
              child: Text(
                '$currentLength/$maxLength',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 8,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildImagePickerButton(double screenWidth, double screenHeight) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.873,
            height: screenHeight * 0.043,
            child: ElevatedButton(
              onPressed: pickImage,
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF4FA2FF)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.camera,
                    color: Color(0xFF4FA2FF),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    '사진 첨부하기',
                    style: medium13.copyWith(
                      color: const Color(0xFF4FA2FF),
                      fontSize: 13,
                      fontFamily: 'S-Core Dream',
                      fontWeight: FontWeight.w600,
                      height: 0.12,
                      letterSpacing: -0.32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget buildSubmitButton(double screenWidth, double screenHeight) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.874,
            height: screenHeight * 0.059,
            child: ElevatedButton(
              onPressed: () {
                reviewPopup();
              },
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: const WidgetStatePropertyAll(
                  Color(0xFF4FA2FF),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF4FA2FF)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              child: Text(
                '리뷰 등록하기',
                style: medium13.copyWith(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 15,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w600,
                  height: 0.09,
                  letterSpacing: -0.32,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '리뷰작성하기',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'S-Core Dream',
            fontWeight: FontWeight.w200,
            height: 0.07,
            letterSpacing: -0.32,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        indent: screenWidth * 0.064,
                        endIndent: screenWidth * 0.064,
                        color: const Color.fromARGB(255, 25, 25, 25),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Container(
                        padding: EdgeInsets.only(left: screenWidth * 0.066),
                        height: screenHeight * 0.023,
                        child: const Text(
                          '*별점을 남겨주세요',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'S-Core Dream',
                            fontWeight: FontWeight.w200,
                            height: 0.09,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ),
                      buildStarRating(),
                      Divider(
                        indent: screenWidth * 0.064,
                        endIndent: screenWidth * 0.064,
                        color: const Color(0xffadaaaa),
                      ),
                      SizedBox(height: screenHeight * 0.019),
                      Container(
                        padding: EdgeInsets.only(left: screenWidth * 0.066),
                        height: screenHeight * 0.023,
                        child: const Text(
                          '*솔직한 리뷰를 작성해주세요',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'S-Core Dream',
                            fontWeight: FontWeight.w200,
                            height: 0.09,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ),
                      buildReviewField(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.016),
                      buildImagePickerButton(screenWidth, screenHeight),
                      if (_image != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Image.file(
                                _image!,
                                width: screenWidth * 0.221,
                                height: screenHeight * 0.101,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      const Spacer(),
                      if (_image != null)
                        buildSubmitButton(screenWidth, screenHeight),
                      const SizedBox(height: 45),
                    ],
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
