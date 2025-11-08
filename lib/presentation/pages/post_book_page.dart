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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title',
                  prefixIcon: const Icon(Icons.menu_book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Author is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BookCondition>(
                value: _selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  prefixIcon: const Icon(Icons.info),
                ),
                items: BookCondition.values
                    .map((condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(condition.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCondition = value);
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(widget.bookToEdit != null ? 'Update Book' : 'Post Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
