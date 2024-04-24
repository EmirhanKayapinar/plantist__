import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plantist/models/todo_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../theme.dart';

class HomeController extends GetxController {
  RxBool isEmailValid = false.obs;
  RxBool isPasswordValid = false.obs;
  RxBool showPassword = false.obs;
  RxBool isDetail = false.obs;
  RxBool switchDate = false.obs;
  RxBool switchTime = false.obs;
  RxString selectedPriority = "None".obs;
  RxString selectedTime = "".obs;
  RxString selectedDate = "".obs;
  RxString attachUrl = "".obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  Rxn<TimeOfDay?> selectedHour = Rxn<TimeOfDay?>();
  Rxn<DateTime?> finalTime = Rxn<DateTime?>();
  TimeOfDay today = TimeOfDay.now();
  TodoModel? model;
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  Rxn<List<Future<void>>> uploadTasks = Rxn<List<Future<void>>>();
  Rxn<List<String>> pickedImages = Rxn<List<String>>();
  var calendarFormat = CalendarFormat.month.obs;
  var focusDay = DateTime.now().obs;
  var selectDay = DateTime.now().obs;
  User? user = FirebaseAuth.instance.currentUser;
  Future createUser() async {
    final user = FirebaseFirestore.instance.collection("TODO");
    model?.dueDate ??= DateTime.now().toString();
    model?.priority ??= 0;
    await user.add(model!.toJson());
  }

  Rxn<List<TodoModel>> todos = Rxn<List<TodoModel>>();
  Rxn<Map<String, List<TodoModel>>> groupedTodos =
      Rxn<Map<String, List<TodoModel>>>();
  @override
  void onInit() {
    model = TodoModel(
        uid: user?.uid,
        category: null,
        dueDate: null,
        note: null,
        priority: null,
        tags: null,
        title: null);
    groupedTodos.bindStream(getUserSortedTodos());

    calendarFormat.value = CalendarFormat.month;
    focusDay.value = DateTime.now();
    selectDay.value = focusDay.value;
    super.onInit();
  }

  updateTodo(String docId) {
    FirebaseFirestore.instance
        .collection('TODO')
        .doc(docId)
        .update(model!.toJson())
        .then((_) {
      debugPrint('Document successfully updated!');
    }).catchError((error) {
      debugPrint('Error updating document: $error');
    });
  }

  deleteTodo(String docId) {
    FirebaseFirestore.instance.collection('TODO').doc(docId).delete().then((_) {
      debugPrint('Document successfully deleted!');
    }).catchError((error) {
      debugPrint('Error removing document: $error');
    });
  }

  Stream<Map<String, List<TodoModel>>> getUserSortedTodos() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('TODO')
          .where('uid', isEqualTo: user.uid)
          .orderBy('priority', descending: true)
          .orderBy('due_date')
          .snapshots()
          .map((QuerySnapshot query) {
        todos.value = query.docs.map((doc) {
          Map<String, dynamic> tempModel = doc.data() as Map<String, dynamic>;
          tempModel.addAll({"id": doc.id});
          return TodoModel.fromJson(tempModel);
        }).toList();

        Map<String, List<TodoModel>> groupedTodos = {};
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

        for (TodoModel todo in todos.value ?? []) {
          String dateKey;
          if (DateTime(
                  DateTime.parse(todo.dueDate ?? "").year,
                  DateTime.parse(todo.dueDate ?? "").month,
                  DateTime.parse(todo.dueDate ?? "").day)
              .isAtSameMomentAs(today)) {
            dateKey = 'Today';
          } else if (DateTime(
                  DateTime.parse(todo.dueDate ?? "").year,
                  DateTime.parse(todo.dueDate ?? "").month,
                  DateTime.parse(todo.dueDate ?? "").day)
              .isAtSameMomentAs(tomorrow)) {
            dateKey = 'Tomorrow';
          } else {
            dateKey = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(todo.dueDate ?? ""));
          }

          if (!groupedTodos.containsKey(dateKey)) {
            groupedTodos[dateKey] = [];
          }
          groupedTodos[dateKey]?.add(todo);
        }
        this.groupedTodos.refresh();
        return groupedTodos;
      });
    } else {
      return const Stream.empty();
    }
  }

  Future<void> readDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('deneme').get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        debugPrint('Doküman verisi: $data');
      }
    } catch (e) {
      debugPrint('Verileri alırken bir hata oluştu: $e');
    }
  }

  getModal(Widget child, String? title,
      {Widget? topWidget,
      bool dragSc = false,
      bool? isDraggable,
      void Function()? ontap,
      StateSetter? setter,
      bool? isFullscreen,
      double? initialSize = 0.5,
      bool isWeb = false}) {
    getBottomSheetSnap(
        initialSize: initialSize ?? 0.5,
        child: child,
        isFullscreen: isFullscreen ?? false,
        topWidget: topWidget,
        ontap: ontap);
  }

  void showFullModalBottomSheet(BuildContext context,
      {bool isEdit = false, String? id}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Obx(
          () => DraggableScrollableSheet(
            snap: true,
            controller: draggableScrollableController,
            snapSizes: const [0.30, 0.5, 0.7, 0.95],
            minChildSize: 0.25,
            initialChildSize: !isDetail.value ? 0.75 : 0.95,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: const ThemeTextStyles()
                                  .bodyMedium
                                  .copyWith(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                              isEdit
                                  ? (isDetail.value
                                      ? "Edit Details"
                                      : "Edit Reminder")
                                  : (isDetail.value
                                      ? "Details"
                                      : "New Reminder"),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          TextButton(
                            onPressed: () {
                              if (isDetail.value) {
                                if (selectedHour.value != null) {
                                  finalTime.value = DateTime(
                                    selectDay.value.year,
                                    selectDay.value.month,
                                    selectDay.value.day,
                                    selectedHour.value!.hour,
                                    selectedHour.value!.minute,
                                  );
                                  model?.dueDate = finalTime.toString();
                                } else {
                                  finalTime.value = DateTime(
                                    selectDay.value.year,
                                    selectDay.value.month,
                                    selectDay.value.day,
                                    today.hour,
                                    today.minute,
                                  );
                                  model?.dueDate = finalTime.toString();
                                }
                                isDetail.value = !isDetail.value;
                              } else {
                                EasyLoading.show();
                                isEdit ? updateTodo(id ?? "") : createUser();
                                EasyLoading.dismiss();
                              }
                            },
                            child: Text(
                              isEdit
                                  ? isDetail.value
                                      ? "Save Details"
                                      : "Save"
                                  : isDetail.value
                                      ? "Add Details"
                                      : "Add",
                              style: const ThemeTextStyles().bodyLarge.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => !isDetail.value
                            ? Expanded(
                                child: ListView(
                                  controller: scrollController,
                                  children: [
                                    TextField(
                                      cursorColor: Colors.black,
                                      autofocus: true,
                                      controller: titleController,
                                      decoration: InputDecoration(
                                        hintText: 'Title',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade500),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade500),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        model?.title = value;
                                      },
                                    ),
                                    TextField(
                                      cursorColor: Colors.black,
                                      minLines: 5,
                                      maxLines: 10,
                                      controller: noteController,
                                      decoration: const InputDecoration(
                                        hintText: 'Notes',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        model?.note = value;
                                      },
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2,
                                              color: Colors.grey.shade500),
                                          color: Colors.grey.withOpacity(.1),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      child: Obx(
                                        () => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('Details'),
                                          subtitle: finalTime.value != null
                                              ? Text(
                                                  "${finalTime.value?.day}/${finalTime.value?.month}/${finalTime.value?.year} - ${finalTime.value?.hour}: ${finalTime.value?.minute} - Priority: ${selectedPriority.value} - Attach : ${uploadTasks.value?.length} ")
                                              : null,
                                          trailing:
                                              const Icon(Icons.chevron_right),
                                          onTap: () {
                                            isDetail.value = !isDetail.value;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    children: <Widget>[
                                      SwitchListTile(
                                        activeColor: Colors.white,
                                        activeTrackColor: Colors.green,
                                        inactiveTrackColor:
                                            Colors.grey.shade300,
                                        inactiveThumbColor: Colors.white,
                                        trackOutlineColor:
                                            const MaterialStatePropertyAll(
                                                Colors.transparent),
                                        title: const Text('Date'),
                                        value: switchDate.value,
                                        onChanged: (bool value) {
                                          switchDate.value = value;
                                          if (value == false) {
                                            selectedDate.value = "";
                                            model?.dueDate = null;
                                          }
                                        },
                                        secondary: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.red,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.calendar_month,
                                              color: Colors.white,
                                              size: 20,
                                            )),
                                      ),
                                      Obx(
                                        () => switchDate.value
                                            ? TableCalendar(
                                                firstDay:
                                                    DateTime.utc(2010, 10, 16),
                                                lastDay:
                                                    DateTime.utc(2030, 3, 14),
                                                focusedDay: focusDay.value,
                                                calendarFormat:
                                                    calendarFormat.value,
                                                selectedDayPredicate: (day) {
                                                  return isSameDay(
                                                      selectDay.value, day);
                                                },
                                                onDaySelected:
                                                    (selectedDay, focusedDay) {
                                                  selectedDate.value =
                                                      selectedDay.toString();

                                                  if (!isSameDay(
                                                      selectDay.value,
                                                      selectedDay)) {
                                                    selectDay.value =
                                                        selectedDay;
                                                    focusDay.value = focusedDay;
                                                  }
                                                },
                                                onPageChanged: (focusedDay) {
                                                  focusDay.value = focusedDay;
                                                },
                                              )
                                            : const SizedBox(),
                                      ),
                                      SwitchListTile(
                                        activeColor: Colors.white,
                                        activeTrackColor: Colors.green,
                                        inactiveTrackColor:
                                            Colors.grey.shade300,
                                        inactiveThumbColor: Colors.white,
                                        trackOutlineColor:
                                            const MaterialStatePropertyAll(
                                                Colors.transparent),
                                        title: const Text('Time'),
                                        value: switchTime.value,
                                        onChanged: (bool value) {
                                          switchTime.value = value;
                                          if (switchTime.value == true) {
                                            selectTime(context);
                                          } else {
                                            selectedHour.value = null;
                                          }
                                        },
                                        secondary: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.blue,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.access_time,
                                              size: 20,
                                              color: Colors.white,
                                            )),
                                      ),
                                      Obx(
                                        () => (selectedDate.value != "")
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "Due Date: ${selectDay.value.day}/${selectDay.value.month}/${selectDay.value.year} "),
                                                  selectedHour.value == null
                                                      ? Text(
                                                          "${today.hour}:${today.minute}")
                                                      : Text(
                                                          "${selectedHour.value?.hour}:${selectedHour.value?.minute}"),
                                                ],
                                              )
                                            : const SizedBox(),
                                      ),
                                      themeSpaceHeight16,
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 4,
                                            top: 4,
                                            bottom: 4),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.grey.shade500),
                                            color: Colors.grey.withOpacity(.1),
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Priority",
                                              style: const ThemeTextStyles()
                                                  .bodyMedium
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  selectedPriority.value,
                                                  style: const ThemeTextStyles()
                                                      .bodyMedium,
                                                ),
                                                PopupMenuButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  onSelected: (value) {
                                                    model?.priority = value;
                                                    if (value == 0) {
                                                      selectedPriority.value =
                                                          "None";
                                                    } else if (value == 1) {
                                                      selectedPriority.value =
                                                          "Low";
                                                    } else if (value == 2) {
                                                      selectedPriority.value =
                                                          "Medium";
                                                    } else if (value == 3) {
                                                      selectedPriority.value =
                                                          "High";
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 0,
                                                      child: Text('None'),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 1,
                                                      child: Text('Low'),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 2,
                                                      child: Text('Medium'),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 3,
                                                      child: Text('High'),
                                                    ),
                                                  ],
                                                  icon: const Icon(
                                                      Icons.arrow_forward_ios),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      themeSpaceHeight16,
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 4,
                                            top: 4,
                                            bottom: 4),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.grey.shade500),
                                            color: Colors.grey.withOpacity(.1),
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Attach a file",
                                              style: const ThemeTextStyles()
                                                  .bodyMedium
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Obx(() => Text(
                                                      (uploadTasks.value ?? [])
                                                              .isEmpty
                                                          ? "None"
                                                          : "${uploadTasks.value?.length}",
                                                      style:
                                                          const ThemeTextStyles()
                                                              .bodyMedium,
                                                    )),
                                                IconButton(
                                                    onPressed: () async {
                                                      EasyLoading.show();
                                                      List<XFile>? files =
                                                          await pickImages();
                                                      await uploadFiles(files);
                                                      EasyLoading.dismiss();
                                                    },
                                                    icon: const Icon(
                                                        FontAwesomeIcons
                                                            .paperclip))
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((value) {
      switchDate.value = false;
      switchTime.value = false;
      isDetail.value = false;
      selectedDate.value = "";
      selectedPriority.value = "";
      model?.dueDate = null;
      model?.category = null;
      model?.note = null;
      model?.title = null;
      model?.tags = null;
      model?.priority = null;
      noteController.text = "";
      titleController.text = "";
      finalTime.value = null;
      uploadTasks.value = [];
      pickedImages.value = [];
    });
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(file);
        uploadTask.whenComplete(() async {
          try {
            final url = await ref.getDownloadURL();
            attachUrl.value = url;
            debugPrint('Upload complete: $url');
          } catch (e) {
            debugPrint('Error occurred while getting download URL: $e');
          }
        });
      } catch (e) {
        debugPrint('Error occurred while uploading to Firebase: $e');
      }
    } else {
      debugPrint('No image selected.');
    }
  }

  Future<List<XFile>?> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedFiles = await picker.pickMultiImage();
    return selectedFiles;
  }

  Future<void> uploadFiles(List<XFile>? files) async {
    uploadTasks.value = [];
    pickedImages.value = [];
    if (files == null || files.isEmpty) {
      debugPrint("No files selected");
      return;
    }

    var storageRef = FirebaseStorage.instance.ref();

    // List<Future<void>> uploadTasks = [];

    for (XFile file in files) {
      File localFile = File(file.path);
      String filePath =
          'images/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      var fileRef = storageRef.child(filePath);

      var uploadTask = fileRef.putFile(localFile).then((taskSnapshot) {
        debugPrint('Upload ${file.name} complete');
      }).catchError((error) {
        debugPrint('Error uploading ${file.name}: $error');
      });

      uploadTasks.value?.add(uploadTask);
      pickedImages.value?.add(filePath);
    }

    if ((uploadTasks.value ?? []).isNotEmpty) {
      await Future.wait(uploadTasks.value ?? []);
      debugPrint('All uploads complete.');
      model?.urlList = pickedImages.value;
    }
  }

  Future<List<dynamic>> getMultipleImageUrls(List<dynamic> filePaths) async {
    List<String> downloadUrls = [];

    for (String path in filePaths) {
      String downloadUrl =
          await FirebaseStorage.instance.ref(path).getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  Future<void> selectTime(BuildContext context) async {
    selectedHour.value = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    // final DateTime finalTime = DateTime(
    //   selectDay.value.year,
    //   selectDay.value.month,
    //   selectDay.value.day,
    //   selectedHour.value!.hour,
    //   selectedHour.value!.minute,
    // );
  }

  getBottomSheetSnap(
      {Widget child = const SizedBox(),
      bool isFullscreen = false,
      Widget? topWidget,
      void Function()? ontap,
      double initialSize = 0.5}) {
    Get.bottomSheet(
      GestureDetector(
        onTap: ontap,
        child: Container(
          //padding: EdgeInsets.only(bottom:50),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: isFullscreen ? 0.9 : initialSize,
            snap: true,
            snapSizes: const [0.30, 0.5, 0.7, 0.95],
            minChildSize: 0.25,
            builder: (BuildContext context, ScrollController scrollController) {
              return SizedBox(
                child: Column(
                  children: [
                    themeSpaceHeight16,
                    Container(
                      height: 5,
                      width: 30,
                      decoration: BoxDecoration(
                          color: Get.theme.colorScheme.outline,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Text("aaaa"),
                    ),
                    themeSpaceHeight16,
                    if (topWidget != null)
                      Container(
                          color: Get.theme.colorScheme.background,
                          child: topWidget),
                    Expanded(
                        child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                child,
                                const SizedBox(
                                  height: 50,
                                )
                              ],
                            )))
                  ],
                ),
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      enableDrag: true,
    );
  }
}
