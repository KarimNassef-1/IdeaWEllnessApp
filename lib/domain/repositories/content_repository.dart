import '../entities/gym_session.dart';

abstract class ContentRepository {
  List<String> freshDrops();
  List<String> partnerHighlights();
  List<Map<String, String>> specialOffers();
  List<GymSession> upcomingSessions();
  List<GymSession> allClassesSchedule();
  List<Map<String, String>> partners();
  List<Map<String, String>> fitnessTips();
}
