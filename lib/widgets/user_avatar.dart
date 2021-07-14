import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key? key,
    required this.identity,
    required this.placeholderPhotoUrl,
    required this.fontSize,
  }) : super(key: key);

  final GoogleIdentity identity;
  final String placeholderPhotoUrl;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: LayoutBuilder(builder: _buildClippedImage),
    );
  }

  Widget _buildClippedImage(BuildContext context, BoxConstraints constraints) {
    assert(constraints.maxWidth == constraints.maxHeight);

    // Placeholder to use when there is no photo URL, and while the photo is
    // loading. Uses the first character of the display name (if it has one),
    // or the first letter of the email address if it does not.
    final List<String?> placeholderCharSources = <String?>[
      identity.displayName,
      identity.email,
      '-',
    ];
    final String placeholderChar = placeholderCharSources
        .firstWhere((String? str) => str != null && str.trimLeft().isNotEmpty)!
        .trimLeft()[0]
        .toUpperCase();
    final Widget placeholder = Center(
      child: Text(
        placeholderChar,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize),
      ),
    );

    final String? photoUrl = identity.photoUrl ?? placeholderPhotoUrl;
    if (photoUrl == null) {
      return placeholder;
    }

    // Add a sizing directive to the profile photo URL.
    final double size =
        MediaQuery.of(context).devicePixelRatio * constraints.maxWidth;

    // Fade the photo in over the top of the placeholder.
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            placeholder,
            FadeInImage.assetNetwork(
              // This creates a transparent placeholder image, so that
              // [placeholder] shows through.
              placeholder: placeholderPhotoUrl,
              image: identity.photoUrl!,
            )
          ],
        ),
      ),
    );
  }
}
