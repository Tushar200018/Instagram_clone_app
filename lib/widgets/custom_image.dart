import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

cachedNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, mediaUrl) => CircularProgressIndicator(),
    errorWidget: (context, mediaUrl, error) => Icon(Icons.error),
  );
}
