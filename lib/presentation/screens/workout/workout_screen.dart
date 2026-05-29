import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exercise_library_tab.dart';
import 'my_plans_tab.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Exercise Library'),
            Tab(text: 'My Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          ExerciseLibraryTab(),
          MyPlansTab(),
        ],
      ),
    );
  }
}
