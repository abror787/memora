class AppConfig {
  // Google Stitch MCP API Key
  // Вставьте ваш API ключ здесь
  static const String? googleApiKey = null; // TODO: Добавить ключ

  // OpenCode Config
  static const String opencodeSchema = 'https://opencode.ai/config.json';

  // Stitch MCP Settings
  static const String stitchUrl = 'https://stitch.googleapis.com/mcp';
  static const bool stitchEnabled = false; // Отключено по умолчанию

  // Environment
  static const bool isProduction = false;

  // Debug mode
  static const bool debugMode = true;
}
