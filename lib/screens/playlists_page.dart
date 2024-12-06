import 'package:flutter/material.dart';
import 'package:RedWave/API/redwave.dart';
import 'package:RedWave/extensions/l10n.dart';
import 'package:RedWave/main.dart';
import 'package:RedWave/widgets/custom_search_bar.dart';
import 'package:RedWave/widgets/playlist_cube.dart';
import 'package:RedWave/widgets/spinner.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final TextEditingController _searchBar = TextEditingController();
  final FocusNode _inputNode = FocusNode();
  bool _showOnlyAlbums = false;

  void toggleShowOnlyAlbums(bool value) {
    setState(() {
      _showOnlyAlbums = value;
    });
  }

  @override
  void dispose() {
    _searchBar.dispose();
    _inputNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listas de reproducción',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'paytoneOne',
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          CustomSearchBar(
            onSubmitted: (String value) {
              setState(() {});
            },
            controller: _searchBar,
            focusNode: _inputNode,
            labelText: '${context.l10n!.search}...',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Switch(
                  value: _showOnlyAlbums,
                  onChanged: toggleShowOnlyAlbums,
                  thumbIcon: WidgetStateProperty.resolveWith<Icon>(
                    (Set<WidgetState> states) {
                      return Icon(
                        states.contains(WidgetState.selected)
                            ? Icons.album
                            : Icons.featured_play_list,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getPlaylists(
                query: _searchBar.text.isEmpty ? null : _searchBar.text,
                type: _showOnlyAlbums ? 'album' : 'playlist',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Spinner();
                } else if (snapshot.hasError) {
                  logger.log(
                    'Error on playlists page',
                    snapshot.error,
                    snapshot.stackTrace,
                  );
                  return Center(
                    child: Text(context.l10n!.error),
                  );
                }

                final _playlists = snapshot.data as List;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _playlists.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (BuildContext context, index) {
                    final playlist = _playlists[index];

                    return PlaylistCube(
                      playlist,
                      isAlbum: playlist['isAlbum'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
