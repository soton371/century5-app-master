
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({Key? key}) : super(key: key);

  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {

  File? _image;
  final picker = ImagePicker();

  var controller = Get.put(AuthController());

  TextEditingController nameContr = TextEditingController();

  Future choiceImage()async{
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  Future upload(File imageFile)async{

    //var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    //var length = await imageFile.length();
    var uri = Uri.parse(MyApi.updateProfileData);

    //add by me
    Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',};
    final length = await _image!.length();

    // var request = http.MultipartRequest("POST",uri);
    // request.fields['profile_id'] = nameContr.text;
    //
    // var pic = await http.MultipartFile.fromPath("image", imageFile.path);
    // //var pic = http.MultipartFile("image",stream,length,filename: basename(imageFile.path));
    //
    // request.files.add(pic);
    //added by me
    final request = new http.MultipartRequest('POST', uri)..fields['profile_id']=controller.myId.toString()..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      print("image uploaded");
    }else{
      print("uploaded faild");
    }

    nameContr.text = "";


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[

            TextField(
              controller: nameContr,
              decoration: InputDecoration(
                  labelText: 'Name'
              ),
            ),


            IconButton(icon: Icon(Icons.camera),
              onPressed: (){
                choiceImage();
              },),
            Container(
              width: 300,
              height: 300,
              child: _image == null ? Text('No image selected') : Image.file(_image!),
            ),

            RaisedButton(child: Text('Upload Image'),
              onPressed: (){
                upload(_image!);
              },),

          ],
        ),
      ),
    );
  }
}

