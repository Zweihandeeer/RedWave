import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:RedWave/API/redwave.dart';
import 'package:RedWave/extensions/l10n.dart';
import 'package:RedWave/main.dart';
import 'package:RedWave/screens/playlist_page.dart';
import 'package:RedWave/services/router_service.dart';
import 'package:RedWave/services/settings_manager.dart';
import 'package:RedWave/widgets/marque.dart';
import 'package:RedWave/widgets/playlist_cube.dart';
import 'package:RedWave/widgets/song_bar.dart';
import 'package:RedWave/widgets/spinner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Red Wave',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'paytoneOne',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopNavBar(),
            _buildSuggestedPlaylists(),
            _buildRecommendedSongsAndArtists(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildNavButton(
              onPressed: () =>
                  NavigationManager.router.go('/home/userSongs/recents'),
              icon: const Icon(FluentIcons.history_24_filled),
              label: context.l10n!.recentlyPlayed,
            ),
            _buildNavButton(
              onPressed: () => NavigationManager.router.go('/home/playlists'),
              icon: const Icon(FluentIcons.list_24_filled),
              label: context.l10n!.playlists,
            ),
            _buildNavButton(
              onPressed: () =>
                  NavigationManager.router.go('/home/userSongs/liked'),
              icon: const Icon(FluentIcons.music_note_2_24_regular),
              label: context.l10n!.likedSongs,
            ),
            _buildNavButton(
              onPressed: () =>
                  NavigationManager.router.go('/home/userLikedPlaylists'),
              icon: const Icon(FluentIcons.task_list_ltr_24_regular),
              label: context.l10n!.likedPlaylists,
            ),
            _buildNavButton(
              onPressed: () =>
                  NavigationManager.router.go('/home/userSongs/offline'),
              icon: const Icon(FluentIcons.cellular_off_24_filled),
              label: context.l10n!.offlineSongs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback onPressed,
    required Icon icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
      ),
    );
  }

  Widget _buildSuggestedPlaylists() {
    return FutureBuilder<List<dynamic>>(
      future: getPlaylists(playlistsNum: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          logger.log(
            'Error in _buildSuggestedPlaylists',
            snapshot.error,
            snapshot.stackTrace,
          );
          return _buildErrorWidget(context);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildPlaylistSection(context, snapshot.data!);
      },
    );
  }

  Widget _buildPlaylistSection(BuildContext context, List<dynamic> playlists) {
    final playlistHeight = MediaQuery.sizeOf(context).height * 0.25 / 1.1;

    return Column(
      children: [
        _buildSectionHeader(
          title: context.l10n!.suggestedPlaylists,
          actionButton: IconButton(
            onPressed: () => NavigationManager.router.go('/home/playlists'),
            icon: Icon(
              FluentIcons.more_horizontal_24_regular,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SizedBox(
          height: playlistHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: playlists.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return PlaylistCube(
                playlist,
                isAlbum: playlist['isAlbum'],
                size: playlistHeight,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSongsAndArtists() {
    return ValueListenableBuilder<bool>(
      valueListenable: defaultRecommendations,
      builder: (_, recommendations, __) {
        return FutureBuilder<dynamic>(
          future: getRecommendedSongs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                logger.log(
                  'Error in _buildRecommendedSongsAndArtists',
                  snapshot.error,
                  snapshot.stackTrace,
                );
                return _buildErrorWidget(context);
              } else if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              return _buildRecommendedContent(
                context: context,
                data: snapshot.data,
                showArtists: !recommendations,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(35),
        child: Spinner(),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Text(
        '${context.l10n!.error}!',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildRecommendedContent({
    required BuildContext context,
    required List<dynamic> data,
    bool showArtists = true,
  }) {
    final contentHeight = MediaQuery.sizeOf(context).height * 0.25;

    return Column(
      children: [
        if (showArtists)
          _buildSectionHeader(title: context.l10n!.suggestedArtists),
        if (showArtists)
          SizedBox(
            height: contentHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                final artist = data[index]['artist'].split('~')[0];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistPage(
                        cubeIcon: FluentIcons.mic_sparkle_24_regular,
                        playlistId: artist,
                        isArtist: true,
                      ),
                    ),
                  ),
                  child: PlaylistCube(
                    {'title': artist},
                    borderRadius: 150,
                    onClickOpen: false,
                    showFavoriteButton: false,
                    cubeIcon: FluentIcons.mic_sparkle_24_regular,
                  ),
                );
              },
            ),
          ),
        _buildSectionHeader(
          title: context.l10n!.recommendedForYou,
          actionButton: IconButton(
            onPressed: () {
              setActivePlaylist({
                'title': context.l10n!.recommendedForYou,
                'list': data,
              });
            },
            icon: Icon(
              FluentIcons.play_circle_24_filled,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return SongBar(data[index], true);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, Widget? actionButton}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: MarqueeWidget(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }
}
