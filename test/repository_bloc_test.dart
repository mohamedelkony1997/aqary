import 'package:aqary/bloc/repositery_bloc.dart';
import 'package:aqary/bloc/repositery_event.dart';
import 'package:aqary/bloc/repositery_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'repository_bloc_test.mocks.dart'; // Ensure correct import path for generated mocks

// Generate mocks
@GenerateMocks([GraphQLClient])
void main() {
  late MockGraphQLClient mockGraphQLClient;
  late RepositoryBloc repositoryBloc;

  setUp(() {
    mockGraphQLClient = MockGraphQLClient();

   
    when(mockGraphQLClient.query(any)).thenAnswer((Invocation invocation) async {
      final QueryOptions options = invocation.positionalArguments[0] as QueryOptions;

      if (options == null) {
        throw ArgumentError('Query options cannot be null');
      }

    
      return QueryResult(
        source: QueryResultSource.network,
        data: {
          'search': {
            'edges': [
              {
                'cursor': 'Y3Vyc29yOnYyOpHOACWlVQ==',
                'node': {
                  'name': 'flutter',
                  'description': 'Flutter makes it easy and fast to build beautiful apps for mobile and beyond.',
                  'primaryLanguage': {'name': 'Dart'}
                }
              }
            ],
            'pageInfo': {'endCursor': 'Y3Vyc29yOnYyOpHOACWlVQ==', 'hasNextPage': true}
          }
        }, options: ,
      );
    });

    repositoryBloc = RepositoryBloc();
  });

  tearDown(() {
    repositoryBloc.close();
  });

  group('RepositoryBloc', () {
    blocTest<RepositoryBloc, RepositoryState>(
      'emits [RepositoryState] with repositories when FetchRepositories is added',
      build: () => repositoryBloc,
      act: (bloc) => bloc.add(FetchRepositories()),
      expect: () => [
        RepositoryState(
          repositories: [
            {
              'cursor': 'Y3Vyc29yOnYyOpHOACWlVQ==',
              'node': {
                'name': 'flutter',
                'description': 'Flutter makes it easy and fast to build beautiful apps for mobile and beyond.',
                'primaryLanguage': {'name': 'Dart'}
              }
            }
          ],
          errorMessage: '',
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<RepositoryBloc, RepositoryState>(
      'emits [RepositoryState] with error message when FetchRepositories fails',
      build: () => repositoryBloc,
      act: (bloc) => bloc.add(FetchRepositories()),
      expect: () => [
        RepositoryState(repositories: [], errorMessage: 'Exception: Failed to fetch data', hasReachedMax: false),
      ],
    );
  });
}