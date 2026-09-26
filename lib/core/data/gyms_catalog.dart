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
  });

  final String name;
  final String location;

  /// Asset paths, e.g. `img/branches/westin_1.jpg`.
  final List<String> photos;

  final String? description;
}

/// Curated list of gym branches, in display order.
const List<Gym> gymsCatalog = <Gym>[
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
];
