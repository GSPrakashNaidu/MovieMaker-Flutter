import 'dart:async';
import 'dart:collection';

abstract class Cache<T> {
    Future<T> get(int key);
    put(int key, T object);
}

class MemCache<T> extends Cache<T> {
    final map = HashMap<int, T>();

    @override
    Future<T> get(int key) {
        return Future.value(map[key]);
    }

    @override
    put(int key, object) {
        map[key] = object;
    }
}