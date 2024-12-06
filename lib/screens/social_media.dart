import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMedia extends StatefulWidget {
  const SocialMedia({super.key});

  @override
  _SocialMediaState createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia> {
  // List of image URLs
  final List<String> imageUrls = [
    'https://ticketing-uploads-1.ticketplus.global/images/thumbs/bf274f8d2b48ec1d9c9c-summer-2025_%281%29.png?1732903615',
    'https://images.portaldisc.com/eventos/6279.jpg',
    'https://images.portaldisc.com/eventos/6225.jpg?t=1725469636'
  ];


  final List<String> urls = [
    'https://ticketplus.cl/events/florida-bier-festival-summer-18-de-enero',
    'https://www.portaldisc.com/evento/masquemusicaenmagnoliabar',
    'https://www.portaldisc.com/evento/elultimodiadelverano'
  ];

  List<bool> liked = List.generate(17, (_) => false);
  List<bool> showHeartOverlay = List.generate(17, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Próximos recitales',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'paytoneOne',
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      liked[index] = !liked[index];
                      showHeartOverlay[index] = true;
                    });

                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        showHeartOverlay[index] = false;
                      });
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrls[index],
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Show overlay heart when double-tapped
                if (showHeartOverlay[index])
                  Icon(
                    Icons.favorite,
                    color: Colors.red.withOpacity(0.8),
                    size: 100,
                  ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 10,
                  child: GestureDetector(
                    onTap: () async {
                      final url = urls[index];
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: const Icon(
                      Icons.link,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        liked[index] = !liked[index];
                      });
                    },
                    child: Icon(
                      liked[index] ? Icons.favorite : Icons.favorite_border,
                      color: liked[index] ? Colors.red : Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
