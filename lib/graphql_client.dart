import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

GraphQLClient setupGraphQLClient() {
  final HttpLink httpLink = HttpLink(
    'https://api.github.com/graphql',
    defaultHeaders: {
      'Authorization': 'token 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',
    },
  );

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: httpLink,
  );
}
