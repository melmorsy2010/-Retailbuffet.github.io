import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'food.dart';
import 'foodlist.dart';



class FoodScreen extends StatefulWidget {
  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final _drinksList = Foodlist();
  final TextEditingController _nameController = TextEditingController();
  int _floor = 1;
  List<String> _sugarOptions = ['1', '2', '3', '4',];
  String _selectedSugar = '1';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _drinksList.loadDrinks();
    _loadUserData();

  }

  Future<void> _openWhatsApp(Food food) async {
    final String apiUrl = 'https://raw.githubusercontent.com/melmorsy2010/Retailtribebuffet/main/number.json';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      print("nazmy");

      final phone = data['phone'];
      final message = 'لو سمحت \n المطلوب "   *${food.name}*" \n الكمية " *${_selectedSugar}* "  \n *التوصيل الى* 👈👈 "${_nameController.text}" \n  الدور " *${_floor.toString()}* "🏴󠁶󠁵󠁭󠁡󠁰󠁿🏴󠁶󠁵󠁭󠁡󠁰󠁿 ';

      await launch('$phone&text=${Uri.encodeFull(message)}');
    } else {
      print('Failed to fetch JSON data.');
    }
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? '';
    final floor = prefs.getInt('الدور') ?? 1;
    setState(() {
      _nameController.text = name;
      _floor = floor;
    });
  }
  void _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _nameController.text);
    prefs.setInt('الدور', _floor);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Colors.brown,
        title: Text('Food '),

      ),
      body: Column(
        children: [

          SizedBox(height: 8),
          ExpansionTile(

            title: Text("Set your Delivery Data",style: GoogleFonts.openSans(fontWeight: FontWeight.bold),),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                child: TextField(

                  controller: _nameController,style: GoogleFonts.cairo(fontWeight: FontWeight.bold),

                  decoration: InputDecoration(
                    labelText: 'Enter your name',

                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: Icon(Icons.person),
                    suffixIcon: DropdownButton<int>(
                      value: _floor,
                      onChanged: (int? newValue) {
                        setState(() {
                          _floor = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text('الدور الاول'),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Text('الدور الثانى'),
                        ),
                        DropdownMenuItem<int>(
                          value: 3,
                          child: Text('الدور الثالث'),
                        ),
                        DropdownMenuItem<int>(
                          value: 4,
                          child: Text('الدور الرابع'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.brown,),
                      onPressed: () {
                        _saveUserData();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FoodScreen()));              },
                      child: Text('Save your Data'),
                    ),

                  ],
                ),
              ),





            ],
          ),


          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: TextField(
              style: GoogleFonts.cairo(),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Find your favorite Food',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _drinksList.loadDrinks(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading drinks'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _drinksList.drinks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final drink = _drinksList.drinks[index];

                    if (!_searchText.isEmpty &&
                        !drink.name.toLowerCase().contains(_searchText.toLowerCase())) {
                      return Container();
                    }

                    return ListTile(
                      leading:SizedBox(
                        width: 100, // Adjust the width as needed
                        height: 100, // Adjust the height as needed
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Adjust the radius value as needed
                          child: CachedNetworkImage(
                            imageUrl: drink.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) =>
                                SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),


                      title: Text(drink.name,style: GoogleFonts.cairo(fontWeight: FontWeight.bold),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EGP ${drink.price.toStringAsFixed(2)}',style: TextStyle(color: Colors.red),),
                          SizedBox(height: 5),
                          Text('Quantity:'),
                          DropdownButton<String>(
                            value: _selectedSugar,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSugar = newValue!;
                              });
                            },
                            items: _sugarOptions.map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      trailing: SingleChildScrollView(
                        child: Column(
                          children: [
                            GestureDetector(

                              child: Text("Request"),
                              onTap: () {
                                _openWhatsApp(drink);
                              },

                            ),
                            Container(
                              child: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  _openWhatsApp(drink);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
