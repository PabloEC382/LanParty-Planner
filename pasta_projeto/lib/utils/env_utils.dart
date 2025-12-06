/// Utility functions for environment variable handling

/// Parse .env file content and return a map of key-value pairs
Map<String, String> parseEnvContent(String content) {
  final map = <String, String>{};
  
  for (final line in content.split('\n')) {
    final trimmed = line.trim();
    
    // Skip empty lines and comments
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    
    // Parse KEY=VALUE
    if (trimmed.contains('=')) {
      final parts = trimmed.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.skip(1).join('=').trim();
        
        // Remove quotes if present
        final cleanValue = _removeQuotes(value);
        map[key] = cleanValue;
      }
    }
  }
  
  return map;
}

/// Mask sensitive values for safe logging
String maskSecret(String? value) {
  if (value == null || value.isEmpty) {
    return '<not-set>';
  }
  
  if (value.length <= 4) {
    return '***';
  }
  
  // Show first 4 and last 4 characters
  final first = value.substring(0, 4);
  final last = value.substring(value.length - 4);
  final masked = '*' * (value.length - 8);
  
  return '$first$masked$last';
}

/// Remove surrounding quotes from a string
String _removeQuotes(String value) {
  if ((value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
