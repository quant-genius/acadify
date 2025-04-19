
import 'dart:async';
import 'dart:js';

/// Utility functions for Firebase JS interop
class FirebaseJsUtils {
  /// Converts a JS Promise to a Dart Future
  static Future<T> handleThenable<T>(dynamic jsPromise) {
    final completer = Completer<T>();
    
    final onResolve = allowInterop((dynamic result) {
      completer.complete(result as T);
    });
    
    final onReject = allowInterop((dynamic error) {
      completer.completeError(error ?? 'Promise rejected');
    });
    
    jsPromise.then(onResolve, onReject);
    
    return completer.future;
  }
  
  /// Converts a Dart object to a JS object
  static dynamic jsify(Object? dartObject, [dynamic Function(dynamic)? customJsify]) {
    if (dartObject == null) return null;
    
    // Use custom jsify if provided
    if (customJsify != null) {
      return customJsify(dartObject);
    }
    
    // Convert Dart Map to JS object
    if (dartObject is Map) {
      final jsObject = newObject();
      dartObject.forEach((key, value) {
        setProperty(jsObject, key.toString(), jsify(value, customJsify));
      });
      return jsObject;
    }
    
    // Convert Dart List to JS array
    if (dartObject is List) {
      final jsArray = [];
      for (var item in dartObject) {
        callMethod(jsArray, 'push', [jsify(item, customJsify)]);
      }
      return jsArray;
    }
    
    // Return primitive values as is
    return dartObject;
  }
  
  /// Converts a JS object to a Dart object
  static dynamic dartify(dynamic jsObject) {
    if (jsObject == null) return null;
    
    // Check if the object is already a primitive Dart type
    if (jsObject is String || jsObject is num || jsObject is bool) {
      return jsObject;
    }
    
    // Handle JS arrays
    if (jsObject is Iterable) {
      return jsObject.map((item) => dartify(item)).toList();
    }
    
    // Handle JS objects
    if (_isJsObject(jsObject)) {
      final Map<String, dynamic> dartMap = {};
      final keys = _getObjectKeys(jsObject);
      
      for (var key in keys) {
        dartMap[key] = dartify(getProperty(jsObject, key));
      }
      
      return dartMap;
    }
    
    // Default case
    return jsObject;
  }
  
  /// Checks if an object is a JS object
  static bool _isJsObject(dynamic obj) {
    return obj != null && obj is! String && obj is! num && obj is! bool && obj is! List;
  }
  
  /// Gets the keys of a JS object
  static List<String> _getObjectKeys(dynamic jsObject) {
    final keysObj = context['Object'].callMethod('keys', [jsObject]);
    final List<String> keys = [];
    
    for (var i = 0; i < keysObj['length']; i++) {
      keys.add('${keysObj[i]}');
    }
    
    return keys;
  }
  
  // Private constructor to prevent instantiation
  FirebaseJsUtils._();
}
