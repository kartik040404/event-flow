import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyEventDetailsFilling extends StatefulWidget {
  @override
  State<FacultyEventDetailsFilling> createState() => _FacultyEventDetailsFillingState();

}

class _FacultyEventDetailsFillingState extends State<FacultyEventDetailsFilling> {
  int? _selectedValue;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime, endTime;
  int count = 0, _selectedIndex = 0;
  bool agree = false,feedbak=false;
  String Startdate = "",
      EndDate = "",
      From = "",
      To = "",
      startdateError = "",
      enddateError = "",
      starttimeError = "",
      endtimeError = "";
  final startdate = TextEditingController(),
      enddate = TextEditingController(),
      starttime = TextEditingController(),
      endtime = TextEditingController();
  List<String> departments = [
    'Select',
    'CSE',
    'CSE(AIML)',
    'CSE(DS)',
    'Civil',
    'Mechanical',
    'E&TC'
  ];
  String selectedDepartment = 'Select';
  List<bool> checkedList = List.generate(
      12, (index) => false); // Initialize all checkboxes as unchecked
  String getItemDescription(int index) {
    switch (index) {
      case 1:
        return "LCD Projector";
      case 2:
        return "Podium Mic";
      case 3:
        return "Cord Mic";
      case 4:
        return "Cordless Mic";
      case 5:
        return "Collar Mic";
      case 6:
        return "Projector Remote";
      case 7:
        return "Presenter Pointer + USB dongle";
      case 8:
        return "Wireless KB/Mouse + USB dongle";
      case 9:
        return "Amplifier and Audio Mixer";
      case 10:
        return "System room key";
      case 11:
        return "AC Remotes";
      case 12:
        return "LCD Screen Remote";
      default:
        return "";
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  TextEditingController facultyNameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController programDetailsController = TextEditingController();
  TextEditingController coordinatorController = TextEditingController();
  TextEditingController coordinator_mobile_no_COntroller = TextEditingController();
  TextEditingController chiefGuestController = TextEditingController();
  TextEditingController no_of_chief_guest_Controller = TextEditingController();
  TextEditingController NoOfInvitiesController = TextEditingController();
  bool isDepartmentValid = true;
  // final DatabaseReference _database = FirebaseDatabase.instance
  //     .refFromURL("https://event-f3777-default-rtdb.firebaseio.com/");

  final emailID=FirebaseAuth.instance.currentUser?.email;
  @override
  Widget build(BuildContext context) {
    // // TODO: implement build
    // throw UnimplementedError();

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Text(
                  "Application for Booking Seminar Hall",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'MainFont',
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),

              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 2),
                  width: 350,
                  height: 2,
                  color: Colors.black,
                ),
              ),

              //---------------------------------------------------------------------------Name of the Faculty----------------------------------------
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "1) Name of the Faculty :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  child: TextFormField(
                    controller: facultyNameController,
                    decoration: InputDecoration(
                        hintText: "Name of the Faculty",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(15)),
                        errorStyle: TextStyle(fontFamily: "MainFont1")),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the faculty name';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //------------------------------------------------------Designation------------------------------------------
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "2) Designation :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  child: TextFormField(
                    controller: designationController,
                    decoration: InputDecoration(
                        hintText: "Designation",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(15)),
                        errorStyle: TextStyle(fontFamily: "MainFont1")),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Designation';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //------------------------------------------------------Department-----------------------------------------
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "3) Department :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),

              Center(
                child: SizedBox(
                  width: 340,
                  child: DropdownButtonFormField<String>(
                    value: selectedDepartment,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartment = newValue!;
                        isDepartmentValid =
                        true; // Reset validation state on change
                      });
                    },
                    items: departments
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorText: isDepartmentValid
                            ? null
                            : 'Please select a department',
                        errorStyle: TextStyle(fontFamily: "MainFont1")),
                    validator: (value) {
                      if (value == 'Select') {
                        return 'Please select a department';
                      }
                      return null; // Return null if the selection is valid
                    },
                  ),
                ),
              ),

              //------------------------------------------------------PhoneNo-----------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "4) Phone/Mobile No :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  child: TextFormField(
                    controller: phoneNoController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        hintText: "Phone/Mobile No",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(15)),
                        errorStyle: TextStyle(fontFamily: "MainFont1")),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Phone No';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //------------------------------------------------------Details of the Programs-----------------------------------------
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "5) Details of the Programs :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),

              Center(
                child: SizedBox(
                  height: 150,
                  width: 340,
                  child: TextFormField(
                    controller: programDetailsController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 50,
                    decoration: InputDecoration(
                        hintText: "Details of the Programs",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(15)),
                        errorStyle: TextStyle(fontFamily: "MainFont1")),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the details';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //------------------------------------------------------Hall Occupancy Dates-----------------------------------------
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "6) Hall Occupancy Dates :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),

              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      "Start date :",
                      style: TextStyle(fontFamily: "MainFont"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 100, top: 10),
                    child: Text(
                      "End date :",
                      style: TextStyle(fontFamily: "MainFont"),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          startDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2026),
                          );

                          if (startDate != null) {
                            setState(() {
                              startdateError =
                              ''; // Reset error message if date is selected
                              Startdate =
                                  DateFormat("yyyy-MM-dd").format(startDate!);
                            });
                          } else if (Startdate.isEmpty) {
                            setState(() {
                              startdateError = 'Please select a start date';
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.only(left: 20, top: 10),
                          child: Row(
                            children: [
                              Text(
                                Startdate.isEmpty
                                    ? "Start date"
                                    : "${Startdate}",
                                style: TextStyle(fontFamily: "MainFont1"),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.calendar_month_outlined),
                            ],
                          ),
                        ),
                      ),
                      if (startdateError.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 10),
                          child: Text(
                            startdateError,
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: "MainFont1",
                                fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          endDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2026));

                          if (endDate != null) {
                            setState(() {
                              enddateError =
                              ''; // Reset error message if date is selected
                              EndDate =
                                  DateFormat("yyyy-MM-dd").format(endDate!);
                            });
                          } else if (EndDate.isEmpty) {
                            setState(() {
                              enddateError = 'Please select the date';
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.only(left: 40, top: 10),
                          child: Row(
                            children: [
                              Text(
                                EndDate.isEmpty ? "End date" : "${EndDate}",
                                style: TextStyle(fontFamily: "MainFont1"),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.calendar_month_outlined),
                            ],
                          ),
                        ),
                      ),
                      if (enddateError.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 30, top: 10),
                          child: Text(
                            enddateError,
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: "MainFont1",
                                fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              //-----------------------------------------------------------Time------------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "7) Time :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),

              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      "From :",
                      style: TextStyle(fontFamily: "MainFont"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 135, top: 10),
                    child: Text(
                      "To :",
                      style: TextStyle(fontFamily: "MainFont"),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          startTime = await showTimePicker(
                              initialEntryMode: TimePickerEntryMode.input,
                              context: context,
                              initialTime: TimeOfDay.now());

                          if (startTime != null) {
                            setState(() {
                              starttimeError = "";
                              // String amPm = startTime!.hour >= 12 ? 'PM' : 'AM';
                              From = startTime!.hour.toString() +
                                  ":" +
                                  startTime!.minute.toString();
                            });
                          } else if (From.isEmpty) {
                            setState(() {
                              starttimeError = 'Please select the time';
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.only(left: 20, top: 10),
                          child: Row(
                            children: [
                              Text(
                                From.isEmpty ? "From" : "${From}",
                                style: TextStyle(fontFamily: "MainFont1"),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                      if (starttimeError.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            starttimeError,
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: "MainFont1",
                                fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          endTime = await showTimePicker(
                              initialEntryMode: TimePickerEntryMode.input,
                              context: context,
                              initialTime: TimeOfDay.now());

                          if (endTime != null) {
                            setState(() {
                              enddateError = "";
                              // String amPm = endTime!.hour >= 12 ? 'PM' : 'AM';
                              To = endTime!.hour.toString() +
                                  ":" +
                                  endTime!.minute.toString();
                            });
                          } else if (To.isEmpty) {
                            setState(() {
                              endtimeError = 'Please select the time';
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.only(left: 60, top: 10),
                          child: Row(
                            children: [
                              Text(
                                To.isEmpty ? "To" : "${To}",
                                style: TextStyle(fontFamily: "MainFont1"),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                      if (endtimeError.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 25, top: 10),
                          child: Text(
                            endtimeError,
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: "MainFont1",
                                fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              //-----------------------------------------------------------Name of the Co-ordinator------------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "8) Name of the Co-ordinator :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  child: TextFormField(
                    controller: coordinatorController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Name of the Co-ordinator",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the name';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //-----------------------------------------------------------Mobile No. of Co-ordinator------------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "9) Mobile No. of Co-ordinator :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  child: TextFormField(
                    controller: coordinator_mobile_no_COntroller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Mobile No. of Co-ordinator",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Mobile No';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //-----------------------------------------------------------Name of the Chief Guest------------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "10) Name of the Chief Guest :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  height: 100,
                  child: TextFormField(
                    controller: chiefGuestController,
                    maxLines: 50,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Name of the Chief Guest",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the name';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //-----------------------------------------------------------Numbers of Chief Guest Expected------------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "11) Numbers of Chief Guest Expected :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  child: TextFormField(
                    controller: no_of_chief_guest_Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Numbers of Chief Guest Expected",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the count';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //-----------------------------------------------------------Numbers of Invitees------------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "12) Numbers of Invitees :",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 340,
                  child: TextFormField(
                    controller: NoOfInvitiesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Numbers of Invitees",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the count';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              //-----------------------------------------------------------Other facility required:------------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "13) Other facility required: ",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),

              Center(
                child: Container(
                  width: 200,
                  margin: EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.white),
                        foregroundColor:
                        MaterialStateProperty.all(Colors.black),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                            side: BorderSide(width: 1)))),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  "Select Items",
                                  style: TextStyle(
                                      fontFamily: "MainFont",
                                      color: Colors.black),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                          fontFamily: "MainFont",
                                          color: Colors.black),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          "--------------------${checkedList.where((element) => element).length}");
                                      count = checkedList
                                          .where((element) => element)
                                          .length;
                                      getCount();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save',
                                        style: TextStyle(
                                            fontFamily: "MainFont",
                                            color: Colors.black)),
                                  ),
                                ],
                                content: Container(
                                  width: 800,
                                  height: 800,
                                  child: ListView.builder(
                                      itemBuilder: (context, index) {
                                        return Card(
                                          elevation: 2,
                                          color: Colors.white,
                                          child: CheckboxListTile(
                                              activeColor: Colors.black,
                                              value: checkedList[index],
                                              title: Text(
                                                "${index + 1}. ${getItemDescription(index + 1)}",
                                                style: TextStyle(
                                                    fontFamily: "MainFont1"),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  checkedList[index] = value!;
                                                });
                                              }),
                                        );
                                      },
                                      itemCount: 12),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      checkedList.where((element) => element).length == 0
                          ? "Select Items"
                          : "Selected Items :${count}",
                      style: TextStyle(fontFamily: "MainFont"),
                    ),
                  ),
                ),
              ),




              //--------------------------------------------------Feedback--------------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "14) Do you need feedback for this event : ",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),

              Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            activeColor: Colors.black,
                            value: 1,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value;
                              });
                            },
                          ),
                          Text('Yes',style: TextStyle(fontFamily: "MainFont")),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            activeColor: Colors.black,
                            value: 0,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value;
                              });
                            },
                          ),
                          Text('No',style: TextStyle(fontFamily: "MainFont")),
                        ],
                      ),
                    ],
                  )
              ),
              //--------------------------------------------------Instruction--------------------------------------------

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "Instruction: ",
                  style: TextStyle(fontFamily: "MainFont", fontSize: 19),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "1.	Display of only one banner is allowed on the stage (Standard size 5ft X 8ft) \n\n2.	Please do not alter the seating arrangement made in the hall. \n\n3.	Do not write on the LCD projector screen. \n\n4.	Damages, if any, will be claimed from the organizers. \n\n5.	Sticking/Pasting on interior wall is strictly banned. I / We agree to abide by the rules and regulations when using the seminar hall and maintain discipline.",
                  style: TextStyle(fontFamily: "MainFont"),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      child: Checkbox(
                        value: agree,
                        activeColor: Colors.black,
                        focusColor: Colors.black,
                        onChanged: (bool? value) {
                          setState(() {
                            agree = value!;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 300,
                      child: Text(
                        "I / We agree to abide by the rules and regulations when using the seminar hall and maintain discipline.",
                        style: TextStyle(fontFamily: "MainFont"),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(5),
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (Startdate.isEmpty) {
                        setState(() {
                          startdateError = "Please enter the date";
                        });
                      }
                      if (EndDate.isEmpty) {
                        setState(() {
                          enddateError = "Please enter the date";
                        });
                      }
                      if (From.isEmpty) {
                        setState(() {
                          starttimeError = "Please enter the time";
                        });
                      }
                      if (To.isEmpty) {
                        setState(() {
                          endtimeError = "Please enter the time";
                        });
                      }
                      if (!agree) {
                        setState(() {
                          Fluttertoast.showToast(
                            msg: "Please Check the Agreement",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Do you want to Submit?"),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("No"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await submitFormDataToFirestore();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(fontFamily: "MainFont"),
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getCount() {
    setState(() {});
  }

  // Future<void> submitFormDataToDatabase() async {
  //   try {
  //     await _database.push().set({
  //       'facultyName': facultyNameController.text,
  //       'designation': designationController.text,
  //       'department': selectedDepartment,
  //       'facultyPhoneNo': phoneNoController.text,
  //       'programDetails': programDetailsController.text,
  //       'startDate': Startdate,
  //       'endDate': EndDate,
  //       'startTime': From,
  //       'endTime': To,
  //       'nameOfCoordinator': coordinatorController,
  //       'mobileNoOfCoordinator': coordinator_mobile_no_COntroller,
  //       'nameOfChiefGuest': chiefGuestController,
  //       'noOfChiefGuest': no_of_chief_guest_Controller,
  //       'noOfInvites': NoOfInvitiesController,
  //       'selectedItemsCount': count,
  //       'selectedItems': getSelectedItemsList(),
  //       'timestamp': ServerValue.timestamp,
  //     });
  //     print(facultyNameController.text + " " + designationController.text);
  //     // resetFormFields();
  //   } catch (e) {
  //     print(
  //         "Error submitting form data: $e");
  //   }
  // }

  Future<void> submitFormDataToFirestore() async {
    try {
      await _firestore.collection('events').doc().set({
        'facultyName': facultyNameController.text,
        'designation': designationController.text,
        'department': selectedDepartment,
        'facultyPhoneNo': phoneNoController.text,
        'programDetails': programDetailsController.text,
        'startDate': Startdate,
        'endDate': EndDate,
        'startTime': From,
        'endTime': To,
        'nameOfCoordinator': coordinatorController.text,
        'mobileNoOfCoordinator': coordinator_mobile_no_COntroller.text,
        'nameOfChiefGuest': chiefGuestController.text,
        'noOfChiefGuest': no_of_chief_guest_Controller.text,
        'noOfInvites': NoOfInvitiesController.text,
        'selectedItemsCount': count,
        'selectedItems': getSelectedItemsList(),
        'timestamp': FieldValue.serverTimestamp(),
        'uniqueName': emailID,
        'permission': 'pending',
        'feedback': _selectedValue,
        'takeFeedback': 0,
      });

      // Show success message after submission
      Fluttertoast.showToast(
        msg: "Event details submitted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Optionally reset form or navigate away
      // resetFormFields();
      // Navigator.of(context).pop(); // or navigate to another screen

    } catch (e) {
      print("Error submitting form data: $e");
      // Show error message
      Fluttertoast.showToast(
        msg: "Error submitting event details",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  List<String> getSelectedItemsList() {
    List<String> selectedItems = [];
    for (int i = 0; i < checkedList.length; i++) {
      if (checkedList[i]) {
        selectedItems.add(getItemDescription(i + 1));
      }
    }
    return selectedItems;
  }
}
