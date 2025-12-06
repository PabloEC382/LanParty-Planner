/// Real implementation of platform_environment using dart:io
/// This is only imported on platforms that support dart:io (native, not web)

import 'dart:io' show Platform;

final Map<String, String> platformEnvironment = Platform.environment;
