import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../chat_screen.dart';
import 'model/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProviderDetailPage extends StatefulWidget {
  final Provider provider;

  ProviderDetailPage({super.key, required this.provider});

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref('Requests');

  Razorpay razorpay = Razorpay();
  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool a = false;
  bool _paymentSuccessful = false;
  final formKey = GlobalKey<FormState>();
  // To track payment status

  @override
  void initState() {
    super.initState();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF0EFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.provider.profileImageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.provider.profileImageUrl,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                        : Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.provider.firstName} ${widget.provider.lastName}',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.provider.category,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'From: ${widget.provider.city}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xffFA9600),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/images/phone_call.png',
                              width: 30,
                              height: 30,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              _makePhoneCall(widget.provider.phoneNumber);
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/images/chat_icon.png',
                              width: 30,
                              height: 30,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              String currentUserId = _auth.currentUser!.uid;
                              String docName =
                                  '${widget.provider.firstName.toString()} ${widget.provider.lastName.toString()}';

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    providerId: widget.provider.uid,
                                    providerName: docName,
                                    userrrtId: currentUserId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffFFB342),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _openMap,
                  child: Text(
                    'VIEW LOCATION ON MAP',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Text(
                'Select Date & Time',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xffF0EFFF),
                  border: Border.all(
                    color: Color(0xffC8C4FF),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff0064FA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectDate(context),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MM/dd/yyyy').format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, letterSpacing: 0.6),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff0064FA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectTime(context),
                            child: Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, letterSpacing: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: formKey,
                      child: TextField(
                        controller: _descriptionController,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xffF0EFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: a,
                    onChanged: (value) {
                      setState(() {
                        a = value!;
                      });
                    },
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Color(0xffFFB342),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "You have to pay 50% of the amount of service while booking, and another 50% will be collected by our service provider after the service is completed.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0064FA),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fixedSize: Size(400, 70),
                ),
                onPressed: () {
                  if(!formKey.currentState!.validate()) return;
                  var options = {
                    'key': 'rzp_test_TkM6x97TEmMQ7T',
                    'amount': 20000,
                    'name': 'Homeservice',
                    'description': 'Booking fees',
                    'prefill': {
                      'contact': '8888888888',
                      'email': 'test@razorpay.com'
                    }
                  };
                  razorpay.open(options);


                },
                child: Text("PAY NOW"),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0064FA),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _paymentSuccessful
                      ? () {
                    if (_selectedDate != null &&
                        _selectedTime != null &&
                        _descriptionController.text.isNotEmpty) {
                      _bookService();
                    }
                  }
                      : null, // Disabled if payment is not successful
                  child: Text(
                    'BOOK SERVICE',
                    style: GoogleFonts.poppins(fontSize: 16, letterSpacing: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _openMap() async {
    final String googleMapUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.provider.latitude},${widget.provider.longitude}';
    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Could not open the map';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not make a call to $phoneNumber';
    }
  }

  void _bookService() {
    if (_selectedDate != null &&
        _selectedTime != null &&
        _descriptionController.text.isNotEmpty) {
      String date = DateFormat('MM/dd/yyyy').format(_selectedDate!);
      String time = _selectedTime!.format(context);
      String description = _descriptionController.text;
      String requestId = _requestDatabase.push().key!;
      String currentUserId = _auth.currentUser!.uid;
      String receiverId = widget.provider.uid;
      String status = 'pending';

      _requestDatabase.child(requestId).set({
        'date': date,
        'time': time,
        'description': description,
        'id': requestId,
        'receiver': receiverId,
        'sender': currentUserId,
        'status': status,
      }).then((_) {
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _descriptionController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Service booked successfully')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to book your Service, Try Again later!')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select a date and time also add a description for appointment')));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _paymentSuccessful = true; // Payment was successful
    });
    Fluttertoast.showToast(msg: "Your payment is successful!");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _paymentSuccessful = false; // Payment failed
    });
    Fluttertoast.showToast(msg: "Your payment failed.");
  }

  @override
  void dispose() {
    super.dispose();
    try {
      razorpay.clear(); // Removes all listeners
    } catch (e) {
      print(e);
    }
  }
}