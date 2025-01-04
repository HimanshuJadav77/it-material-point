import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itmaterialspoint/Login_Register/Login.dart';
import 'package:itmaterialspoint/UI_widgets/elevated.dart';
import '../Custom/custom_widgets.dart';
import '../Custom/theme.dart';
import '../Services/mail_verification.dart';
import '../UI_widgets/snack_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _registerScreenState();
}

class _registerScreenState extends State<RegisterScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool isHide = true;

  File? pickedImage;
  final _imagePicker = ImagePicker();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  registerUser(String email, String password, String name, String phone) async {
    if (email == "" && password == "" && name == "" && phone == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            "Please Enter All Fields And/Or Upload Image.",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    } else {
      String errorMessage;
      try {
        setState(() {
          isLoading = true;
        });

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.toString().trim(),
            password: password.toString().trim());

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => verifyEmail(
                email: email,
                name: name,
                password: password,
                phone: phone,
                pickedImage: pickedImage,
                fromPage: "register",
              ),
            ));
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        switch (e.code) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Your password is wrong.";
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = "User with this email has been disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }

        showSnackBar(context, errorMessage);
      }
    }
  }

  showAlertBox() {
    return showDialog(
      barrierColor: Colors.black45,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Select Image",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () async {
                  try {
                    final photo = await _imagePicker.pickImage(
                        source: ImageSource.camera);
                    if (photo != null) {
                      final tempImage = File(photo.path);
                      setState(() {
                        pickedImage = tempImage;
                      });
                    }
                  } catch (e) {
                    print(e.toString());
                  }
                  Navigator.pop(context);
                },
                leading: const Icon(
                  Icons.camera,
                  color: Colors.black,
                ),
                title: const Text(
                  "Camera",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () async {
                  try {
                    final photo = await _imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (photo != null) {
                      final tempImage = File(photo.path);
                      setState(() {
                        pickedImage = tempImage;
                      });
                    }
                  } catch (e) {
                    print(e.toString());
                  }
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.image, color: Colors.black),
                title: const Text("Gallary",
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return customscaffold(
      color: Colors.white70,
      conpadding: const EdgeInsets.only(right: 25, left: 25),
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        children: [
          //      const SizedBox(height: 80),
          Expanded(
            flex: 5,
            child: Form(
              key: _formSignupKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // get started text
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontFamily: "karsyu",
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: lightColorScheme.primary,
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 35,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),

                    InkWell(
                      onTap: showAlertBox,
                      child: pickedImage != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(pickedImage!),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.black12,
                              radius: 60,
                              child: Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 60,
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    // full name
                    TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Full name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Full Name'),
                        prefixIcon: const Icon(Icons.person_2_outlined),
                        hintText: 'Enter Full Name',
                        hintStyle: const TextStyle(
                          color: Colors.black26,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    // email
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'Enter Email',
                        hintStyle: const TextStyle(
                          color: Colors.black26,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    //phonenumber
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      controller: phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Phone Number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Phone No.'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                        hintText: 'Enter Phone No.',
                        hintStyle: const TextStyle(
                          color: Colors.black26,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 25.0,
                    ),
                    // password
                    TextFormField(
                      controller: passwordController,
                      obscureText: isHide,
                      obscuringCharacter: '●',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Password'),
                        suffixIcon: IconButton(
                          icon: Icon(isHide
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_sharp),
                          onPressed: () {
                            setState(() {
                              isHide = !isHide;
                            });
                          },
                        ),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        hintText: 'Enter Password',
                        hintStyle: const TextStyle(
                          color: Colors.black26,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    // i agree to the processing
                    Row(
                      children: [
                        Checkbox(
                          value: agreePersonalData,
                          onChanged: (bool? value) {
                            setState(() {
                              agreePersonalData = value!;
                            });
                          },
                          activeColor: lightColorScheme.primary,
                        ),
                        const Text(
                          'I agree to the processing of ',
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          'Personal data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lightColorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    // signup button
                    SizedBox(
                      width: double.infinity,
                      child: ElvB(
                        onTab: () {
                          if (_formSignupKey.currentState!.validate() &&
                              agreePersonalData) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Processing Data'),
                              ),
                            );
                            if (passwordController.text.length == 6 ||
                                passwordController.text.length > 6) {
                              if (pickedImage != null) {
                                registerUser(
                                    emailController.text,
                                    passwordController.text,
                                    nameController.text,
                                    phoneController.text);
                              } else {
                                showSnackBar(
                                    context, "Please Select Your Image");
                              }
                            } else {
                              showSnackBar(context,
                                  "Password Length Must be 6 Characters.");
                            }
                          } else if (!agreePersonalData) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please agree to the processing of personal data')),
                            );
                          }
                        },
                        text: "Register",
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),
                    // already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}