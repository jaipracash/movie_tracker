import 'package:flutter/material.dart';
import 'package:movie_tracker/utils/colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_list_model.dart';
import 'package:movie_tracker/pages/searchResultPage.dart';
import 'package:movie_tracker/components/movie_grid_view.dart';
import 'package:movie_tracker/pages/home_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool isSearchFocused = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool isLoading = false;
  List<Movie> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: mobileNavBar(context),
      desktop: desktopNavBar(),
    );
  }

  Widget mobileNavBar(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: 130.0,
        color: AppColors.navbarColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 15.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     'FilmFeed',
                     style: TextStyle(
                       fontSize: 30.0,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                   ),
                   InkWell(
                       onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) =>
                               HomePage()),
                         );
                       },
                     child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 15.0),),
                   )
                 ],
                             ),
              ),
            const SizedBox(height: 10.0),
            searchBar(220.0, 40.0, 13.0, 15.0),
            const SizedBox(height: 10.0),
            // Row(
            //   children: [
            //     navButton('New', 18.0),
            //     navButton('Popular', 18.0),
            //     navButton('Top Rated', 18.0),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget desktopNavBar() {
    return Container(
      width: double.infinity,
      height: 85.0,
      color: AppColors.navbarColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            const Text(
              'FilmFeed',
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Search Bar
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: searchBarDesktop(400.0, 40.0, 15.0, 20.0),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text(
                    'Home',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
                SizedBox(width: 27.0,),
                navButton('New', 18.0, 'upcoming'),
                SizedBox(width: 27.0,),
                navButton('Popular', 18.0, 'popular'),
                SizedBox(width: 27.0,),
                navButton('Top Rated', 18.0, 'top_rated'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchBarDesktop(double width, double height, double textSize, double iconSize) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsPage(query: value),
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search for "movies"',
                  hintStyle: TextStyle(fontSize: textSize),
                  border: InputBorder.none,
                ),
              ),
            ),
            Icon(
              Icons.search,
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget navButton(String text, double txtSz, String movieType) {
    return InkWell(
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                MovieGridView(movieType: movieType)),
          );
      },
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(text, style: TextStyle(color: Colors.white, fontSize: txtSz))
      ),
    );
  }

  Widget searchBar(double width, double height, double textSize, double iconSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible( // Allow the TextField to adapt
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultsPage(query: value),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for "movies"',
                    hintStyle: TextStyle(fontSize: textSize),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(width: 10), // Space between the text field and icon
              Icon(
                Icons.search,
                size: iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
