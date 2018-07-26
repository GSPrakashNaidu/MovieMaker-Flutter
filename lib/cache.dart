import 'dart:async';
import 'dart:collection';

abstract class Cache<T> {
    Future<T> get(int index);
    put(int index, T object);
}

class MemCache<T> extends Cache<T> {
    final map = HashMap<int, T>();

    @override
    Future<T> get(int index) {
        return Future.value(map[index]);
    }

    @override
    put(int index, object) {
        map[index] = object;
    }
}