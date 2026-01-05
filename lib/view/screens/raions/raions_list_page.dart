import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stalc_alarm/core/values/lists.dart';
import 'package:stalc_alarm/view/screens/raions/add_new_raion_page.dart';

class RaionsListPage extends StatefulWidget {
  const RaionsListPage({super.key});

  @override
  State<RaionsListPage> createState() => _RaionsListPageState();
}

const bottomGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 57, 33, 6),
    Color.fromARGB(255, 45, 26, 5),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.02, 0.25, 0.6, 1.0],
);

const separatedGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(255, 57, 33, 6),
    Color.fromARGB(255, 45, 26, 5),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.02, 0.5, 0.8, 1.0],
);

List<String> list = ["No oblast choose"];

class _RaionsListPageState extends State<RaionsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 20, 11, 2),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: false).push(
                CupertinoPageRoute(builder: (_) => const AddNewRaionPage()),
              );
            },
            icon: Icon(Icons.add, color: Color.fromARGB(255, 247, 135, 50)),
          ),
        ],
        title: Text(
          "Регіони",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔥 ГРАДІЄНТ ПІД APPBAR
          SizedBox(
            height: 2, // товщина лінії
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: bottomGradient),
            ),
          ),

          // КОНТЕНТ
          Expanded(
            child: LayoutBuilder(
              builder: (context, constrains) => ListView.separated(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      list[index],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 248, 165, 101),
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // TODO: логіка вибору області
                      print(
                        'Обрано: ${ListsOfAdministrativeUnits.ukraineRegions[index]}',
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 2, // товщина divider
                    //margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      gradient: separatedGradient,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
