import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../core/api_constants.dart';
import '../core/api_service.dart';
import 'movie_player_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ApiService _apiService = ApiService();
  MovieDetail? _detailedInfo;
  List<Movie> _similarMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final details = await _apiService.getMovieDetails(widget.movie.id);
    final similar = await _apiService.getSimilarMovies(widget.movie.id);
    if (mounted) {
      setState(() {
        _detailedInfo = details;
        _similarMovies = similar;
        _isLoading = false;
      });
    }
  }

  Future<void> _playTrailer() async {
    final key = await _apiService.getMovieTrailerKey(widget.movie.id);
    if (key != null) {
      final url = Uri.parse('https://www.youtube.com/watch?v=$key');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch trailer')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trailer not available')),
        );
      }
    }
  }

  Future<void> _playFullMovie() async {
    final url = 'https://vidfast.pro/movie/${widget.movie.id}';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MoviePlayerScreen(
        movieUrl: url,
        movieTitle: widget.movie.title,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'hero${widget.movie.id}',
                child: CachedNetworkImage(
                   imageUrl: '${ApiConstants.originalImageBaseUrl}${widget.movie.backdropPath.isNotEmpty ? widget.movie.backdropPath : widget.movie.posterPath}',
                   fit: BoxFit.cover,
                   placeholder: (context, url) => Container(color: Colors.grey[900]),
                   errorWidget: (context, url, err) => Container(color: Colors.grey[900]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('98% Match', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(widget.movie.releaseDate.split('-').first, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)),
                        child: const Text('HD', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                      if (_detailedInfo != null) ...[
                        const SizedBox(width: 8),
                        Text('${_detailedInfo!.runtime}m', style: const TextStyle(color: Colors.grey)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: const Text('Play Movie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: _playFullMovie,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          icon: const Icon(Icons.ondemand_video, size: 28),
                          label: const Text('Trailer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: _playTrailer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  if (_detailedInfo != null && _detailedInfo!.genres.isNotEmpty)
                    Text.rich(
                      TextSpan(
                        text: 'Genres: ',
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: _detailedInfo!.genres.join(', '),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ]
                      )
                    ),
                  const SizedBox(height: 30),
                  const Text('More Like This', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _similarMovies.length,
                          itemBuilder: (context, index) {
                            final simMovie = _similarMovies[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (_) => MovieDetailsScreen(movie: simMovie),
                                ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: '${ApiConstants.imageBaseUrl}${simMovie.posterPath}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
