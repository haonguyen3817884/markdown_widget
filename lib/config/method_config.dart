class MethodConfig {
  MethodConfig._internal();

  static MethodConfig? _methodConfig;

  factory MethodConfig({Function()? methodInput}) {
    _methodConfig ??= MethodConfig._internal();

    _methodConfig!.customerMethod =
        methodInput ?? _methodConfig!.customerMethod;

    return _methodConfig!;
  }

  Function()? customerMethod;
}
