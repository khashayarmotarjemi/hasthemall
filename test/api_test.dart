import 'package:hasthemall/main.dart';

void main() async {
  Api api = Api();

  await api.run();
  await api.createNames();

}