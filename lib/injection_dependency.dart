import 'package:get_it/get_it.dart';
import 'package:poc_metamask/modal.dart';

abstract class InjectionDependency {
  static void setup() {
    GetIt.I.registerSingleton(Modal());
  }
}
