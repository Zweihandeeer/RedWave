import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:RedWave/API/version.dart';
import 'package:RedWave/screens/about_page.dart';
import 'package:RedWave/screens/bottom_navigation_page.dart';
import 'package:RedWave/screens/home_page.dart';
import 'package:RedWave/screens/playlists_page.dart';
import 'package:RedWave/screens/search_page.dart';
import 'package:RedWave/screens/settings_page.dart';
import 'package:RedWave/screens/social_media.dart';
import 'package:RedWave/screens/user_added_playlists_page.dart';
import 'package:RedWave/screens/user_liked_playlists_page.dart';
import 'package:RedWave/screens/user_songs_page.dart';
import 'package:RedWave/services/settings_manager.dart';

class NavigationManager {
  factory NavigationManager() {
    return _instance;
  }

  NavigationManager._internal() {
    final routes = [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: !offlineMode.value ? _onlineRoutes() : _offlineRoutes(),
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return getPage(
            child: BottomNavigationPage(
              child: navigationShell,
            ),
            state: state,
          );
        },
      ),
    ];

    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: homePath,
      routes: routes,
    );
  }
  static final NavigationManager _instance = NavigationManager._internal();

  static NavigationManager get instance => _instance;

  static late final GoRouter router;

  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> searchTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> socialMediaTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> userPlaylistsTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> settingsTabNavigatorKey =
      GlobalKey<NavigatorState>();

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static const String homePath = '/home';
  static const String settingsPath = '/settings';
  static const String social = '/social';
  static const String searchPath = '/search';
  static const String userPlaylistsPath = '/userPlaylists';

  List<StatefulShellBranch> _onlineRoutes() {
    return [
      StatefulShellBranch(
        navigatorKey: homeTabNavigatorKey,
        routes: [
          GoRoute(
            path: homePath,
            pageBuilder: (context, GoRouterState state) {
              return getPage(
                child: const HomePage(),
                state: state,
              );
            },
            routes: [
              GoRoute(
                path: 'userSongs/:page',
                builder: (context, state) => UserSongsPage(
                  page: state.pathParameters['page'] ?? 'liked',
                ),
              ),
              GoRoute(
                path: 'playlists',
                builder: (context, state) => const PlaylistsPage(),
              ),
              GoRoute(
                path: 'userLikedPlaylists',
                builder: (context, state) => const UserLikedPlaylistsPage(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: searchTabNavigatorKey,
        routes: [
          GoRoute(
            path: searchPath,
            pageBuilder: (context, GoRouterState state) {
              return getPage(
                child: const SearchPage(),
                state: state,
              );
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: socialMediaTabNavigatorKey,
        routes: [
          GoRoute(
            path: social,
            pageBuilder: (context, GoRouterState state) {
              return getPage(
                child: const SocialMedia(),
                state: state,
              );
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: userPlaylistsTabNavigatorKey,
        routes: [
          GoRoute(
            path: userPlaylistsPath,
            pageBuilder: (context, GoRouterState state) {
              return getPage(
                child: const UserPlaylistsPage(),
                state: state,
              );
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: settingsTabNavigatorKey,
        routes: [
          GoRoute(
            path: settingsPath,
            pageBuilder: (context, state) {
              return getPage(
                child: const SettingsPage(),
                state: state,
              );
            },
            routes: [
              GoRoute(
                path: 'license',
                builder: (context, state) => const LicensePage(
                  applicationName: 'Red Wave',
                  applicationVersion: appVersion,
                ),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<StatefulShellBranch> _offlineRoutes() {
    return [
      StatefulShellBranch(
        navigatorKey: homeTabNavigatorKey,
        routes: [
          GoRoute(
            path: homePath,
            pageBuilder: (context, GoRouterState state) {
              return getPage(
                child: const UserSongsPage(page: 'offline'),
                state: state,
              );
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: settingsTabNavigatorKey,
        routes: [
          GoRoute(
            path: settingsPath,
            pageBuilder: (context, state) {
              return getPage(
                child: const SettingsPage(),
                state: state,
              );
            },
            routes: [
              GoRoute(
                path: 'license',
                builder: (context, state) => const LicensePage(
                  applicationName: 'Red Wave',
                  applicationVersion: appVersion,
                ),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  static Page getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
    );
  }
}
