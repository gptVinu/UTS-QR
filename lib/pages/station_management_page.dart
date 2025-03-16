import 'dart:io';
import 'package:flutter/material.dart';
import '../data/database.dart';
import 'package:image_picker/image_picker.dart';

class StationManagementPage extends StatefulWidget {
  const StationManagementPage({Key? key}) : super(key: key);

  @override
  State<StationManagementPage> createState() => _StationManagementPageState();
}

class _StationManagementPageState extends State<StationManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredStations = [];
  String? _selectedLine;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredStations = List.from(StationDatabase.allStations);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterStations(_searchController.text);
  }

  void _filterStations(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      List<Map<String, dynamic>> tempList =
          List.from(StationDatabase.allStations);

      // Apply line filter if selected
      if (_selectedLine != null) {
        tempList = tempList
            .where((station) =>
                station['line'].toString().contains(_selectedLine!))
            .toList();
      }

      // Apply search filter if there's a query
      if (query.isNotEmpty) {
        tempList = tempList
            .where((station) =>
                station['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                station['code']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }

      filteredStations = tempList;
    });
  }

  void _selectLine(String? line) {
    setState(() {
      // Toggle line selection
      _selectedLine = _selectedLine == line ? null : line;
      _filterStations(_searchController.text);
    });
  }

  void _showDeleteConfirmation(Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Station'),
          content: Text('Are you sure you want to remove ${station['name']}?'),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // In a real app, you would remove from database
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${station['name']} removed')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddStationForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddStationForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainLines = StationDatabase.trainLines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Line filter boxes
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: trainLines.length,
              itemBuilder: (context, index) {
                final line = trainLines[index];
                final isSelected =
                    _selectedLine == line['name'].toString().split(' ')[0];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () =>
                        _selectLine(line['name'].toString().split(' ')[0]),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? line['color'].withOpacity(0.9)
                            : line['color'].withOpacity(0.2),
                        border: Border.all(
                          color: line['color'],
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            line['icon'] as IconData,
                            color: isSelected ? Colors.white : line['color'],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            line['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : line['color'],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Station count indicator
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedLine != null
                      ? '$_selectedLine Line Stations'
                      : 'All Stations',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${filteredStations.length} stations',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Stations list
          Expanded(
            child: filteredStations.isEmpty
                ? const Center(
                    child: Text('No stations found'),
                  )
                : ListView.builder(
                    itemCount: filteredStations.length,
                    itemBuilder: (context, index) {
                      final station = filteredStations[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Station header with name and actions
                                Row(
                                  children: [
                                    // Station code avatar
                                    CircleAvatar(
                                      backgroundColor:
                                          station['color'].withOpacity(0.2),
                                      foregroundColor: station['color'],
                                      radius: 20,
                                      child: Text(
                                        station['code'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Station name - expanded to take available space
                                    Expanded(
                                      child: Text(
                                        station['name'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        // Removed maxLines and ellipsis constraints
                                      ),
                                    ),

                                    // Action buttons in their own row
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Favorite button
                                        _buildActionButton(
                                          icon: station['isPopular'] as bool
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: station['isPopular'] as bool
                                              ? Colors.amber
                                              : Colors.grey,
                                          tooltip: station['isPopular'] as bool
                                              ? 'Remove from popular'
                                              : 'Mark as popular',
                                          onTap: () {
                                            final isPopular =
                                                !(station['isPopular'] as bool);
                                            setState(() {
                                              station['isPopular'] = isPopular;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(isPopular
                                                    ? '${station['name']} marked as popular'
                                                    : '${station['name']} removed from popular'),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                        ),

                                        // Delete button
                                        _buildActionButton(
                                          icon: Icons.delete_outline,
                                          color: Colors.red,
                                          tooltip: 'Delete station',
                                          onTap: () =>
                                              _showDeleteConfirmation(station),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Divider between header and details
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.0),
                                  child: Divider(height: 1),
                                ),

                                // Station details row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.train,
                                      size: 16,
                                      color: station['color'],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        station['line'] as String,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStationForm,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to create action buttons with consistent styling
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class AddStationForm extends StatefulWidget {
  const AddStationForm({Key? key}) : super(key: key);

  @override
  State<AddStationForm> createState() => _AddStationFormState();
}

class _AddStationFormState extends State<AddStationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String _selectedLine = 'Western';
  bool _isPopular = false;
  File? _qrImageFile;
  final _picker = ImagePicker();
  bool _isFormValid = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to validate form in real-time
    _nameController.addListener(_validateForm);
    _codeController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _codeController.removeListener(_validateForm);
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    // Check if the form is valid
    final nameValid = _nameController.text.trim().isNotEmpty;
    final codeValid = _isValidCode(_codeController.text);
    setState(() {
      _isFormValid = nameValid && codeValid;
    });
  }

  bool _isValidCode(String code) {
    // Code must be 1-4 uppercase letters
    final regex = RegExp(r'^[A-Z]{1,4}$');
    return regex.hasMatch(code);
  }

  Color _getLineColor() {
    switch (_selectedLine.split('/')[0]) {
      case 'Western':
        return Colors.blue;
      case 'Central':
        return Colors.red;
      case 'Harbour':
        return Colors.green;
      case 'Trans-Harbour':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );

      // Only update state if the component is still mounted
      if (mounted) {
        setState(() {
          if (pickedFile != null) {
            _qrImageFile = File(pickedFile.path);
          }
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with back button
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add New Station',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Station Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Station Name*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter station name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Station Code with capitalization and validation
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Station Code* (1-4 capital letters)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.code),
                      hintText: 'e.g., CSMT, DR, BND',
                      errorText: _codeController.text.isNotEmpty &&
                              !_isValidCode(_codeController.text)
                          ? 'Use 1-4 capital letters only'
                          : null,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter station code';
                      }
                      if (!_isValidCode(value)) {
                        return 'Code must be 1-4 capital letters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Force uppercase for station code
                      if (value != value.toUpperCase()) {
                        _codeController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: _codeController.selection,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Line Selection
                  DropdownButtonFormField<String>(
                    value: _selectedLine,
                    decoration: const InputDecoration(
                      labelText: 'Train Line*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.train),
                    ),
                    items: [
                      'Western',
                      'Central',
                      'Harbour',
                      'Trans-Harbour',
                      'Western/Central',
                      'Central/Harbour'
                    ]
                        .map((line) => DropdownMenuItem<String>(
                              value: line,
                              child: Text(line),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLine = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Is Popular Station
                  CheckboxListTile(
                    title: const Text('Popular Station'),
                    value: _isPopular,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _isPopular = value;
                        });
                      }
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),

                  // QR Code Image Upload
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Station QR Code:'),
                        const SizedBox(height: 8),
                        Center(
                          child: GestureDetector(
                            onTap: _isUploading ? null : _pickImage,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _isUploading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _qrImageFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.file(
                                            _qrImageFile!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.error_outline,
                                                      size: 40,
                                                      color: Colors.red),
                                                  SizedBox(height: 8),
                                                  Text('Error loading image',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ],
                                              );
                                            },
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.qr_code, size: 40),
                                            SizedBox(height: 8),
                                            Text('Tap to upload QR'),
                                          ],
                                        ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: _isUploading ? null : _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: Text(_isUploading
                                ? 'Uploading...'
                                : 'Select from gallery'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit Button - disabled until form is valid
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid && !_isUploading
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                // In a real app, this would save to database
                                final newStation = {
                                  'name': _nameController.text,
                                  'line': _selectedLine,
                                  'code': _codeController.text,
                                  'color': _getLineColor(),
                                  'isPopular': _isPopular,
                                  'qr': _qrImageFile?.path,
                                };

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Added station: ${newStation['name']}')),
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Fade button when disabled
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        disabledForegroundColor: Colors.grey.withOpacity(0.5),
                      ),
                      child: Text(
                        _isUploading ? 'Please wait...' : 'Add Station',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
