import 'dart:convert';

import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLight = true;

  final ImagePicker pickerObject = ImagePicker();

  File? imageUser;

  dynamic listApi;


  @override
  void initState() {
    getListFunction();
    super.initState();
  }

  Future<void> getListFunction() async{
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/usuario'),
      headers: {'Content-Type': 'application/json'}
    );


    if(response.statusCode == 200){
      final responseGet = jsonDecode(response.body);

      setState(() {
        listApi = responseGet;
      });

      print(listApi);
    }
  }

  Future<void> sendImageFunction() async {
    try {
      if (imageUser != null) {
        final request = http.MultipartRequest(
            'POST', Uri.parse('http://10.0.2.2:3000/upload'));

        request.files.add(http.MultipartFile.fromString('file', imageUser!.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context as BuildContext)
              .showSnackBar(SnackBar(content: Text('Upload de foto concluido!')));
        } else {
          ScaffoldMessenger.of(context as BuildContext)
              .showSnackBar(SnackBar(content: Text('Erro para upload de foto e ${response.statusCode}')));
        }
      } else {
        print('nenhuma foto');
      }
    } on Exception catch (e) {
      print( 'olha o erro ai $e');
    }
  }

  Future<void> pickerImageFunction() async {
    final imagePicked =
        await pickerObject.pickImage(source: ImageSource.camera);

    if (imagePicked != null) {

      final File imageSaved = await saveFileFunction(imagePicked.path);

      setState(() {
        imageUser = imageSaved;
      });
      setState(() {
        sendImageFunction();
      });
    } else {
      print('Erro ao capturar image');
    }
  }

  Future<File> saveFileFunction(String imageParameter) async{
    final directory = await getApplicationDocumentsDirectory();
    final nameImage = basename(imageParameter);
    final newPathImage = '${directory.path}/$nameImage';

    return File(imageParameter).copy(newPathImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isLight ? MyColors.cinzaClaro : MyColors.roxoEscuro,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      if (isLight == true) {
                        setState(() {
                          isLight = false;
                        });
                      } else {
                        setState(() {
                          isLight = true;
                        });
                      }
                    },
                    icon: isLight
                        ? Icon(Icons.sunny, size: 30)
                        : Icon(
                            Icons.dark_mode_rounded,
                            size: 30,
                            color: MyColors.cinzaClaro,
                          )),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  children: [
                    Text(
                      'Perfil do Estudantil',
                      style: isLight
                          ? TextStyle(
                              color: MyColors.roxoEscuro,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)
                          : TextStyle(
                              color: MyColors.cinzaClaro,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CircleAvatar(
                        backgroundColor:
                            isLight ? MyColors.roxoEscuro : MyColors.cinzaClaro,
                        radius: 90,
                        child: imageUser == null
                            ? Icon(Icons.people,
                                color: isLight
                                    ? MyColors.cinzaClaro
                                    : MyColors.roxoEscuro,
                                size: 90)
                            : ClipOval(
                                child: Image.file(imageUser!),
                              )),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        onPressed: () {
                          pickerImageFunction();
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: isLight
                              ? MyColors.roxoEscuro
                              : MyColors.cinzaClaro,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Descrição',
                style: TextStyle(
                    color: isLight ? MyColors.roxoEscuro : MyColors.cinzaClaro,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'nome',
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        Text(
                          listApi['nome'],
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CPF',
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        Text(
                          listApi['cpf'],
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CEP',
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        Text(
                          listApi['cep'],
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telefone',
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        Text(
                          listApi['telefone'],
                          style: TextStyle(
                              color: isLight
                                  ? MyColors.roxoEscuro
                                  : MyColors.cinzaClaro,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10,),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
