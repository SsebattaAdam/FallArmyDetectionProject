import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../auth/authservices.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class ExpertInsightsPage extends StatefulWidget {
  const ExpertInsightsPage({Key? key}) : super(key: key);

  @override
  State<ExpertInsightsPage> createState() => _ExpertInsightsPageState();
}

class _ExpertInsightsPageState extends State<ExpertInsightsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  Map<String, bool> _downloadingFiles = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await _authService.signInAnonymously();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to connect to service: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Expert Insights'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Expert Insights'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _initializeAuth();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Insights'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('expertDocuments')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading documents: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No documents available yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for expert insights',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final fileName = data['fileName'] ?? 'Untitled';
              final fileUrl = data['fileUrl'];
              final fileSize = data['fileSize'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _viewDocument(fileUrl, fileName, docId),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getFileIcon(fileName),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? 'Untitled Document',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['description'] ?? 'No description',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  'Uploaded: ${_formatDate(data['createdAt'])}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          _downloadingFiles[docId] == true
                              ? const CircularProgressIndicator()
                              : Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _viewDocument(fileUrl, fileName, docId),
                                icon: const Icon(Icons.visibility, color: Colors.white),
                                label: const Text('View', style: TextStyle(fontSize: 12, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _downloadDocument(fileUrl, fileName, docId),
                                icon: const Icon(Icons.download,color: Colors.white, ),
                                label: const Text('Download', style: TextStyle(fontSize: 12, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getFileIcon(String fileName) {
    IconData iconData;
    Color iconColor;

    if (fileName.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      iconData = Icons.description;
      iconColor = Colors.blue;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      iconData = Icons.table_chart;
      iconColor = Colors.green;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      iconData = Icons.slideshow;
      iconColor = Colors.orange;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        size: 32,
        color: iconColor,
      ),
    );
  }

  String _formatFileSize(dynamic size) {
    if (size == null) return 'Unknown size';

    final int fileSize = size is int ? size : int.tryParse(size.toString()) ?? 0;

    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('MMM d, yyyy').format(date);
    }

    return 'Unknown date';
  }

  Future<void> _viewDocument(String? fileUrl, String? fileName, String docId) async {
    if (fileUrl == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document not available')),
      );
      return;
    }

    setState(() {
      _downloadingFiles[docId] = true;
    });

    try {
      // Get the document directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Check if file already exists
      bool fileExists = await file.exists();

      // Download file if it doesn't exist
      if (!fileExists) {
        await _storage.refFromURL(fileUrl).writeToFile(file);
      }

      // Open document viewer based on file type
      if (fileName.toLowerCase().endsWith('.pdf')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(
              filePath: filePath,
              fileName: fileName,
            ),
          ),
        );
      } else if (fileName.toLowerCase().endsWith('.doc') ||
          fileName.toLowerCase().endsWith('.docx') ||
          fileName.toLowerCase().endsWith('.xls') ||
          fileName.toLowerCase().endsWith('.xlsx') ||
          fileName.toLowerCase().endsWith('.ppt') ||
          fileName.toLowerCase().endsWith('.pptx')) {
        // For other document types, use a web view or specialized viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenericDocumentViewer(
              fileUrl: fileUrl,
              fileName: fileName,
            ),
          ),
        );
      } else {
        // For unsupported file types, try to open with system viewer
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception("Could not open file: ${result.message}");
        }
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _downloadingFiles[docId] = false;
      });
    }
  }

  Future<void> _downloadDocument(String? fileUrl, String? fileName, String docId) async {
    if (fileUrl == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document not available')),
      );
      return;
    }

    setState(() {
      _downloadingFiles[docId] = true;
    });

    try {
      // Get the document directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Download file
      await _storage.refFromURL(fileUrl).writeToFile(file);

      // Open the file
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        throw Exception("Could not open file: ${result.message}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded: $fileName'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _downloadingFiles[docId] = false;
      });
    }
  }
}

// PDF Viewer Page
class PDFViewerPage extends StatelessWidget {
  final String filePath;
  final String fileName;

  const PDFViewerPage({
    Key? key,
    required this.filePath,
    required this.fileName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(fileName),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                // Implement sharing functionality if needed
              },
            ),
          ],
        ),
      body: SfPdfViewer.file(
        File(filePath),
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        pageLayoutMode: PdfPageLayoutMode.continuous,
      ),
    );
  }
}

// Generic Document Viewer for other file types
class GenericDocumentViewer extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const GenericDocumentViewer({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<GenericDocumentViewer> createState() => _GenericDocumentViewerState();
}

class _GenericDocumentViewerState extends State<GenericDocumentViewer> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initViewer();
  }

  Future<void> _initViewer() async {
    try {
      // This is a placeholder for initialization logic
      // In a real implementation, you might need to prepare the document
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load document: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              // Implement direct download functionality if needed
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading document..."),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initViewer();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Determine which viewer to use based on file extension
    final fileExtension = widget.fileName.split('.').last.toLowerCase();

    if (fileExtension == 'pdf') {
      return SfPdfViewer.network(
        widget.fileUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        pageLayoutMode: PdfPageLayoutMode.continuous,
      );
    } else if (fileExtension == 'doc' || fileExtension == 'docx') {
      // For Word documents, we'll show a message that direct viewing isn't supported
      // but offer options to download or open externally
      return _buildUnsupportedFormatView("Word");
    } else if (fileExtension == 'xls' || fileExtension == 'xlsx') {
      // For Excel documents
      return _buildUnsupportedFormatView("Excel");
    } else if (fileExtension == 'ppt' || fileExtension == 'pptx') {
      // For PowerPoint documents
      return _buildUnsupportedFormatView("PowerPoint");
    } else {
      // For other document types
      return _buildUnsupportedFormatView("This");
    }
  }

  Widget _buildUnsupportedFormatView(String documentType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForFileType(widget.fileName),
              size: 72,
              color: _getColorForFileType(widget.fileName),
            ),
            const SizedBox(height: 24),
            Text(
              "$documentType document preview is not available in the app",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "You can download the file to view it with compatible apps on your device.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _downloadAndOpenFile,
              icon: const Icon(Icons.download),
              label: const Text("Download & Open"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFileType(String fileName) {
    if (fileName.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icons.description;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Icons.table_chart;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return Icons.slideshow;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Color _getColorForFileType(String fileName) {
    if (fileName.endsWith('.pdf')) {
      return Colors.red;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Colors.blue;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Colors.green;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Future<void> _downloadAndOpenFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the document directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.fileName}';
      final file = File(filePath);

      // Check if file already exists
      bool fileExists = await file.exists();

      // Download file if it doesn't exist
      if (!fileExists) {
        // Get reference to the file in Firebase Storage
        final ref = FirebaseStorage.instance.refFromURL(widget.fileUrl);

        // Download to local file
        await ref.writeToFile(file);
      }

      // Open the file with system viewer
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        throw Exception("Could not open file: ${result.message}");
      }

      // Return to previous screen after opening
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: $e";
      });
    }
  }
}

