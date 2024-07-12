import 'package:aqary/bloc/repositery_event.dart';
import 'package:aqary/bloc/repositery_state.dart';
import 'package:aqary/graphql_client.dart';
import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';



import 'package:hive/hive.dart';


class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  final Box _repositoryBox = Hive.box('repositories');

  RepositoryBloc() : super(RepositoryState(repositories: [], errorMessage: '', hasReachedMax: false)) {
    on<FetchRepositories>(_onFetchRepositories);
    on<FilterRepositoriesByLanguage>(_onFilterRepositoriesByLanguage);
    on<FetchMoreRepositories>(_onFetchMoreRepositories);
  }

  Future<void> _onFetchRepositories(FetchRepositories event, Emitter<RepositoryState> emit) async {
    final client = setupGraphQLClient();
    const query = '''
      query {
        search(query: "stars:>100", type: REPOSITORY, first: 10) {
          edges {
            cursor
            node {
              ... on Repository {
                name
                description
                primaryLanguage {
                  name
                }
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    ''';

    try {
      final result = await client.query(QueryOptions(document: gql(query)));
      if (result.hasException) {
        // Load from cache if available
        final cachedRepositories = _repositoryBox.get('repositories');
        if (cachedRepositories != null) {
          emit(RepositoryState(
            repositories: cachedRepositories,
            errorMessage: 'Failed to fetch data from network, loaded from cache.',
          ));
        } else {
          emit(RepositoryState(repositories: [], errorMessage: result.exception.toString()));
        }
      } else {
        final repositories = result.data!['search']['edges'];
        final pageInfo = result.data!['search']['pageInfo'];
        // Save to cache
        _repositoryBox.put('repositories', repositories);
        emit(RepositoryState(repositories: repositories, errorMessage: '', hasReachedMax: !pageInfo['hasNextPage']));
      }
    } catch (e) {
      // Load from cache if available
      final cachedRepositories = _repositoryBox.get('repositories');
      if (cachedRepositories != null) {
        emit(RepositoryState(
          repositories: cachedRepositories,
          errorMessage: 'Failed to fetch data from network, loaded from cache.',
        ));
      } else {
        emit(RepositoryState(repositories: [], errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onFetchMoreRepositories(FetchMoreRepositories event, Emitter<RepositoryState> emit) async {
    if (state.hasReachedMax) return;

    final client = setupGraphQLClient();
    final query = '''
      query (\$cursor: String) {
        search(query: "stars:>100", type: REPOSITORY, first: 10, after: \$cursor) {
          edges {
            cursor
            node {
              ... on Repository {
                name
                description
                primaryLanguage {
                  name
                }
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    ''';

    try {
      final result = await client.query(QueryOptions(document: gql(query), variables: {
        'cursor': state.repositories.isNotEmpty
            ? state.repositories.last['cursor']
            : null,
      }));
      if (result.hasException) {
        emit(state.copyWith(errorMessage: result.exception.toString()));
      } else {
        final newRepositories = result.data!['search']['edges'];
        final pageInfo = result.data!['search']['pageInfo'];
        emit(state.copyWith(
          repositories: List.of(state.repositories)..addAll(newRepositories),
          hasReachedMax: !pageInfo['hasNextPage'],
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterRepositoriesByLanguage(FilterRepositoriesByLanguage event, Emitter<RepositoryState> emit) async {
    final client = setupGraphQLClient();
    final query = '''
      query (\$cursor: String) {
        search(query: "language:${event.language} stars:>100", type: REPOSITORY, first: 10, after: \$cursor) {
          edges {
            cursor
            node {
              ... on Repository {
                name
                description
                primaryLanguage {
                  name
                }
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    ''';

    try {
      final result = await client.query(QueryOptions(document: gql(query), variables: {
        'cursor': null,
      }));
      if (result.hasException) {
        emit(RepositoryState(repositories: [], errorMessage: result.exception.toString()));
      } else {
        final repositories = result.data!['search']['edges'];
        final pageInfo = result.data!['search']['pageInfo'];
        emit(RepositoryState(repositories: repositories, errorMessage: '', hasReachedMax: !pageInfo['hasNextPage']));
      }
    } catch (e) {
      emit(RepositoryState(repositories: [], errorMessage: e.toString()));
    }
  }
}
