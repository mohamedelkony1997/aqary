

class RepositoryState {
  final List<dynamic> repositories;
  final String errorMessage;
  final bool hasReachedMax;  // New property for pagination

  RepositoryState({
    required this.repositories,
    required this.errorMessage,
    this.hasReachedMax = false,  // Default to false
  });

  RepositoryState copyWith({
    List<dynamic>? repositories,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return RepositoryState(
      repositories: repositories ?? this.repositories,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
