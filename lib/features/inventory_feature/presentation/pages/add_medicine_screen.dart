import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain_layer/entities/medicine_entity.dart';
import '../cubit/medicine_cubit.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _shelfLocationController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));
  String? _category; // جعلناه Nullable لضمان الاختيار الصحيح
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تعيين قيمة افتراضية موجودة فعلياً في القائمة لتجنب خطأ الـ Dropdown
    _category = MedicineCubit.get(context).categories[1]; 
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('medicine_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
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
      appBar: AppBar(title: const Text('إضافة دواء جديد')),
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
                    image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                  ),
                  child: _image == null ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الدواء (تجاري)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _genericNameController,
                decoration: const InputDecoration(labelText: 'الاسم العلمي / المادة الفعالة', border: OutlineInputBorder()),
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
                isExpanded: true,
                items: MedicineCubit.get(context).categories
                    .where((e) => e != 'الكل')
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'القسم', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _shelfLocationController,
                decoration: const InputDecoration(labelText: 'رقم الرف', border: OutlineInputBorder()),
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
                      String? imageUrl;
                      if (_image != null) imageUrl = await _uploadImage(_image!);
                      
                      final medicine = MedicineEntity(
                        uId: FirebaseAuth.instance.currentUser!.uid,
                        name: _nameController.text,
                        genericName: _genericNameController.text,
                        category: _category!,
                        purchasePrice: double.parse(_purchasePriceController.text),
                        sellingPrice: double.parse(_sellingPriceController.text),
                        quantity: int.parse(_quantityController.text),
                        expiryDate: _expiryDate,
                        barcode: _barcodeController.text,
                        imageUrl: imageUrl,
                        shelfLocation: _shelfLocationController.text,
                      );
                      
                      MedicineCubit.get(context).addMedicine(medicine);
                      Navigator.pop(context);
                    }
                  },
                  child: _isLoading ? const CircularProgressIndicator() : const Text('حفظ الدواء'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
