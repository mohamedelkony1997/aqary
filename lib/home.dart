import 'package:aqary/bloc/repositery_bloc.dart';
import 'package:aqary/bloc/repositery_event.dart';
import 'package:aqary/bloc/repositery_state.dart';
import 'package:aqary/repository_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class RepositoryListScreen extends StatefulWidget {
  @override
  _RepositoryListScreenState createState() => _RepositoryListScreenState();
}

class _RepositoryListScreenState extends State<RepositoryListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      BlocProvider.of<RepositoryBloc>(context).add(FetchMoreRepositories());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Trending Repositories'),
        actions: [
          _buildLanguageFilter(context),
        ],
      ),
      body: BlocBuilder<RepositoryBloc, RepositoryState>(
        builder: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.repositories.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: state.repositories.length + (state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= state.repositories.length) {
                return Center(child: CircularProgressIndicator());
              }

              final repository = state.repositories[index]['node'];
              return ListTile(
                title: Text(repository['name']),
                subtitle: Text(repository['description'] ?? 'No description available'),
                trailing: Text(repository['primaryLanguage']?['name'] ?? 'Unknown'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RepositoryDetailScreen(repository: repository),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLanguageFilter(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        BlocProvider.of<RepositoryBloc>(context).add(FilterRepositoriesByLanguage(value));
      },
      itemBuilder: (context) {
        return ['JavaScript', 'Python', 'Java', 'C++'].map((language) {
          return PopupMenuItem(
            value: language,
            child: Text(language),
          );
        }).toList();
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
