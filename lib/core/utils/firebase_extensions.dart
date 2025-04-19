
import 'dart:async';
import 'dart:js' as js;

/// Utility functions for Firebase JS interop
class FirebaseJsUtils {
  /// Converts a JS Promise to a Dart Future
  static Future<T> handleThenable<T>(dynamic jsPromise) {
    final completer = Completer<T>();
    
    final onResolve = js.allowInterop((dynamic result) {
      completer.complete(result as T);
    });
    
    final onReject = js.allowInterop((dynamic error) {
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
      final jsObject = js.JsObject(js.context['Object']);
      dartObject.forEach((key, value) {
        jsObject[key.toString()] = jsify(value, customJsify);
      });
      return jsObject;
    }
    
    // Convert Dart List to JS array
    if (dartObject is List) {
      final jsArray = js.JsObject(js.context['Array']);
      for (var i = 0; i < dartObject.length; i++) {
        jsArray[i] = jsify(dartObject[i], customJsify);
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
    if (jsObject is js.JsArray || (jsObject is js.JsObject && _hasArrayProperties(jsObject))) {
      final length = jsObject['length'] as int;
      final result = <dynamic>[];
      for (var i = 0; i < length; i++) {
        result.add(dartify(jsObject[i]));
      }
      return result;
    }
    
    // Handle JS objects
    if (jsObject is js.JsObject) {
      final keys = _getObjectKeys(jsObject);
      final result = <String, dynamic>{};
      for (var key in keys) {
        result[key] = dartify(jsObject[key]);
      }
      return result;
    }
    
    // Default case
    return jsObject;
  }
  
  /// Checks if a JS object has array-like properties
  static bool _hasArrayProperties(js.JsObject obj) {
    return obj['length'] != null && obj['push'] != null;
  }
  
  /// Gets the keys of a JS object
  static List<String> _getObjectKeys(js.JsObject jsObject) {
    final keysObj = js.context['Object'].callMethod('keys', [jsObject]);
    final List<String> keys = [];
    
    final length = keysObj['length'] as int;
    for (var i = 0; i < length; i++) {
      keys.add(keysObj[i] as String);
    }
    
    return keys;
  }
  
  // Private constructor to prevent instantiation
  FirebaseJsUtils._();
}

// Add top-level extension methods to make utilities globally accessible
/// Extension that adds utility methods to the js.JsObject class
extension JsObjectUtils on dynamic {
  /// Handle a JavaScript Promise, converting it to a Dart Future
  Future<T> handleThenable<T>() {
    return FirebaseJsUtils.handleThenable<T>(this);
  }
}

/// Extension for methods needed throughout the Firebase web implementation
extension FirebaseCoreUtils on dynamic {
  /// Converts a JS object to a Dart object
  static dynamic dartify(dynamic jsObject) {
    return FirebaseJsUtils.dartify(jsObject);
  }
  
  /// Converts a Dart object to a JS object
  static dynamic jsify(Object? dartObject, [dynamic Function(dynamic)? customJsify]) {
    return FirebaseJsUtils.jsify(dartObject, customJsify);
  }
}
