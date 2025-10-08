// lib/providers/loading_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingCubit extends Cubit<bool> {
  LoadingCubit() : super(false);

  void setLoading(bool isLoading) {
    emit(isLoading);
  }

  void startLoading() {
    emit(true);
  }

  void stopLoading() {
    emit(false);
  }
}