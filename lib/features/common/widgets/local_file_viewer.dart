// Widget to display locally stored files
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../services/local_storage_service.dart';

class LocalFileViewer extends StatelessWidget {
  final String? filePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LocalFileViewer({
    super.key,
    required this.filePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (filePath == null || filePath!.isEmpty) {
      return _buildPlaceholder();
    }

    return FutureBuilder<File?>(
      future: LocalStorageService().getFile(filePath!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildErrorWidget();
        }

        final file = snapshot.data!;
        final extension = file.path.split('.').last.toLowerCase();

        // Check if it's an image
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          );
        }

        // For non-image files (PDF, documents), show a file icon
        return _buildFileIcon(extension);
      },
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.image,
            color: Colors.grey,
            size: 40,
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: const Icon(
            Icons.error,
            color: Colors.red,
            size: 40,
          ),
        );
  }

  Widget _buildFileIcon(String extension) {
    IconData iconData;
    Color iconColor;

    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Container(
      width: width ?? 100,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: iconColor,
            size: 40,
          ),
          const SizedBox(height: 4),
          Text(
            extension.toUpperCase(),
            style: TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget to display a list of local files
class LocalFilesList extends StatelessWidget {
  final List<String> filePaths;
  final Function(String)? onFileSelected;
  final bool showFileName;

  const LocalFilesList({
    super.key,
    required this.filePaths,
    this.onFileSelected,
    this.showFileName = true,
  });

  @override
  Widget build(BuildContext context) {
    if (filePaths.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد ملفات',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filePaths.length,
      itemBuilder: (context, index) {
        final filePath = filePaths[index];
        final fileName = filePath.split('/').last;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: LocalFileViewer(
              filePath: filePath,
              width: 50,
              height: 50,
            ),
            title: showFileName ? Text(fileName) : null,
            subtitle: FutureBuilder<int>(
              future: LocalStorageService().getFileSize(filePath),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(_formatBytes(snapshot.data!));
                }
                return const Text('جاري التحميل...');
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showFileDialog(context, filePath),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareFile(filePath),
                ),
              ],
            ),
            onTap: onFileSelected != null ? () => onFileSelected!(filePath) : null,
          ),
        );
      },
    );
  }

  void _showFileDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalFileViewer(
                filePath: filePath,
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 16),
              Text(
                filePath.split('/').last,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareFile(String filePath) {
    // Implement file sharing functionality
    // This would require additional packages like share_plus
    print('Sharing file: $filePath');
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
