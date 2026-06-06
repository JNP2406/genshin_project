import 'package:flutter/material.dart';

class MoraNotifier extends ValueNotifier<double> {
  MoraNotifier() : super(0);

  static final MoraNotifier instance = MoraNotifier();

  void update(double newMora) {
    value = newMora;
    notifyListeners();
  }
}