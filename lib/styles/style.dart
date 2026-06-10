import 'package:flutter/material.dart';
import 'package:euro_app/pages/finals_page.dart';

class AppBarEuro extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarEuro({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: Row(
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinalsPage()),
                );
              },
              child: const LogoBlackandWhite(maxWidth: 150),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class LogoBlackandWhite extends StatelessWidget {
  const LogoBlackandWhite({super.key, this.maxWidth});

  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final image = Image.asset(
      isDarkTheme
          ? 'assets/images/logo_white_txt.png'
          : 'assets/images/logo_black_txt.png',
      height: 40,
      fit: BoxFit.contain,
    );

    if (maxWidth == null) {
      return image;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: image,
    );
  }
}
