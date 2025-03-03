class FileCompressionPlus {
  static registerPlugin() {
    // Register the plugin
    console.log('FileCompressionPlus web plugin registered');
  }

  static setCompressImageHandler(handler) {
    window.compressImageHandler = handler;
  }

  static setCompressPdfHandler(handler) {
    window.compressPdfHandler = handler;
  }

  static async compressImage(data) {
    if (!window.compressImageHandler) {
      console.error('Image compression handler not registered');
      return null;
    }
    return await window.compressImageHandler(data);
  }

  static async compressPdf(data) {
    if (!window.compressPdfHandler) {
      console.error('PDF compression handler not registered');
      return null;
    }
    return await window.compressPdfHandler(data);
  }
}

// Register the plugin class
window.FileCompressionPlus = FileCompressionPlus;