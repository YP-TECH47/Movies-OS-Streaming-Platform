import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/movie_provider.dart';
import '../core/api_constants.dart';
import 'movie_details_screen.dart';

class NewHotScreen extends StatelessWidget {
  const NewHotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upcomingMovies = Provider.of<MovieProvider>(context).upcomingMovies;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('New & Hot', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: const [
          Icon(Icons.cast, color: Colors.white),
          SizedBox(width: 20),
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 20),
        ],
      ),
      body: upcomingMovies.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : ListView.builder(
              itemCount: upcomingMovies.length,
              itemBuilder: (context, index) {
                final movie = upcomingMovies[index];
                String month = '';
                String day = '';
                try {
                   if (movie.releaseDate.isNotEmpty) {
                      DateTime date = DateTime.parse(movie.releaseDate);
                      month = DateFormat('MMM').format(date).toUpperCase();
                      day = DateFormat('dd').format(date);
                   }
                } catch(e) {}

                return GestureDetector(
                   onTap: () {
                     Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MovieDetailsScreen(movie: movie),
                     ));
                   },
                   child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(month, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(day, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: -2)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: '${ApiConstants.originalImageBaseUrl}${movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath}',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[850], height: 200),
                                  errorWidget: (context, url, err) => Container(color: Colors.grey[850], height: 200, child: const Icon(Icons.error, color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                movie.overview,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
