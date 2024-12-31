import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:movie_tracker/components/navBar.dart';
import 'package:movie_tracker/pages/regionTrendingMovies.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'movieRow.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: mobileHome(),
      desktop: desktopHome(),
    );
  }

  Widget desktopHome(){
    return Scaffold(
      body: Column(
        children: [
          NavBar(), // NavBar remains unaffected
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ContainerWithGradient(500.0, 60.0, 15.0, 20.0),
                  Container4(),
                  const MovieRow(movieType: 'popular'),
                  const MovieRow(movieType: 'top_rated'),
                  const MovieRow(movieType: 'upcoming'),
                  Container5()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mobileHome(){
    return Scaffold(
      body: Column(
        children: [
          NavBar(), // NavBar remains unaffected
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ContainerWithGradient(420, 32, 12, 10),
                  Container4(),
                  const MovieRow(movieType: 'popular' ),
                  const MovieRow(movieType: 'top_rated'),
                  const MovieRow(movieType: 'upcoming'),
                  Container5()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget ContainerWithGradient(double containerHeight, double topicText, double subtopicTxt, double sizedBxHei) {
    return Container(
      width: double.infinity,
      height: containerHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/multipleMoviePosters.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black,
                  ],
                  stops: [0.7, 1.0],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Your Personalized Guide to Movies, \nTV shows, and More',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: topicText,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: sizedBxHei), // Spacing between texts
                 Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Discover where to stream the latest, most popular, and upcoming movies and TV shows with FilmFeed—your ultimate entertainment guide!',
                    style: TextStyle(fontSize: subtopicTxt, color: Colors.white54,),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget Container4() {
    return Container(
      width: double.infinity,
      height: 500.0,
      child: TamilMoviesPage(),
    );
  }

  Widget Container5() {
    return Container(
      height: 250.0,
      width: double.infinity,
      color: Colors.black,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'FilmFeed',
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Divider(height: 1.0, color: Colors.grey, indent: 20.0, endIndent: 20.0,),
            SizedBox(height: 20.0,),
            Text('© FilmFeed - Made for project - Film data by TMDb.', style: TextStyle(color: Colors.white, fontSize: 11),),
            SizedBox(height: 10.0,)
          ],
        ),
      ),
    );
  }
}
