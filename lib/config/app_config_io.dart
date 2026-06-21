import 'dart:io';

String ioApiBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080/api';
  }
  return 'http://localhost:8080/api';
}

String ioImageBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080/images/products';
  }
  return 'http://localhost:8080/images/products';
}
