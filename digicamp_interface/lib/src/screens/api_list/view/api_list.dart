import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class ApiListPage extends StatefulWidget {
  const ApiListPage({super.key});

  @override
  State<ApiListPage> createState() => _ApiListPageState();
}

class _ApiListPageState extends State<ApiListPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locator<ApiClient>().getApiList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.data!.isSuccess) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.data!.length,
            itemBuilder: (context, index) {
              final api = snapshot.data!.data![index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: api.method == 'GET'
                        ? Colors.green
                        : api.method == 'POST'
                            ? Colors.blue
                            : api.method == 'PUT'
                                ? Colors.orange
                                : api.method == 'DELETE'
                                    ? Colors.red
                                    : Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    api.method!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(api.name!),
                subtitle: Text(api.description!),
                trailing: IconButton(
                  tooltip: "Copy Url",
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: api.url!));
                  },
                ),
                onTap: () {},
              );
            },
          );
        }
      },
    );
  }
}
