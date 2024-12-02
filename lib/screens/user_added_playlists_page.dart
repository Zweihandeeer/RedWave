import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:RedWave/API/redwave.dart';
import 'package:RedWave/extensions/l10n.dart';
import 'package:RedWave/main.dart';
import 'package:RedWave/screens/playlist_page.dart';
import 'package:RedWave/utilities/flutter_toast.dart';
import 'package:RedWave/widgets/confirmation_dialog.dart';
import 'package:RedWave/widgets/playlist_cube.dart';
import 'package:RedWave/widgets/spinner.dart';

class UserPlaylistsPage extends StatefulWidget {
  const UserPlaylistsPage({super.key});

  @override
  State<UserPlaylistsPage> createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends State<UserPlaylistsPage> {
  late Future<List> _playlistsFuture;
  bool isYouTubeMode = true;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = getUserPlaylists();
  }

  Future<void> _refreshPlaylists() async {
    setState(() {
      _playlistsFuture = getUserPlaylists();
    });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              var id = '';
              var customPlaylistName = '';
              String? imageUrl;

              return StatefulBuilder(
                builder: (context, setState) {
                  final activeButtonBackground =
                      Theme.of(context).colorScheme.surfaceContainer;
                  final inactiveButtonBackground =
                      Theme.of(context).colorScheme.secondaryContainer;
                  return AlertDialog(
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isYouTubeMode = true;
                                    id = '';
                                    customPlaylistName = '';
                                    imageUrl = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isYouTubeMode
                                      ? inactiveButtonBackground
                                      : activeButtonBackground,
                                ),
                                child:
                                    const Icon(FluentIcons.globe_add_24_filled),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isYouTubeMode = false;
                                    id = '';
                                    customPlaylistName = '';
                                    imageUrl = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isYouTubeMode
                                      ? activeButtonBackground
                                      : inactiveButtonBackground,
                                ),
                                child: const Icon(
                                  FluentIcons.person_add_24_filled,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          if (isYouTubeMode)
                            TextField(
                              decoration: InputDecoration(
                                labelText:
                                    context.l10n!.youtubePlaylistLinkOrId,
                              ),
                              onChanged: (value) {
                                id = value;
                              },
                            )
                          else ...[
                            TextField(
                              decoration: InputDecoration(
                                labelText: context.l10n!.customPlaylistName,
                              ),
                              onChanged: (value) {
                                customPlaylistName = value;
                              },
                            ),
                            const SizedBox(height: 7),
                            TextField(
                              decoration: InputDecoration(
                                labelText: context.l10n!.customPlaylistImgUrl,
                              ),
                              onChanged: (value) {
                                imageUrl = value;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          context.l10n!.add.toUpperCase(),
                        ),
                        onPressed: () async {
                          if (isYouTubeMode && id.isNotEmpty) {
                            showToast(
                              context,
                              await addUserPlaylist(id, context),
                            );
                          } else if (!isYouTubeMode &&
                              customPlaylistName.isNotEmpty) {
                            showToast(
                              context,
                              createCustomPlaylist(
                                customPlaylistName,
                                imageUrl,
                                context,
                              ),
                            );
                          } else {
                            showToast(
                              context,
                              '${context.l10n!.provideIdOrNameError}.',
                            );
                          }

                          Navigator.pop(context);
                          await _refreshPlaylists();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(FluentIcons.add_24_filled),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 15),
        child: FutureBuilder(
          future: _playlistsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Spinner();
            } else if (snapshot.hasError) {
              logger.log(
                'Error on user playlists page',
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
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: _playlists.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, index) {
                final playlist = _playlists[index];
                final ytid = playlist['ytid'];

                return GestureDetector(
                  onTap: playlist['isCustom'] ?? false
                      ? () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlaylistPage(playlistData: playlist),
                            ),
                          );
                          if (result == false) {
                            setState(() {});
                          }
                        }
                      : null,
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmationDialog(
                          confirmationMessage:
                              context.l10n!.removePlaylistQuestion,
                          submitMessage: context.l10n!.remove,
                          onCancel: () {
                            Navigator.of(context).pop();
                          },
                          onSubmit: () {
                            Navigator.of(context).pop();

                            if (ytid == null && playlist['isCustom']) {
                              removeUserCustomPlaylist(playlist);
                            } else {
                              removeUserPlaylist(ytid);
                            }

                            _refreshPlaylists();
                          },
                        );
                      },
                    );
                  },
                  child: PlaylistCube(
                    playlist,
                    playlistData:
                        playlist['isCustom'] ?? false ? playlist : null,
                    onClickOpen: playlist['isCustom'] == null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
