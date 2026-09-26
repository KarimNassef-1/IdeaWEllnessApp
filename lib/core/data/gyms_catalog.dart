/// A single gym branch shown in the "Gyms" gallery, with its own photos.
///
/// Branch photos are bundled as app assets under `img/branches/`. To add a new
/// branch: drop its photos in that folder (any names), then add a [Gym] entry
/// below pointing at those asset paths. No backend or schema change is needed.
class Gym {
  const Gym({
    required this.name,
    required this.location,
    required this.photos,
    this.description,
    this.comingSoon = false,
  });

  final String name;

  /// Area/city. Leave empty ('') to hide the location line (e.g. for a
  /// branch that hasn't opened yet).
  final String location;

  /// Asset paths, e.g. `img/branches/westin_1.jpg`.
  final List<String> photos;

  final String? description;

  /// Shows a "COMING SOON" badge and hides the location pin.
  final bool comingSoon;
}

/// Curated list of gym branches, in display order.
const List<Gym> gymsCatalog = <Gym>[
  Gym(
    name: 'Sheraton',
    location: 'Heliopolis, Cairo',
    photos: [
      'img/branches/sheraton_1.jpg',
      'img/branches/sheraton_2.jpg',
      'img/branches/sheraton_3.jpg',
      'img/branches/sheraton_4.jpg',
      'img/branches/sheraton_5.jpg',
    ],
  ),
  Gym(
    name: 'Westin',
    location: 'New Cairo',
    photos: [
      'img/branches/westin_1.jpg',
      'img/branches/westin_2.jpg',
      'img/branches/westin_3.jpg',
      'img/branches/westin_4.jpg',
      'img/branches/westin_5.jpg',
      'img/branches/westin_6.jpg',
    ],
  ),
  Gym(
    name: 'Gouna',
    location: 'El Gouna, Red Sea',
    photos: [
      'img/branches/gouna_1.jpg',
      'img/branches/gouna_2.jpg',
      'img/branches/gouna_3.jpg',
      'img/branches/gouna_4.jpg',
    ],
  ),
  Gym(
    name: 'Sahel',
    location: 'North Coast',
    photos: [
      'img/branches/sahel_1.jpg',
      'img/branches/sahel_2.jpg',
      'img/branches/sahel_3.jpg',
      'img/branches/sahel_4.jpg',
      'img/branches/sahel_5.jpg',
    ],
  ),
  Gym(
    name: 'Taj Sultan',
    location: '',
    comingSoon: true,
    photos: [
      'img/branches/taj_sultan_1.jpg',
    ],
  ),
];
