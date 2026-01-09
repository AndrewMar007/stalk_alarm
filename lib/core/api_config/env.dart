enum Environment {dev, prod}

class Env{
  static Environment current = Environment.dev;

  static String get baseUrl{
    switch(current) {
      case Environment.dev:
      return "https://stalk-alarm-proxy-api.onrender.com/api";
      case Environment.prod:
      return "";
    }
  }
}