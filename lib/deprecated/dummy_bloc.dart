import 'package:flutter_bloc/flutter_bloc.dart';

class DummyBloc extends Bloc<DummyEvent, DummyState> {
  DummyBloc() : super(DummyInitialState()) {
    on<LoadDummyEvent>((event, emit) async {
      emit(DummyLoadedState('dummy'));
    });
  }
}

abstract class DummyEvent {}

class LoadDummyEvent extends DummyEvent {}

abstract class DummyState {}

class DummyInitialState extends DummyState {}

class DummyLoadedState extends DummyState {
  String text;
  DummyLoadedState(this.text);
}
