import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import 'shimmer_loading.dart';

/// Image widget with placeholder, loading state, and error handling
class ImageWithPlaceholder extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final Color? placeholderColor;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageWithPlaceholder({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.book,
    this.placeholderColor,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultPlaceholderColor = placeholderColor ?? 
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final defaultIconColor = isDark ? AppColors.iconDark : AppColors.iconLight;

    Widget buildPlaceholder() {
      if (placeholder != null) return placeholder!;
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: defaultPlaceholderColor,
          borderRadius: borderRadius,
        ),
        child: Icon(
          placeholderIcon,
          size: (width != null && height != null) 
              ? (width! < height! ? width! * 0.4 : height! * 0.4)
              : 40,
          color: defaultIconColor.withOpacity(0.5),
        ),
      );
    }

    Widget buildErrorWidget() {
      if (errorWidget != null) return errorWidget!;
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: defaultPlaceholderColor,
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.broken_image,
          size: (width != null && height != null) 
              ? (width! < height! ? width! * 0.4 : height! * 0.4)
              : 40,
          color: AppColors.error.withOpacity(0.5),
        ),
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return buildPlaceholder();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => ShimmerLoading(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        borderRadius: borderRadius,
      ),
      errorWidget: (context, url, error) => buildErrorWidget(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Book cover image with standard styling
class BookCoverImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final double borderRadius;

  const BookCoverImage({
    super.key,
    this.imageUrl,
    this.width = 140,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ImageWithPlaceholder(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: BorderRadius.circular(borderRadius),
        placeholderIcon: Icons.book,
      ),
    );
  }
}

