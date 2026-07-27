import 'package:flutter/material.dart';

void main() {
  runApp(const HomeDirectApp());
}

// ===========================================================================
// APP ROOT + THEME
// ===========================================================================
const kSeed = Color(0xFF0E7C66); // brand teal-green

class HomeDirectApp extends StatelessWidget {
  const HomeDirectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeDirect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kSeed),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        fontFamily: 'Roboto',
      ),
      home: const MainShell(),
    );
  }
}

// ===========================================================================
// MOCK DATA
// ===========================================================================
class Property {
  final String id;
  final String title;
  final String area;
  final int price; // RWF / month
  final String type; // Apartment, House, Studio, Room
  final int beds;
  final int baths;
  final double rating;
  final int reviews;
  final List<String> images;
  final List<String> amenities;
  final String description;
  final String ownerName;
  final bool ownerVerified;
  final double ownerRating;
  bool isFavorite;

  Property({
    required this.id,
    required this.title,
    required this.area,
    required this.price,
    required this.type,
    required this.beds,
    required this.baths,
    required this.rating,
    required this.reviews,
    required this.images,
    required this.amenities,
    required this.description,
    required this.ownerName,
    required this.ownerVerified,
    required this.ownerRating,
    this.isFavorite = false,
  });
}

String _img(String seed) => 'https://picsum.photos/seed/$seed/900/700';

// Shared in-memory list. Toggling isFavorite here reflects across all screens.
final List<Property> mockProperties = [
  Property(
    id: 'p1',
    title: 'Sunny 2-Bedroom Apartment',
    area: 'Kacyiru, Kigali',
    price: 450000,
    type: 'Apartment',
    beds: 2,
    baths: 1,
    rating: 4.8,
    reviews: 32,
    images: [_img('hd-kacyiru1'), _img('hd-kacyiru2'), _img('hd-kacyiru3')],
    amenities: ['Wifi', 'Parking', 'Water', 'Security', 'Furnished'],
    description:
        'Bright, airy apartment minutes from the city centre. Newly painted, '
        'tiled floors, and a private balcony overlooking the hills. Reliable '
        'water and 24/7 compound security.',
    ownerName: 'Aline U.',
    ownerVerified: true,
    ownerRating: 4.9,
  ),
  Property(
    id: 'p2',
    title: 'Modern Studio Near ALU',
    area: 'Nyarutarama, Kigali',
    price: 220000,
    type: 'Studio',
    beds: 1,
    baths: 1,
    rating: 4.6,
    reviews: 18,
    images: [_img('hd-studio1'), _img('hd-studio2')],
    amenities: ['Wifi', 'Water', 'Furnished', 'Security'],
    description:
        'Compact, fully-furnished studio perfect for students or young '
        'professionals. Walking distance to shops and transport.',
    ownerName: 'Jean-Paul M.',
    ownerVerified: true,
    ownerRating: 4.7,
  ),
  Property(
    id: 'p3',
    title: 'Spacious Family House',
    area: 'Kibagabaga, Kigali',
    price: 1200000,
    type: 'House',
    beds: 4,
    baths: 3,
    rating: 4.9,
    reviews: 47,
    images: [_img('hd-house1'), _img('hd-house2'), _img('hd-house3')],
    amenities: ['Parking', 'Water', 'Security', 'Generator', 'Pet-friendly'],
    description:
        'Standalone family home with a large garden and gated parking for two '
        'cars. Backup generator and borehole water. Quiet, family neighbourhood.',
    ownerName: 'Grace K.',
    ownerVerified: true,
    ownerRating: 5.0,
  ),
  Property(
    id: 'p4',
    title: 'Cozy 1-Bedroom Flat',
    area: 'Remera, Kigali',
    price: 300000,
    type: 'Apartment',
    beds: 1,
    baths: 1,
    rating: 4.4,
    reviews: 12,
    images: [_img('hd-flat1'), _img('hd-flat2')],
    amenities: ['Wifi', 'Water', 'Security'],
    description:
        'Well-kept one-bedroom flat close to the bus terminal and markets. '
        'Great value for a central location.',
    ownerName: 'Eric N.',
    ownerVerified: false,
    ownerRating: 4.3,
  ),
  Property(
    id: 'p5',
    title: 'Furnished Room in Shared House',
    area: 'Nyamirambo, Kigali',
    price: 150000,
    type: 'Room',
    beds: 1,
    baths: 1,
    rating: 4.5,
    reviews: 9,
    images: [_img('hd-room1'), _img('hd-room2')],
    amenities: ['Wifi', 'Water', 'Furnished'],
    description:
        'Private furnished room in a friendly shared house. Shared kitchen and '
        'lounge. Bills included. Ideal for a single tenant.',
    ownerName: 'Sandrine B.',
    ownerVerified: true,
    ownerRating: 4.6,
  ),
  Property(
    id: 'p6',
    title: 'Executive 3-Bedroom Apartment',
    area: 'Kimihurura, Kigali',
    price: 900000,
    type: 'Apartment',
    beds: 3,
    baths: 2,
    rating: 4.9,
    reviews: 55,
    images: [_img('hd-exec1'), _img('hd-exec2'), _img('hd-exec3')],
    amenities: ['Wifi', 'Parking', 'Water', 'Security', 'AC', 'Generator'],
    description:
        'Upscale apartment in a prime location with lift access, AC, and secure '
        'underground parking. Finished to a high standard throughout.',
    ownerName: 'Patrick H.',
    ownerVerified: true,
    ownerRating: 4.8,
  ),
];

// RWF with thousands separators, no external packages.
String rwf(int amount) {
  final s = amount.toString();
  final b = StringBuffer('RWF ');
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

IconData amenityIcon(String a) {
  switch (a.toLowerCase()) {
    case 'wifi':
      return Icons.wifi_rounded;
    case 'parking':
      return Icons.local_parking_rounded;
    case 'furnished':
      return Icons.chair_rounded;
    case 'water':
      return Icons.water_drop_rounded;
    case 'security':
      return Icons.shield_rounded;
    case 'ac':
      return Icons.ac_unit_rounded;
    case 'generator':
      return Icons.bolt_rounded;
    case 'pet-friendly':
      return Icons.pets_rounded;
    default:
      return Icons.check_circle_outline_rounded;
  }
}

// ===========================================================================
// NETWORK IMAGE with graceful loading + fallback
// ===========================================================================
class NetImage extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  const NetImage(this.url, {super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (c, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          width: width,
          color: const Color(0xFFE6ECEA),
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (c, e, s) => Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E7C66), Color(0xFF19A88B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.home_rounded, color: Colors.white54, size: 44),
        ),
      ),
    );
  }
}

// ===========================================================================
// MAIN SHELL — bottom navigation
// ===========================================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = const [
      ExploreScreen(),
      SavedScreen(),
      BookingsScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Saved'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Bookings'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

// ===========================================================================
// EXPLORE
// ===========================================================================
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _filter = 'All';
  final _filters = const ['All', 'Apartment', 'House', 'Studio', 'Room'];

  List<Property> get _visible => _filter == 'All'
      ? mockProperties
      : mockProperties.where((p) => p.type == _filter).toList();

  Future<void> _openDetail(Property p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)),
    );
    if (mounted) setState(() {}); // refresh hearts after returning
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final featured = mockProperties.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hi there 👋',
                                  style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 18, color: cs.primary),
                                  const SizedBox(width: 4),
                                  Text('Kigali, Rwanda',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurface)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: cs.primary.withOpacity(0.12),
                          child: Icon(Icons.person, color: cs.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8E6)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: cs.onSurfaceVariant),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search area, e.g. Kacyiru',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter chips
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final f = _filters[i];
                          final sel = f == _filter;
                          return GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: sel ? cs.primary : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: sel
                                        ? cs.primary
                                        : const Color(0xFFE2E8E6)),
                              ),
                              child: Text(f,
                                  style: TextStyle(
                                      color:
                                          sel ? Colors.white : cs.onSurface,
                                      fontWeight: FontWeight.w600)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    _sectionTitle('Featured near you'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // Featured horizontal row
            SliverToBoxAdapter(
              child: SizedBox(
                height: 232,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => _FeaturedCard(
                    property: featured[i],
                    onTap: () => _openDetail(featured[i]),
                    onFav: () =>
                        setState(() => featured[i].isFavorite =
                            !featured[i].isFavorite),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _sectionTitle(
                    _filter == 'All' ? 'All homes' : '$_filter homes'),
              ),
            ),
            // Vertical list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final p = _visible[i];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, 0, 20, i == _visible.length - 1 ? 24 : 16),
                    child: _PropertyCard(
                      property: p,
                      onTap: () => _openDetail(p),
                      onFav: () =>
                          setState(() => p.isFavorite = !p.isFavorite),
                    ),
                  );
                },
                childCount: _visible.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800));
}

// --- Featured card (horizontal) ---
class _FeaturedCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFav;
  const _FeaturedCard(
      {required this.property, required this.onTap, required this.onFav});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: NetImage(property.images.first,
                      height: 140, width: 260),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _FavButton(
                      active: property.isFavorite, onTap: onFav),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: _pill(property.type, cs),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star,
                          size: 15, color: Colors.amber.shade600),
                      const SizedBox(width: 3),
                      Text('${property.rating}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(property.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(rwf(property.price),
                      style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Property card (full width) ---
class _PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFav;
  const _PropertyCard(
      {required this.property, required this.onTap, required this.onFav});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: NetImage(property.images.first, height: 190),
                ),
                Positioned(
                    top: 12,
                    right: 12,
                    child: _FavButton(
                        active: property.isFavorite, onTap: onFav)),
                Positioned(
                    top: 12, left: 12, child: _pill(property.type, cs)),
                if (property.ownerVerified)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              size: 14, color: cs.primary),
                          const SizedBox(width: 4),
                          const Text('Verified owner',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ),
                      Icon(Icons.star,
                          size: 17, color: Colors.amber.shade600),
                      const SizedBox(width: 3),
                      Text('${property.rating}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 15, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(property.area,
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _spec(Icons.bed_outlined, '${property.beds} bed'),
                      const SizedBox(width: 16),
                      _spec(Icons.bathtub_outlined,
                          '${property.baths} bath'),
                      const Spacer(),
                      Text(rwf(property.price),
                          style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      Text('/mo',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spec(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 17, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      );
}

Widget _pill(String text, ColorScheme cs) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );

class _FavButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FavButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1), blurRadius: 6),
          ],
        ),
        child: Icon(
          active ? Icons.favorite : Icons.favorite_border,
          size: 19,
          color: active ? Colors.redAccent : Colors.black54,
        ),
      ),
    );
  }
}

// ===========================================================================
// PROPERTY DETAIL
// ===========================================================================
class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});
  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image carousel header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
            actions: [
              _circleBtn(
                p.isFavorite ? Icons.favorite : Icons.favorite_border,
                () => setState(() => p.isFavorite = !p.isFavorite),
                color: p.isFavorite ? Colors.redAccent : Colors.black87,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    children:
                        p.images.map((u) => NetImage(u)).toList(),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        p.images.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(i == _page ? 1 : 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _pill(p.type, cs),
                      const Spacer(),
                      Icon(Icons.star,
                          size: 18, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text('${p.rating}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      Text('  (${p.reviews} reviews)',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(p.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 17, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(p.area,
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Quick specs
                  Row(
                    children: [
                      _specBox(Icons.bed_outlined, '${p.beds}', 'Bedrooms',
                          cs),
                      const SizedBox(width: 12),
                      _specBox(Icons.bathtub_outlined, '${p.baths}',
                          'Bathrooms', cs),
                      const SizedBox(width: 12),
                      _specBox(Icons.square_foot, p.type, 'Type', cs),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About this home',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(p.description,
                      style: TextStyle(
                          height: 1.5,
                          fontSize: 14.5,
                          color: cs.onSurface.withOpacity(0.8))),
                  const SizedBox(height: 24),
                  const Text('What this place offers',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: p.amenities
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFE2E8E6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(amenityIcon(a),
                                      size: 18, color: cs.primary),
                                  const SizedBox(width: 8),
                                  Text(a,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Hosted by',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  _OwnerCard(property: p),
                  const SizedBox(height: 24),
                  const Text('Reviews',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const _ReviewTile(
                      name: 'Claudine',
                      text:
                          'Exactly as described. The owner replied fast and '
                          'move-in was smooth.',
                      stars: 5),
                  const _ReviewTile(
                      name: 'Yves',
                      text:
                          'Good location and fair price. Water and security '
                          'were reliable throughout my stay.',
                      stars: 4),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky bottom booking bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rwf(p.price),
                      style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  Text('per month',
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12)),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _showRequestSheet(context, p),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(180, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Request to book',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color? color}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: color ?? Colors.black87, size: 20),
          ),
        ),
      );

  Widget _specBox(
          IconData icon, String value, String label, ColorScheme cs) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8E6)),
          ),
          child: Column(
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(height: 6),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              Text(label,
                  style: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ),
      );
}

void _showRequestSheet(BuildContext context, Property p) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Request to book',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface)),
            const SizedBox(height: 6),
            Text(p.title,
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            const Text('Move-in date',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _fakeField(Icons.calendar_today_outlined, 'Select a date'),
            const SizedBox(height: 16),
            const Text('Message to owner',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _fakeField(Icons.chat_bubble_outline,
                'Hi, I\'m interested in your place...'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Request sent to ${p.ownerName} (mock)')),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Send request',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _fakeField(IconData icon, String hint) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8E6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(hint, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );

class _OwnerCard extends StatelessWidget {
  final Property property;
  const _OwnerCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8E6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: cs.primary.withOpacity(0.12),
            child: Icon(Icons.person, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(property.ownerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(width: 6),
                    if (property.ownerVerified)
                      Icon(Icons.verified,
                          size: 16, color: cs.primary),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.star,
                        size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    Text('${property.ownerRating} • Usually replies fast',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat — coming soon')),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Message'),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final String text;
  final int stars;
  const _ReviewTile(
      {required this.name, required this.text, required this.stars});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Text(name[0],
                    style: TextStyle(
                        color: cs.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(Icons.star,
                        size: 14,
                        color: i < stars
                            ? Colors.amber.shade600
                            : Colors.grey.shade300)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(text,
              style: TextStyle(
                  height: 1.4,
                  fontSize: 13.5,
                  color: cs.onSurface.withOpacity(0.75))),
        ],
      ),
    );
  }
}

// ===========================================================================
// SAVED
// ===========================================================================
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final saved = mockProperties.where((p) => p.isFavorite).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved homes',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
      ),
      body: saved.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 56, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No saved homes yet',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Tap the heart on any listing to save it',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: saved.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _PropertyCard(
                property: saved[i],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PropertyDetailScreen(property: saved[i]))),
                onFav: () {},
              ),
            ),
    );
  }
}

// ===========================================================================
// BOOKINGS
// ===========================================================================
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My bookings',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _bookingCard(context, mockProperties[0], 'Active',
              const Color(0xFF0E7C66)),
          const SizedBox(height: 16),
          _bookingCard(context, mockProperties[5], 'Requested',
              Colors.orange.shade700),
        ],
      ),
    );
  }

  Widget _bookingCard(
      BuildContext context, Property p, String status, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: NetImage(p.images.first, height: 76, width: 76),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 3),
                Text(p.area,
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PROFILE
// ===========================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(Icons.person, size: 36, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Syhff',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 6),
                      Icon(Icons.verified, size: 18, color: cs.primary),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Verified tenant',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _tile(context, Icons.person_outline, 'Edit profile'),
          _tile(context, Icons.receipt_long_outlined, 'My bookings'),
          _tile(context, Icons.payments_outlined, 'Payment methods'),
          _tile(context, Icons.notifications_outlined, 'Notifications'),
          _tile(context, Icons.help_outline, 'Help & support'),
          const SizedBox(height: 8),
          _tile(context, Icons.logout, 'Log out', danger: true),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label,
      {bool danger = false}) {
    final color = danger ? Colors.red : Colors.black87;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: color)),
        trailing: danger
            ? null
            : const Icon(Icons.chevron_right, color: Colors.grey),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label — coming soon')),
        ),
      ),
    );
  }
}
