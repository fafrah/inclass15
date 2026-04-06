import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class ItemForm extends StatefulWidget {
  final FirestoreService service;
  final Item? item;
  const ItemForm({super.key, required this.service, this.item});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item != null ? widget.item!.name : '',
    );
    _quantityController = TextEditingController(
      text: widget.item != null ? widget.item!.quantity.toString() : '',
    );
    _priceController = TextEditingController(
      text: widget.item != null ? widget.item!.price.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final quantity = int.parse(_quantityController.text.trim());
    final price = double.parse(_priceController.text.trim());

    final item = Item(
      id: widget.item?.id ?? '',
      name: name,
      quantity: quantity,
      price: price,
    );

    try {
      if (widget.item == null) {
        await widget.service.addItem(item);
      } else {
        await widget.service.updateItem(item);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a name' : null,
            ),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter quantity';
                if (int.tryParse(value) == null) return 'Enter valid number';
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter price';
                if (double.tryParse(value) == null) return 'Enter valid price';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submitForm, child: const Text('Save')),
      ],
    );
  }
}
