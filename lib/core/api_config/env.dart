enum Environment {dev, prod}

class Env{
  static Environment current = Environment.dev;

  static String get baseUrl{
    switch(current) {
      case Environment.dev:
      return "http://192.168.1.23:3000/api";
      case Environment.prod:
      return "";
    }
  }
}