import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../domain/models/book_model.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';

class PostBookPage extends StatefulWidget {
  final BookModel? bookToEdit;

  const PostBookPage({super.key, this.bookToEdit});

  @override
  State<PostBookPage> createState() => _PostBookPageState();
}

class _PostBookPageState extends State<PostBookPage> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late BookCondition _selectedCondition;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      _titleController = TextEditingController(text: widget.bookToEdit!.title);
      _authorController = TextEditingController(text: widget.bookToEdit!.author);
      _selectedCondition = widget.bookToEdit!.condition;
    } else {
      _titleController = TextEditingController();
      _authorController = TextEditingController();
      _selectedCondition = BookCondition.used;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = context.read<AuthProvider>().currentUser;
        if (currentUser == null) return;

        final book = BookModel(
          id: widget.bookToEdit?.id ?? '',
          title: _titleController.text,
          author: _authorController.text,
          condition: _selectedCondition,
          coverImageUrl: widget.bookToEdit?.coverImageUrl,
          userId: currentUser.id,
          userName: currentUser.displayName ?? 'Unknown',
          createdAt: widget.bookToEdit?.createdAt ?? DateTime.now(),
        );

        if (widget.bookToEdit != null) {
          await context.read<BookProvider>().updateBook(widget.bookToEdit!.id, book);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book updated successfully!')),
          );
        } else {
          await context.read<BookProvider>().createBook(book);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book posted successfully!')),
          );
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookToEdit != null ? 'Edit Book' : 'Post a Book'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book Title
              Text(
                'Book Title',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter book title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Author
              Text(
                'Author',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  hintText: 'Enter author name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Author is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Swap For
              Text(
                'Swap For',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'What book do you want in exchange?',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              // Condition
              Text(
                'Condition',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: BookCondition.values.map((condition) {
                  final isSelected = _selectedCondition == condition;
                  final conditionName = condition.toString().split('.').last;
                  return FilterChip(
                    label: Text(conditionName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCondition = condition);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.accentColor : AppTheme.primaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.accentColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              // Post Button
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.bookToEdit != null ? 'Update Book' : 'Post',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
