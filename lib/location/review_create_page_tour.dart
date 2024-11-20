import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/color.dart';
import '../theme/text.dart';

class ReviewCreatePageTour extends StatefulWidget {
  final String courseId;

  const ReviewCreatePageTour({Key? key, required this.courseId})
      : super(key: key);

  @override
  State<ReviewCreatePageTour> createState() => _ReviewCreatePageTourState();
}

class _ReviewCreatePageTourState extends State<ReviewCreatePageTour> {
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
        .collection('locationMap')
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
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text(
                '리뷰가 성공적으로 등록되었어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: (18 / 393) * MediaQuery.of(context).size.width,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '소중한 후기 감사해요 !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: (12 / 393) * MediaQuery.of(context).size.width,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w200,
                  letterSpacing: -0.32,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const Divider(),
              TextButton(
                onPressed: () {
                  submitReview();
                  Navigator.pop(context);
                },
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Color(0xFF007BFF),
                    fontSize: (14 / 393) * MediaQuery.of(context).size.width,
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
            size: MediaQuery.of(context).size.width * 0.08,
          ),
        ),
      ),
    );
  }

  Widget buildReviewField() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.066),
      child: Stack(
        children: [
          Container(
            width: screenWidth * 0.87,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.033,
              vertical: MediaQuery.of(context).size.height * 0.015,
            ),
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
                hintStyle: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                  fontFamily: 'S-Core Dream',
                  fontSize: (11 / 393) * screenWidth,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.01,
            right: screenWidth * 0.05,
            child: Text(
              '$currentLength/$maxLength',
              style: TextStyle(
                color: Colors.grey,
                fontSize: (8 / 393) * screenWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImagePickerButton() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
        left: screenWidth * 0.066,
        right: screenWidth * 0.066,
      ),
      child: SizedBox(
        width: screenWidth * 0.87,
        height: MediaQuery.of(context).size.height * 0.05,
        child: ElevatedButton(
          onPressed: pickImage,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.white,
            side: const BorderSide(width: 1, color: Color(0xFF4FA2FF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.camera,
                color: Color(0xFF4FA2FF),
                size: (24 / 393) * screenWidth,
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                '사진 첨부하기',
                style: medium13.copyWith(
                  color: const Color(0xFF4FA2FF),
                  fontSize: (13 / 393) * screenWidth,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
        left: screenWidth * 0.066,
        right: screenWidth * 0.066,
      ),
      child: SizedBox(
        width: screenWidth * 0.87,
        height: MediaQuery.of(context).size.height * 0.06,
        child: ElevatedButton(
          onPressed: () {
            reviewPopup();
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF4FA2FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            '리뷰 등록하기',
            style: medium13.copyWith(
              color: const Color(0xFFFFFFFF),
              fontSize: (15 / 393) * screenWidth,
              fontFamily: 'S-Core Dream',
              fontWeight: FontWeight.w600,
              letterSpacing: -0.32,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePreview() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return _image != null
        ? Center(
            child: Padding(
              padding: EdgeInsets.only(top: (100 / 852) * screenHeight),
              child: Image.file(
                _image!,
                width: screenWidth * 0.5,
                height: MediaQuery.of(context).size.height * 0.2,
                fit: BoxFit.cover,
              ),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '리뷰작성하기',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: (18 / 393) * screenWidth,
            fontFamily: 'S-Core Dream',
            fontWeight: FontWeight.w500,
            letterSpacing: -0.32,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        indent: MediaQuery.of(context).size.width * 0.064,
                        endIndent: MediaQuery.of(context).size.width * 0.064,
                        color: const Color.fromARGB(255, 25, 25, 25),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.066,
                        ),
                        child: Text(
                          '*별점을 남겨주세요',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: (15 / 393) * screenWidth,
                            fontFamily: 'S-Core Dream',
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ),
                      buildStarRating(),
                      Divider(
                        indent: MediaQuery.of(context).size.width * 0.064,
                        endIndent: MediaQuery.of(context).size.width * 0.064,
                        color: const Color(0xffadaaaa),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.019,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.066,
                        ),
                        child: Text(
                          '*솔직한 리뷰를 작성해주세요',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: (15 / 393) * screenWidth,
                            fontFamily: 'S-Core Dream',
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      buildReviewField(),
                      buildImagePickerButton(),
                      buildImagePreview(),
                      const Spacer(),
                      buildSubmitButton(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
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
