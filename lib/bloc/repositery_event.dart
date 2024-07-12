import 'package:equatable/equatable.dart';
abstract class RepositoryEvent {}

class FetchRepositories extends RepositoryEvent {}

class FilterRepositoriesByLanguage extends RepositoryEvent {
  final String language;

  FilterRepositoriesByLanguage(this.language);
}

class FetchMoreRepositories extends RepositoryEvent {}  // New event for pagination
