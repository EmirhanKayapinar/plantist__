import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plantist/constant/material_screen.dart';
import 'package:plantist/models/todo_model.dart';
import 'package:plantist/theme.dart';
import 'package:plantist/ui/home/home_controller.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return MaterialScreen(
        title: Text(
          "Plantist",
          style: const ThemeTextStyles().titleMedium,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Obx(
              () => ListView.builder(
                  itemCount:
                      controller.groupedTodos.value?.entries.toList().length,
                  itemBuilder: (context, index) {
                    var entry =
                        controller.groupedTodos.value?.entries.toList()[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            entry?.key ?? "",
                            style: const ThemeTextStyles()
                                .bodyMedium
                                .copyWith(color: Colors.grey.shade700),
                          ),
                        ),
                        Column(
                          children: (entry?.value ?? []).map((todo) {
                            return _buildListItem(
                              context: context,
                              iconColor: _getPriorityColor(todo.priority ?? 0),
                              todo: todo,
                              title: todo.title.toString(),
                              date: DateFormat('dd.MM-yyyy')
                                  .format(DateTime.parse(todo.dueDate ?? "")),
                              time:
                                  "${DateTime.parse(todo.dueDate ?? "").hour.toString().padLeft(2, '0')}:${DateTime.parse(todo.dueDate ?? "").minute.toString().padLeft(2, '0')}",
                              subtitle: todo.note,
                              attachmentText:
                                  ((todo.urlList ?? []).isNotEmpty ||
                                          todo.urlList != null)
                                      ? '${todo.urlList?.length} Attachments'
                                      : "",
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }),
            )),
            themeSpaceHeight4,
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Divider(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            themeSpaceHeight8,
            SizedBox(
              width: Get.width,
              height: 60,
              child: ElevatedButton.icon(
                  onPressed: () {
                    // controller.createUser(name: "EMKA");
                    controller.showFullModalBottomSheet(context);

                    // controller.readDataFromFirestore();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.black),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      )),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    "New Reminder",
                    style: const ThemeTextStyles()
                        .bodyLarge
                        .copyWith(color: Colors.white),
                  )),
            ),
          ],
        ));
  }

  Widget _buildListItem(
      {required Color iconColor,
      required TodoModel todo,
      required String title,
      required String date,
      required String time,
      String? subtitle,
      required String attachmentText,
      required BuildContext context}) {
    return Dismissible(
      key: Key(todo.id.toString()),
      background: Container(
        color: Colors.grey,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.edit, color: Colors.white, size: 30),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showConfirmDialog(context, 'Delete this todo?',
              'Are you sure you want to delete this todo?');
        } else {
          controller.selectedDate.value = todo.dueDate.toString();

          if (todo.priority == 0) {
            controller.selectedPriority.value = "None";
          } else if (todo.priority == 1) {
            controller.selectedPriority.value = "Low";
          } else if (todo.priority == 2) {
            controller.selectedPriority.value = "Medium";
          } else if (todo.priority == 3) {
            controller.selectedPriority.value = "High";
          }

          controller.selectedPriority.value = todo.priority.toString();
          controller.model?.dueDate = todo.dueDate.toString();
          controller.model?.category = todo.category;
          controller.model?.note = todo.note;
          controller.model?.title = todo.title;
          controller.model?.tags = todo.tags;
          controller.model?.priority = todo.priority;
          controller.noteController.text = todo.note.toString();
          controller.titleController.text = todo.title.toString();
          controller.finalTime.value = DateTime.parse(todo.dueDate ?? "");
          controller.showFullModalBottomSheet(context,
              id: todo.id, isEdit: true);
          return false;
        }
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          EasyLoading.show();
          await controller.deleteTodo(todo.id.toString());
          EasyLoading.dismiss();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                // İkon
                // Padding(
                //   padding: const EdgeInsets.only(right: 8.0),
                //   child: Icon(Icons.circle, color: iconColor, size: 12.0),
                // ),
                Container(
                  width: 25,
                  height: 25,
                  // color: iconColor,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: iconColor,
                          strokeAlign: BorderSide.strokeAlignInside),
                      color: iconColor.withOpacity(0.2),
                      shape: BoxShape.circle),
                ),
                themeSpaceWidth16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title ?? "-",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      themeSpaceHeight4,
                      if (subtitle != null)
                        Text(
                          todo.note ?? "-",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      themeSpaceHeight4,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.calendar,
                                size: 16,
                              ),
                              themeSpaceWidth4,
                              Text(
                                DateFormat('dd.MM.yyyy')
                                    .format(DateTime.parse(todo.dueDate ?? "")),
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          themeSpaceWidth8,
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.clock,
                                size: 16,
                              ),
                              themeSpaceWidth4,
                              Text(
                                "${DateTime.parse(todo.dueDate ?? "").hour}:${DateTime.parse(todo.dueDate ?? "").minute}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (attachmentText != "")
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.paperclip,
                          size: 16,
                        ),
                        onPressed: () async {
                          EasyLoading.show();
                          var urlList = await controller
                              .getMultipleImageUrls(todo.urlList ?? []);
                          EasyLoading.dismiss();

                          // ignore: use_build_context_synchronously
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.only(top: 16),
                                width: Get.width,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (var item in urlList)
                                        Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Image.network(item))
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      themeSpaceWidth4,
                      Text(
                        attachmentText,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> showConfirmDialog(
      BuildContext context, String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
