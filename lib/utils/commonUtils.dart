
class CommonUtils {
  static String formatMovieType(String movieType) {
    final formattedType = movieType.replaceAll('_', ' ');
    return formattedType[0].toUpperCase() + formattedType.substring(1).toLowerCase();
  }
}
