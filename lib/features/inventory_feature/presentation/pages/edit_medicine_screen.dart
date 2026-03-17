import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain_layer/entities/medicine_entity.dart';
import '../cubit/medicine_cubit.dart';

class EditMedicineScreen extends StatefulWidget {
  final MedicineEntity medicine;
  const EditMedicineScreen({super.key, required this.medicine});

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _quantityController;
  late TextEditingController _barcodeController;
  late DateTime _expiryDate;
  late String _category;
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _purchasePriceController = TextEditingController(text: widget.medicine.purchasePrice.toString());
    _sellingPriceController = TextEditingController(text: widget.medicine.sellingPrice.toString());
    _quantityController = TextEditingController(text: widget.medicine.quantity.toString());
    _barcodeController = TextEditingController(text: widget.medicine.barcode);
    _expiryDate = widget.medicine.expiryDate;
    _category = widget.medicine.category;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _scanBarcode() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              _barcodeController.text = barcodes.first.rawValue ?? "";
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل بيانات الدواء')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    image: _image != null 
                      ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) 
                      : (widget.medicine.imageUrl != null ? DecorationImage(image: NetworkImage(widget.medicine.imageUrl!), fit: BoxFit.cover) : null),
                  ),
                  child: (_image == null && widget.medicine.imageUrl == null) 
                    ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey) 
                    : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الدواء', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(labelText: 'الباركود', border: OutlineInputBorder()),
                    ),
                  ),
                  IconButton(onPressed: _scanBarcode, icon: const Icon(Icons.qr_code_scanner, color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _category,
                items: MedicineCubit.get(context).categories.where((e) => e != 'الكل').map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'القسم', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'سعر الشراء', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'سعر البيع', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الكمية المتاحة', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              ListTile(
                title: Text("تاريخ الانتهاء: ${_expiryDate.year}-${_expiryDate.month}-${_expiryDate.day}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: _expiryDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
                  if (date != null) setState(() => _expiryDate = date);
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      
                      final updatedMedicine = MedicineEntity(
                        id: widget.medicine.id,
                        uId: widget.medicine.uId,
                        name: _nameController.text,
                        category: _category,
                        purchasePrice: double.parse(_purchasePriceController.text),
                        sellingPrice: double.parse(_sellingPriceController.text),
                        quantity: int.parse(_quantityController.text),
                        expiryDate: _expiryDate,
                        barcode: _barcodeController.text,
                        imageUrl: widget.medicine.imageUrl, // في التعديل سنبقي الصورة القديمة حالياً للسرعة
                      );
                      
                      MedicineCubit.get(context).updateMedicine(updatedMedicine);
                      Navigator.pop(context);
                    }
                  },
                  child: _isLoading ? const CircularProgressIndicator() : const Text('تعديل الدواء'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
