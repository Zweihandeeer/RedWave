import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:RedWave/API/version.dart';
import 'package:RedWave/extensions/l10n.dart';
import 'package:RedWave/utilities/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n!.about),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 17, 8, 0),
              child: Text(
                'Red Wave  |  $appVersion',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'paytoneOne',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(
              color: Colors.white24,
              thickness: 0.8,
              height: 50,
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        'https://avatars.githubusercontent.com/u/22137445?s=400&u=12382b5cec5b6d1d77f49f6bfa740f732940eb0b&v=4',
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  'Luis Velásquez',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Software Engineer'),
                trailing: Wrap(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(FluentIcons.globe_24_filled),
                      tooltip: 'Website',
                      onPressed: () {
                        launchURL(
                          Uri.parse('https://github.com/Zweihandeeer'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
