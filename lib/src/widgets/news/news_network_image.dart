import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../utils/image_url_resolver.dart';

class NewsNetworkImage extends StatelessWidget {
  const NewsNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ImageUrlResolver.resolve(imageUrl);
    final displayUrl = resolvedUrl.isNotEmpty
        ? resolvedUrl
        : AppConstants.newsPlaceholderImage;

    final image = Image.network(
      displayUrl,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(showLoader: true);
      },
      errorBuilder: (context, error, stackTrace) {
        if (displayUrl != AppConstants.newsPlaceholderImage) {
          return Image.network(
            AppConstants.newsPlaceholderImage,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          );
        }
        return _placeholder();
      },
    );

    if (width == null && height == null) {
      return SizedBox.expand(child: image);
    }

    return image;
  }

  Widget _placeholder({bool showLoader = false}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceContainer,
      alignment: Alignment.center,
      child: showLoader
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.image_outlined,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
    );
  }
}
