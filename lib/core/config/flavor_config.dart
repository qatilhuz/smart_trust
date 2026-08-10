enum Flavor { development, staging, production }

class FlavorConfig {
  FlavorConfig._();

  static late Flavor current;

  static String get name => current.name;
}
