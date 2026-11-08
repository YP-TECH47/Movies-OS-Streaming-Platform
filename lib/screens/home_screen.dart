import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../widgets/content_list.dart';
import '../core/api_constants.dart';
import '../screens/movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(
          (_scrollOffset / 350).clamp(0, 1).toDouble(),
        ),
        title: Text(
          'Cinema OS',
          style: TextStyle(
            color: const Color(0xFFE50914).withOpacity(
              (_scrollOffset / 350).clamp(0, 1).toDouble(),
            ),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.movie_filter, color: Color(0xFFE50914), size: 32),
        ),
        leadingWidth: _scrollOffset > 100 ? 0 : 50,
        actions: [
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white),
            onPressed: () {},// working on how to add screen cast in an app 
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},// currently no notifications from the aps side for the user
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 14,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: movieProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      _buildHero(context, movieProvider),
                      Container(
                        height: 500,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            if (movieProvider.trendingMovies.isNotEmpty)
                              Text(
                                movieProvider.trendingMovies.first.title.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _HeaderButton(icon: Icons.add, title: 'My List', onTap: () {}),
                                _PlayButton(movie: movieProvider.trendingMovies.isNotEmpty ? movieProvider.trendingMovies.first : null),
                                _HeaderButton(icon: Icons.info_outline, title: 'Info', onTap: () {
                                  if (movieProvider.trendingMovies.isNotEmpty) {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => MovieDetailsScreen(movie: movieProvider.trendingMovies.first),
                                    ));
                                  }
                                }),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: ContentList(
                      title: 'Trending Now',
                      movies: movieProvider.trendingMovies,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ContentList(
                    title: 'Top Rated',
                    movies: movieProvider.topRatedMovies,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ContentList(
                    title: 'Action Thrillers',
                    movies: movieProvider.actionMovies,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ContentList(
                    title: 'Comedies',
                    movies: movieProvider.comedyMovies,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ContentList(
                    title: 'Romance',
                    movies: movieProvider.romanceMovies,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20.0)),
              ],
            ),
    );
  }

  Widget _buildHero(BuildContext context, MovieProvider provider) {
    if (provider.trendingMovies.isEmpty) return const SizedBox(height: 500);
    final movie = provider.trendingMovies.first;
    return CachedNetworkImage(
      imageUrl: '${ApiConstants.originalImageBaseUrl}${movie.posterPath}',
      height: 500,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final dynamic movie;
  const _PlayButton({this.movie});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      icon: const Icon(Icons.play_arrow, size: 30, color: Colors.black),
      label: const Text(
        'Play',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      onPressed: () {
         if (movie != null) {
            Navigator.of(context).push(MaterialPageRoute(
               builder: (_) => MovieDetailsScreen(movie: movie),
            ));
         }
      },
    );
  }
}
