/// Entity representing OMDb ratings (IMDb, Rotten Tomatoes, Metacritic)
class OmdbRating {
  final String? imdbRating;
  final String? imdbVotes;
  final String? rottenTomatoesRating;
  final String? metascore;
  final String? rated;
  final String? awards;
  final String? boxOffice;

  const OmdbRating({
    this.imdbRating,
    this.imdbVotes,
    this.rottenTomatoesRating,
    this.metascore,
    this.rated,
    this.awards,
    this.boxOffice,
  });

  bool get hasAnyRating =>
      (imdbRating != null && imdbRating != 'N/A') ||
      (rottenTomatoesRating != null && rottenTomatoesRating != 'N/A') ||
      (metascore != null && metascore != 'N/A');
}
