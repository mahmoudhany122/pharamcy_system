import 'package:flutter/cupertino.dart';

import '../data/models/onboarding_item_model.dart';

Widget buildBoardingItem({required BoardingModel model})=> Column(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Expanded(
      child: Image.asset(model.image),
    ),
    const SizedBox(height: 30),
    Text(
      model.title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 15),
    Text(
      model.body,
      style: const TextStyle(fontSize: 16),
    ),
  ],
);