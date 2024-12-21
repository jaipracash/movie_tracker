import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:movie_tracker/utils/colors.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: mobileNavBar() ,
      desktop: desktopNavBar(),
    );
  }

  Widget mobileNavBar(){
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: 120.0,
        color: Colors.black,
        child: Column(
          children: [
            SizedBox(height: 15.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('FilmFeed', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                searchBar(200.0, 30.0, 10.0, 15.0),
              ],
            ),
            SizedBox(height: 10.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                navButton('New', 13.0),
                navButton('Popular', 13.0),
                navButton('Trending', 13.0)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget desktopNavBar(){
    return Container(
      width: double.infinity,
      height: 70.0,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('FilmFeed', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
          searchBar(300.0, 40.0, 15.0, 20.0),
          Row(
            children: [
              navButton('New', 18.0),
              navButton('Popular',18.0),
              navButton('Trending', 18.0)
            ],
          ),
          Icon(Icons.light_mode, color: Color(0xFFFFde21),)

        ],
      ),
    );
  }

  Widget navButton(String text, double txtSz) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
            onPressed: () {},
            child:
            Text(text, style: TextStyle(color: Colors.white, fontSize: txtSz))));
  }

  Widget searchBar(double width, double height, double textSize, double iconSize){
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10.0)
      ),
      child:  Padding(
        padding: EdgeInsets.all(10.0),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Search for "movies"', style: TextStyle(fontSize: textSize),),
            Icon(Icons.search, size: iconSize,)
          ],
        ),
      ),
    );
  }
}
