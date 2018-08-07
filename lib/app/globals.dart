import 'package:movie_maker/app/cache.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

final Cache<Uint8List> cache = MemCache();

const MethodChannel methodChannel =
const MethodChannel('moviemaker.devunion.com/movie_maker_channel');