import '../../domain/entities/gym_session.dart';
import '../../domain/repositories/content_repository.dart';
import '../../core/utils/showcase_ai_images.dart';

class ContentRepositoryImpl implements ContentRepository {
  String _img(String prompt, int seed) {
    return showcaseAiImage(prompt, seed: seed);
  }

  static const List<GymSession> _heliopolisSchedule = [
    GymSession(
      id: 'sun-0830-pilates',
      day: 'Sunday',
      name: 'Pilates',
      timeStart: '8:30 AM',
      timeEnd: '9:30 AM',
      trainer: 'C. Maria Bokhara',
      type: 'Included',
      category: 'Included',
    ),
    GymSession(
      id: 'sun-0915-functional-push',
      day: 'Sunday',
      name: 'Functional Bodybuilding (Push Day)',
      timeStart: '9:15 AM',
      timeEnd: '10:15 AM',
      trainer: 'C. Marc',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'sun-1800-kickboxing',
      day: 'Sunday',
      name: 'Kickboxing',
      timeStart: '6:00 PM',
      timeEnd: '7:00 PM',
      trainer: 'C. Samara',
      type: 'Included',
      category: 'Included',
    ),
    GymSession(
      id: 'sun-1900-core-fusion',
      day: 'Sunday',
      name: 'Core Strength Pilates Fusion',
      timeStart: '7:00 PM',
      timeEnd: '8:00 PM',
      trainer: 'C. Dina Salah',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'sun-2000-cellulite',
      day: 'Sunday',
      name: 'Cellulite Control (Ladies Only)',
      timeStart: '8:00 PM',
      timeEnd: '9:00 PM',
      trainer: 'C. Marina',
      type: 'Paid Program',
      category: 'Paid Program',
    ),
    GymSession(
      id: 'mon-0915-pilates',
      day: 'Monday',
      name: 'Pilates',
      timeStart: '9:15 AM',
      timeEnd: '10:15 AM',
      trainer: 'C. Diana',
      type: 'Included',
      category: 'Included',
    ),
    GymSession(
      id: 'mon-1900-functional',
      day: 'Monday',
      name: 'Functional Training (Full Body)',
      timeStart: '7:00 PM',
      timeEnd: '8:00 PM',
      trainer: 'C. Mohey',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'mon-2000-pilates',
      day: 'Monday',
      name: 'Pilates',
      timeStart: '8:00 PM',
      timeEnd: '9:00 PM',
      trainer: 'C. Maria Bushara',
      type: 'Included',
      category: 'Included',
    ),
    GymSession(
      id: 'tue-0730-functional',
      day: 'Tuesday',
      name: 'Functional Training (Full Body)',
      timeStart: '7:30 AM',
      timeEnd: '8:30 AM',
      trainer: 'C. Rafael',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'tue-0830-pilates',
      day: 'Tuesday',
      name: 'Pilates',
      timeStart: '8:30 AM',
      timeEnd: '9:30 AM',
      trainer: 'C. Maria Bokhara',
      type: 'Included',
      category: 'Included',
    ),
    GymSession(
      id: 'tue-0915-coreabs',
      day: 'Tuesday',
      name: 'Core & Abs',
      timeStart: '9:15 AM',
      timeEnd: '10:15 AM',
      trainer: 'C. Marc',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'tue-1800-kickboxing',
      day: 'Tuesday',
      name: 'Kickboxing',
      timeStart: '6:00 PM',
      timeEnd: '7:00 PM',
      trainer: 'C. Samara',
      type: 'Included',
      category: 'Included',
    ),
    GymSession(
      id: 'tue-1900-cellulite',
      day: 'Tuesday',
      name: 'Cellulite Control (Ladies Only)',
      timeStart: '7:00 PM',
      timeEnd: '8:00 PM',
      trainer: 'C. Marina',
      type: 'Paid Program',
      category: 'Paid Program',
    ),
    GymSession(
      id: 'tue-2000-functional',
      day: 'Tuesday',
      name: 'Functional Training (Full Body)',
      timeStart: '8:00 PM',
      timeEnd: '9:00 PM',
      trainer: 'C. Rafael',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'wed-0830-fbb-legs',
      day: 'Wednesday',
      name: 'Functional Bodybuilding (Leg Day)',
      timeStart: '8:30 AM',
      timeEnd: '9:30 AM',
      trainer: 'C. Mohey',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'wed-1900-functional',
      day: 'Wednesday',
      name: 'Functional Training (Full Body)',
      timeStart: '7:00 PM',
      timeEnd: '8:00 PM',
      trainer: 'C. Marc',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'wed-2000-pilates',
      day: 'Wednesday',
      name: 'Pilates',
      timeStart: '8:00 PM',
      timeEnd: '9:00 PM',
      trainer: 'C. Maria Bushara',
      type: 'Included',
      category: 'Included',
    ),
    GymSession(
      id: 'thu-0730-functional',
      day: 'Thursday',
      name: 'Functional Training (Full Body)',
      timeStart: '7:30 AM',
      timeEnd: '8:30 AM',
      trainer: 'C. Rafael',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'thu-0915-fbb-full',
      day: 'Thursday',
      name: 'Functional Bodybuilding (Full Day)',
      timeStart: '9:15 AM',
      timeEnd: '10:15 AM',
      trainer: 'C. Marc',
      type: 'Standard',
      category: 'Standard',
    ),
    GymSession(
      id: 'thu-1900-cellulite',
      day: 'Thursday',
      name: 'Cellulite Control (Ladies Only)',
      timeStart: '7:00 PM',
      timeEnd: '8:00 PM',
      trainer: 'C. Marina',
      type: 'Member Access',
      category: 'Member Access',
    ),
    GymSession(
      id: 'sat-1100-weekend',
      day: 'Saturday',
      name: 'Weekend Workout',
      timeStart: '11:00 AM',
      timeEnd: '12:00 PM',
      trainer: 'All Team',
      type: 'Special',
      category: 'Special',
    ),
  ];

  @override
  List<String> freshDrops() {
    return [
      _img('premium gym interior cinematic lighting modern wellness club', 11),
      _img('group functional training session in luxury gym dynamic action', 12),
      _img('female athlete doing pilates reformer premium studio aesthetic', 13),
    ];
  }

  @override
  List<String> partnerHighlights() {
    return [
      _img('sportswear brand collaboration photoshoot gym lifestyle', 21),
      _img('healthy protein snack and supplement showcase premium branding', 22),
      _img('wellness spa recovery partner campaign high end look', 23),
    ];
  }

  @override
  List<Map<String, String>> specialOffers() {
    return [
      {
        'title': '30% on Personal Training',
        'subtitle': 'For premium members this week',
        'image': _img('personal trainer coaching athlete gym intense scene', 31),
      },
      {
        'title': 'Nutrition Assessment',
        'subtitle': 'Unlock your personalized plan',
        'image': _img('nutrition consultation healthy meal planning wellness clinic', 32),
      },
      {
        'title': 'Team Arena Pass',
        'subtitle': 'Bring a friend this weekend',
        'image': _img('friends training together in arena fitness space', 33),
      },
    ];
  }

  @override
  List<GymSession> upcomingSessions() {
    return _heliopolisSchedule.take(8).toList();
  }

  @override
  List<GymSession> allClassesSchedule() {
    return _heliopolisSchedule;
  }

  @override
  List<Map<String, String>> partners() {
    return [
      {'name': 'Hydra Fuel', 'image': _img('hydration drink brand product photography', 41)},
      {'name': 'Alpha Wear', 'image': _img('athletic apparel minimal campaign portrait', 42)},
      {'name': 'Nutri Co.', 'image': _img('nutrition brand premium food supplements flatlay', 43)},
      {'name': 'Pulse Labs', 'image': _img('fitness tech wearable device branding', 44)},
    ];
  }

  @override
  List<Map<String, String>> fitnessTips() {
    return [
      {
        'title': '5-Minute Mobility Reset',
        'subtitle': 'Warm up smarter before heavy sessions.',
        'image': _img('athlete stretching mobility routine in gym warm up', 51),
      },
      {
        'title': 'Hydration Timing Guide',
        'subtitle': 'Boost your performance with simple timing.',
        'image': _img('runner drinking water hydration performance concept', 52),
      },
      {
        'title': 'High-Protein Easy Bowl',
        'subtitle': 'Recipe for a balanced post-workout meal.',
        'image': _img('healthy protein bowl recipe food photography premium', 53),
      },
    ];
  }
}
