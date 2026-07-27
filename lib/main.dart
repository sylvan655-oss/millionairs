// ===========================================================================
// HomeDirect — direct-to-owner rentals in Rwanda
// Single-file Flutter app (tenant + owner). Admin lives in a separate
// codebase: admin.html.
//
// BEFORE RUNNING: paste your Supabase URL + anon key in the CONFIG block below.
// ===========================================================================

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ======================= CONFIG SPOT — PASTE HERE ==========================
const String kSupabaseUrl = 'PASTE_YOUR_PROJECT_URL_HERE';
const String kSupabaseAnonKey = 'PASTE_YOUR_ANON_PUBLIC_KEY_HERE';

// SPOT: Google Maps — add your key here and to AndroidManifest, then the map
// card on the property page can become a real map.
const String kGoogleMapsKey = '';

// SPOT: payments aggregator (Flutterwave / Paypack). Empty = payments off.
const String kPaymentsPublicKey = '';
// ===========================================================================

bool get kBackendReady =>
    kSupabaseUrl.startsWith('https://') && kSupabaseAnonKey.length > 40;

SupabaseClient get sb => Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  if (kBackendReady) {
    await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
  }
  runApp(const HomeDirectApp());
}

// ================================ BRAND ====================================
class C {
  static const ink = Color(0xFF0B211C); // deep hill green
  static const ink2 = Color(0xFF10312A);
  static const primary = Color(0xFF12735C);
  static const mint = Color(0xFF2FD3A3);
  static const sand = Color(0xFFF3F6F4);
  static const line = Color(0xFFE2E9E5);
  static const text = Color(0xFF0E1A17);
  static const muted = Color(0xFF6B7C77);
  static const danger = Color(0xFFD14343);
  static const warn = Color(0xFFE1A32B);
}

const _gap = SizedBox(height: 16);

class HomeDirectApp extends StatelessWidget {
  const HomeDirectApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return MaterialApp(
      title: 'HomeDirect',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: C.primary,
          primary: C.primary,
          surface: Colors.white,
        ),
        textTheme: base.textTheme.apply(bodyColor: C.text, displayColor: C.text),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
              color: C.text, fontSize: 19, fontWeight: FontWeight.w700),
          iconTheme: IconThemeData(color: C.text),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: C.sand,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: C.line)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: C.primary, width: 1.6)),
          labelStyle: const TextStyle(color: C.muted),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: C.primary,
            minimumSize: const Size.fromHeight(54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      home: const SplashScreen(),
    );
  }
}

// ================================ HELPERS ==================================
void toast(BuildContext c, String msg, {bool error = false}) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? C.danger : C.ink,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}

String money(num v, [String cur = 'RWF']) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '$cur ${b.toString()}';
}

String ago(DateTime d) {
  final m = DateTime.now().difference(d).inMinutes;
  if (m < 1) return 'now';
  if (m < 60) return '${m}m';
  if (m < 1440) return '${m ~/ 60}h';
  if (m < 10080) return '${m ~/ 1440}d';
  return '${d.day}/${d.month}/${d.year}';
}

const kProvinces = ['Kigali City', 'Northern', 'Southern', 'Eastern', 'Western'];
const kDistricts = {
  'Kigali City': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
  'Northern': ['Musanze', 'Gicumbi', 'Burera', 'Rulindo', 'Gakenke'],
  'Southern': ['Huye', 'Muhanga', 'Nyanza', 'Kamonyi', 'Ruhango', 'Gisagara', 'Nyaruguru', 'Nyamagabe'],
  'Eastern': ['Rwamagana', 'Kayonza', 'Bugesera', 'Ngoma', 'Kirehe', 'Gatsibo', 'Nyagatare'],
  'Western': ['Rubavu', 'Rusizi', 'Karongi', 'Nyabihu', 'Ngororero', 'Rutsiro', 'Nyamasheke'],
};
const kAmenities = [
  'Water tank', 'Backup power', 'Parking', 'Wi-Fi ready', 'Security guard',
  'Fenced', 'Balcony', 'Garden', 'Hot water', 'Tiled floor', 'Ceiling',
  'Kitchen cabinets', 'Wardrobe', 'Servant quarter'
];
const kTypeLabels = {
  'apartment': 'Apartment',
  'house': 'House',
  'studio': 'Studio',
  'room': 'Single room',
  'commercial': 'Commercial',
};

// ================================ MODELS ===================================
class Profile {
  final String id, fullName, role;
  final String? phone, avatarUrl, bio;
  final bool isVerified, isBlocked, isAdmin;
  Profile.fromMap(Map<String, dynamic> m)
      : id = m['id'] as String,
        fullName = (m['full_name'] ?? '') as String,
        role = (m['role'] ?? 'tenant') as String,
        phone = m['phone'] as String?,
        avatarUrl = m['avatar_url'] as String?,
        bio = m['bio'] as String?,
        isVerified = (m['is_verified'] ?? false) as bool,
        isBlocked = (m['is_blocked'] ?? false) as bool,
        isAdmin = (m['is_admin'] ?? false) as bool;
  bool get isOwner => role == 'owner';
  String get initials {
    final p = fullName.trim().split(RegExp(r'\s+'));
    if (fullName.trim().isEmpty) return '?';
    return p.length == 1
        ? p.first.substring(0, 1).toUpperCase()
        : (p[0][0] + p[1][0]).toUpperCase();
  }
}

class Property {
  final String id, ownerId, title, description, type, status, currency, period;
  final String province, district, sector, addressLine;
  final num price;
  final int bedrooms, bathrooms, views;
  final int? sizeSqm;
  final bool furnished, featured;
  final double? lat, lng;
  final List<String> amenities;
  final String? coverUrl, rejectReason;
  final DateTime createdAt;
  final List<String> photos;
  final Map<String, dynamic>? owner;

  Property.fromMap(Map<String, dynamic> m)
      : id = m['id'] as String,
        ownerId = m['owner_id'] as String,
        title = (m['title'] ?? '') as String,
        description = (m['description'] ?? '') as String,
        type = (m['type'] ?? 'apartment') as String,
        status = (m['status'] ?? 'pending') as String,
        currency = (m['currency'] ?? 'RWF') as String,
        period = (m['period'] ?? 'month') as String,
        province = (m['province'] ?? '') as String,
        district = (m['district'] ?? '') as String,
        sector = (m['sector'] ?? '') as String,
        addressLine = (m['address_line'] ?? '') as String,
        price = (m['price'] ?? 0) as num,
        bedrooms = (m['bedrooms'] ?? 0) as int,
        bathrooms = (m['bathrooms'] ?? 0) as int,
        views = (m['views_count'] ?? 0) as int,
        sizeSqm = m['size_sqm'] as int?,
        furnished = (m['furnished'] ?? false) as bool,
        featured = (m['is_featured'] ?? false) as bool,
        lat = (m['latitude'] as num?)?.toDouble(),
        lng = (m['longitude'] as num?)?.toDouble(),
        amenities = ((m['amenities'] ?? []) as List).cast<String>(),
        coverUrl = m['cover_url'] as String?,
        rejectReason = m['reject_reason'] as String?,
        createdAt = DateTime.parse(m['created_at'] as String),
        photos = ((m['property_photos'] ?? []) as List)
            .map((e) => (e as Map)['url'] as String)
            .toList(),
        owner = (m['owner'] as Map?)?.cast<String, dynamic>();

  String get location =>
      [sector, district].where((e) => e.isNotEmpty).join(', ');
  List<String> get gallery {
    final g = <String>[];
    if (coverUrl != null && coverUrl!.isNotEmpty) g.add(coverUrl!);
    for (final p in photos) {
      if (!g.contains(p)) g.add(p);
    }
    return g;
  }
}

class Filters {
  String? type, district;
  int? minBeds;
  double minPrice = 0, maxPrice = 2000000;
  bool furnishedOnly = false;
  String query = '';
  bool get isActive =>
      type != null ||
      district != null ||
      minBeds != null ||
      furnishedOnly ||
      minPrice > 0 ||
      maxPrice < 2000000;
  void reset() {
    type = null; district = null; minBeds = null;
    minPrice = 0; maxPrice = 2000000; furnishedOnly = false;
  }
}

// =============================== SERVICES ==================================
class Session {
  static Profile? me;
  static Future<Profile?> load() async {
    final u = sb.auth.currentUser;
    if (u == null) return me = null;
    final row = await sb.from('profiles').select().eq('id', u.id).maybeSingle();
    if (row == null) return me = null;
    return me = Profile.fromMap(row);
  }

  static Future<void> signOut() async {
    await sb.auth.signOut();
    me = null;
  }
}

class Api {
  static const _sel =
      '*, property_photos(url, sort_order), owner:profiles!properties_owner_id_fkey(id, full_name, phone, avatar_url, is_verified)';

  static Future<List<Property>> browse(Filters f, {int limit = 30}) async {
    var q = sb.from('properties').select(_sel).eq('status', 'active');
    if (f.type != null) q = q.eq('type', f.type!);
    if (f.district != null) q = q.eq('district', f.district!);
    if (f.minBeds != null) q = q.gte('bedrooms', f.minBeds!);
    if (f.furnishedOnly) q = q.eq('furnished', true);
    if (f.minPrice > 0) q = q.gte('price', f.minPrice);
    if (f.maxPrice < 2000000) q = q.lte('price', f.maxPrice);
    if (f.query.trim().isNotEmpty) {
      final s = '%${f.query.trim()}%';
      q = q.or('title.ilike.$s,district.ilike.$s,sector.ilike.$s,address_line.ilike.$s');
    }
    final rows = await q.order('is_featured', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => Property.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Property> byId(String id) async {
    final row = await sb.from('properties').select(_sel).eq('id', id).single();
    return Property.fromMap(row);
  }

  static Future<List<Property>> mine() async {
    final rows = await sb
        .from('properties')
        .select(_sel)
        .eq('owner_id', sb.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Property.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Set<String>> favoriteIds() async {
    final rows = await sb
        .from('favorites')
        .select('property_id')
        .eq('tenant_id', sb.auth.currentUser!.id);
    return (rows as List).map((e) => e['property_id'] as String).toSet();
  }

  static Future<List<Property>> favorites() async {
    final rows = await sb
        .from('favorites')
        .select('property:properties($_sel)')
        .eq('tenant_id', sb.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return (rows as List)
        .where((e) => e['property'] != null)
        .map((e) => Property.fromMap((e['property'] as Map).cast<String, dynamic>()))
        .toList();
  }

  static Future<void> toggleFavorite(String propertyId, bool on) async {
    final uid = sb.auth.currentUser!.id;
    if (on) {
      await sb.from('favorites').insert({'tenant_id': uid, 'property_id': propertyId});
    } else {
      await sb.from('favorites').delete().eq('tenant_id', uid).eq('property_id', propertyId);
    }
  }

  static Future<String> openConversation(String propertyId) async {
    final id = await sb.rpc('get_or_create_conversation',
        params: {'p_property_id': propertyId});
    return id as String;
  }

  static Future<List<Map<String, dynamic>>> conversations() async {
    final uid = sb.auth.currentUser!.id;
    final rows = await sb
        .from('conversations')
        .select(
            '*, property:properties(id, title, cover_url), tenant:profiles!conversations_tenant_id_fkey(id, full_name, avatar_url), owner:profiles!conversations_owner_id_fkey(id, full_name, avatar_url)')
        .or('tenant_id.eq.$uid,owner_id.eq.$uid')
        .order('last_message_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  static Future<void> notify(String userId, String title, String body,
      {String? linkId}) async {
    try {
      await sb.from('notifications').insert(
          {'user_id': userId, 'title': title, 'body': body, 'link_id': linkId});
    } catch (_) {/* non-critical */}
  }

  static Future<String> uploadImage(File file, String bucket) async {
    final uid = sb.auth.currentUser!.id;
    final ext = file.path.split('.').last.toLowerCase();
    final path =
        '$uid/${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}.$ext';
    await sb.storage.from(bucket).upload(path, file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false));
    return sb.storage.from(bucket).getPublicUrl(path);
  }
}

// ================================ SPLASH ===================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2100))
        ..forward();
  late final Animation<double> draw =
      CurvedAnimation(parent: _c, curve: const Interval(0.05, 0.62, curve: Curves.easeInOutCubic));
  late final Animation<double> fill =
      CurvedAnimation(parent: _c, curve: const Interval(0.52, 0.80, curve: Curves.easeOut));
  late final Animation<double> word =
      CurvedAnimation(parent: _c, curve: const Interval(0.62, 1.0, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 2250));
    if (!mounted) return;
    if (!kBackendReady) {
      _go(const ConfigScreen());
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarded') ?? false;
    if (sb.auth.currentUser != null) {
      final p = await Session.load();
      if (!mounted) return;
      if (p == null) {
        _go(const AuthScreen());
      } else if (p.isBlocked) {
        await Session.signOut();
        _go(const AuthScreen(blockedNotice: true));
      } else {
        _go(const Shell());
      }
      return;
    }
    _go(seen ? const AuthScreen() : const OnboardingScreen());
  }

  void _go(Widget w) => Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, a, __) =>
            FadeTransition(opacity: a, child: w),
      ));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: _GlowBackdrop()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _c,
                  builder: (_, __) => CustomPaint(
                    size: const Size(132, 118),
                    painter: _HouseMarkPainter(draw.value, fill.value),
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: word,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, .35), end: Offset.zero)
                        .animate(word),
                    child: Column(
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.1,
                                color: Colors.white),
                            children: [
                              TextSpan(text: 'Home'),
                              TextSpan(
                                  text: 'Direct',
                                  style: TextStyle(color: C.mint)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Rent straight from the owner',
                            style: TextStyle(
                                color: Colors.white.withOpacity(.62),
                                fontSize: 14,
                                letterSpacing: .3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBackdrop extends StatelessWidget {
  const _GlowBackdrop();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [C.ink, C.ink2, Color(0xFF07352C)],
        ),
      ),
      child: Stack(children: [
        Positioned(
          top: -110,
          right: -80,
          child: _blob(260, C.mint.withOpacity(.16)),
        ),
        Positioned(
          bottom: -140,
          left: -90,
          child: _blob(300, C.primary.withOpacity(.28)),
        ),
      ]),
    );
  }

  Widget _blob(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: c, blurRadius: 120, spreadRadius: 40)],
          color: c,
        ),
      );
}

/// Draws the roof + door outline stroke-by-stroke, then fades a mint key-hole in.
class _HouseMarkPainter extends CustomPainter {
  final double draw, fill;
  _HouseMarkPainter(this.draw, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * .06, h * .46)
      ..lineTo(w * .5, h * .06)
      ..lineTo(w * .94, h * .46)
      ..lineTo(w * .94, h * .96)
      ..lineTo(w * .06, h * .96)
      ..close();

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
          metric.extractPath(0, metric.length * draw.clamp(0, 1)), stroke);
    }

    if (fill > 0) {
      final cx = w * .5, cy = h * .62;
      final p = Paint()..color = C.mint.withOpacity(fill);
      canvas.drawCircle(Offset(cx, cy), 13 * fill, p);
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 5, cy + 6, 10, 26 * fill), const Radius.circular(5));
      canvas.drawRRect(r, p);
    }
  }

  @override
  bool shouldRepaint(_HouseMarkPainter o) => o.draw != draw || o.fill != fill;
}

// ============================== CONFIG SCREEN ==============================
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.vpn_key_rounded, color: C.mint, size: 40),
              const SizedBox(height: 18),
              const Text('Add your Supabase keys',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                'Open main.dart, find the CONFIG SPOT at the top, and paste your '
                'project URL and anon public key. You will find both in the Supabase '
                'dashboard under Settings → API. Then restart the app.',
                style: TextStyle(
                    color: Colors.white.withOpacity(.7), height: 1.5, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================== ONBOARDING =================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _i = 0;

  final _pages = const [
    _OnbData(
      eyebrow: 'NO BROKERS',
      title: 'Talk to the person\nwho owns the key',
      body:
          'Every listing on HomeDirect belongs to a real owner you can message directly. No agent fee, no middleman markup.',
      art: 0,
    ),
    _OnbData(
      eyebrow: 'ONE HONEST PRICE',
      title: 'See the rent\nbefore you travel',
      body:
          'Price, rooms, sector and photos are on the listing. Filter down to what you can actually afford, then book a viewing.',
      art: 1,
    ),
    _OnbData(
      eyebrow: 'CHECKED LISTINGS',
      title: 'Owners are verified\nbefore they publish',
      body:
          'Our team reviews owner documents and every new listing. Anything that looks off gets taken down.',
      art: 2,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final last = _i == _pages.length - 1;
    return Scaffold(
      backgroundColor: C.ink,
      body: Stack(
        children: [
          const Positioned.fill(child: _GlowBackdrop()),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 6),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text('Skip',
                          style: TextStyle(
                              color: Colors.white.withOpacity(.75),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _pages.length,
                    onPageChanged: (v) => setState(() => _i = v),
                    itemBuilder: (_, i) => _OnbPage(data: _pages[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final on = i == _i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: on ? 26 : 6,
                            decoration: BoxDecoration(
                              color: on ? C.mint : Colors.white.withOpacity(.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: C.mint,
                              foregroundColor: C.ink,
                              minimumSize: const Size.fromHeight(56)),
                          onPressed: () {
                            if (last) {
                              _finish();
                            } else {
                              _pc.nextPage(
                                  duration: const Duration(milliseconds: 320),
                                  curve: Curves.easeOutCubic);
                            }
                          },
                          child: Text(last ? 'Get started' : 'Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnbData {
  final String eyebrow, title, body;
  final int art;
  const _OnbData(
      {required this.eyebrow,
      required this.title,
      required this.body,
      required this.art});
}

class _OnbPage extends StatelessWidget {
  final _OnbData data;
  const _OnbPage({required this.data});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          SizedBox(
            height: 210,
            width: double.infinity,
            child: CustomPaint(painter: _OnbArtPainter(data.art)),
          ),
          const SizedBox(height: 38),
          Text(data.eyebrow,
              style: const TextStyle(
                  color: C.mint,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2)),
          const SizedBox(height: 14),
          Text(data.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.15,
                  letterSpacing: -0.9,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Text(data.body,
              style: TextStyle(
                  color: Colors.white.withOpacity(.66),
                  fontSize: 15.5,
                  height: 1.55)),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Three hand-built illustrations — no image assets needed.
class _OnbArtPainter extends CustomPainter {
  final int kind;
  _OnbArtPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final white = Paint()..color = Colors.white.withOpacity(.10);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(.55);
    final mint = Paint()..color = C.mint;

    if (kind == 0) {
      // two chat bubbles bridged by a key line
      final b1 = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .04, h * .10, w * .44, h * .34),
          const Radius.circular(20));
      final b2 = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .50, h * .52, w * .46, h * .34),
          const Radius.circular(20));
      canvas.drawRRect(b1, white);
      canvas.drawRRect(b2, Paint()..color = C.mint.withOpacity(.20));
      canvas.drawRRect(b1, line);
      canvas.drawRRect(b2, line..color = C.mint.withOpacity(.7));
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(
            Offset(w * .14 + i * 16, h * .27), 4.5, Paint()..color = Colors.white.withOpacity(.6));
      }
      canvas.drawLine(Offset(w * .30, h * .46), Offset(w * .62, h * .50),
          Paint()
            ..color = Colors.white.withOpacity(.28)
            ..strokeWidth = 2);
      canvas.drawCircle(Offset(w * .70, h * .68), 9, mint);
      canvas.drawRect(Rect.fromLTWH(w * .70, h * .68, 34, 5), mint);
    } else if (kind == 1) {
      // price bars rising, one highlighted
      final bars = [.32, .52, .44, .78, .60];
      for (var i = 0; i < bars.length; i++) {
        final bw = w * .12;
        final bh = h * bars[i];
        final x = w * .06 + i * (bw + w * .06);
        final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, h - bh, bw, bh), const Radius.circular(12));
        canvas.drawRRect(r, i == 3 ? mint : white);
      }
      canvas.drawLine(Offset(0, h * .22), Offset(w, h * .22),
          Paint()
            ..color = Colors.white.withOpacity(.22)
            ..strokeWidth = 1.4);
      canvas.drawCircle(Offset(w * .62, h * .22), 6, mint);
    } else {
      // shield with check + document lines
      final path = Path()
        ..moveTo(w * .5, h * .06)
        ..lineTo(w * .84, h * .22)
        ..lineTo(w * .84, h * .56)
        ..quadraticBezierTo(w * .84, h * .88, w * .5, h * .98)
        ..quadraticBezierTo(w * .16, h * .88, w * .16, h * .56)
        ..lineTo(w * .16, h * .22)
        ..close();
      canvas.drawPath(path, white);
      canvas.drawPath(path, line..color = C.mint.withOpacity(.75));
      final check = Path()
        ..moveTo(w * .38, h * .50)
        ..lineTo(w * .47, h * .60)
        ..lineTo(w * .64, h * .38);
      canvas.drawPath(
          check,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..color = C.mint);
    }
  }

  @override
  bool shouldRepaint(_OnbArtPainter o) => o.kind != kind;
}

// ================================= AUTH ====================================
class AuthScreen extends StatefulWidget {
  final bool blockedNotice;
  const AuthScreen({super.key, this.blockedNotice = false});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _signup = false, _busy = false, _hide = true;
  String _role = 'tenant';
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.blockedNotice) {
      WidgetsBinding.instance.addPostFrameCallback((_) => toast(context,
          'This account has been suspended. Contact support.',
          error: true));
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_signup) {
        await sb.auth.signUp(
          email: _email.text.trim(),
          password: _pass.text,
          data: {
            'full_name': _name.text.trim(),
            'phone': _phone.text.trim(),
            'role': _role,
          },
        );
        if (sb.auth.currentUser == null) {
          if (!mounted) return;
          setState(() => _busy = false);
          toast(context, 'Check your email to confirm the account, then sign in.');
          setState(() => _signup = false);
          return;
        }
      } else {
        await sb.auth.signInWithPassword(
            email: _email.text.trim(), password: _pass.text);
      }
      final p = await Session.load();
      if (!mounted) return;
      if (p == null) {
        setState(() => _busy = false);
        toast(context, 'Profile not found. Contact support.', error: true);
        return;
      }
      if (p.isBlocked) {
        await Session.signOut();
        if (!mounted) return;
        setState(() => _busy = false);
        toast(context, 'This account has been suspended.', error: true);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarded', true);
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Shell()));
    } on AuthException catch (e) {
      setState(() => _busy = false);
      if (mounted) toast(context, e.message, error: true);
    } catch (e) {
      setState(() => _busy = false);
      if (mounted) toast(context, 'Something went wrong. Try again.', error: true);
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      toast(context, 'Type your email first, then tap Forgot password.');
      return;
    }
    try {
      await sb.auth.resetPasswordForEmail(email);
      if (mounted) toast(context, 'Reset link sent to $email');
    } catch (_) {
      if (mounted) toast(context, 'Could not send the reset link.', error: true);
    }
    // SPOT: SMS reset. Swap to phone OTP once an SMS provider
    // (Africa's Talking / Twilio) is connected to Supabase Auth.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: C.ink, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.home_rounded,
                        color: C.mint, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('HomeDirect',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.4)),
                ]),
                const SizedBox(height: 34),
                Text(_signup ? 'Create your account' : 'Welcome back',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1)),
                const SizedBox(height: 8),
                Text(
                    _signup
                        ? 'A few details and you can start listing or searching.'
                        : 'Sign in to keep browsing and messaging owners.',
                    style: const TextStyle(color: C.muted, fontSize: 15)),
                const SizedBox(height: 28),
                if (_signup) ...[
                  _RoleChooser(
                      value: _role, onChanged: (v) => setState(() => _role = v)),
                  _gap,
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) =>
                        (v == null || v.trim().length < 3) ? 'Enter your full name' : null,
                  ),
                  _gap,
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone', hintText: '07XX XXX XXX'),
                    validator: (v) =>
                        (v == null || v.trim().length < 9) ? 'Enter a valid phone number' : null,
                  ),
                  _gap,
                ],
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                _gap,
                TextFormField(
                  controller: _pass,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_hide
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                if (!_signup)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: _forgot, child: const Text('Forgot password')),
                  ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white))
                      : Text(_signup ? 'Create account' : 'Sign in'),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : () => setState(() => _signup = !_signup),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: C.muted, fontSize: 14.5),
                        children: [
                          TextSpan(
                              text: _signup
                                  ? 'Already have an account?  '
                                  : "New here?  "),
                          TextSpan(
                              text: _signup ? 'Sign in' : 'Create an account',
                              style: const TextStyle(
                                  color: C.primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChooser extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _RoleChooser({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tile(String v, IconData ic, String title, String sub) {
      final on = value == v;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: on ? C.primary.withOpacity(.07) : C.sand,
              border: Border.all(color: on ? C.primary : C.line, width: on ? 1.6 : 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ic, color: on ? C.primary : C.muted, size: 22),
                const SizedBox(height: 10),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: on ? C.primary : C.text)),
                const SizedBox(height: 3),
                Text(sub,
                    style: const TextStyle(fontSize: 12, color: C.muted, height: 1.3)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(children: [
      tile('tenant', Icons.search_rounded, 'I am looking', 'Find a place to rent'),
      const SizedBox(width: 12),
      tile('owner', Icons.vpn_key_rounded, 'I own property', 'List and manage it'),
    ]);
  }
}

// ================================= SHELL ===================================
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final me = Session.me;
    if (me == null) return const AuthScreen();
    final owner = me.isOwner;

    final pages = owner
        ? const [OwnerDashboard(), OwnerListings(), InquiriesScreen(), ChatListScreen(), ProfileScreen()]
        : const [TenantHome(), ExploreScreen(), FavoritesScreen(), ChatListScreen(), ProfileScreen()];

    final items = owner
        ? const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Overview'),
            NavigationDestination(icon: Icon(Icons.holiday_village_outlined), selectedIcon: Icon(Icons.holiday_village_rounded), label: 'Listings'),
            NavigationDestination(icon: Icon(Icons.event_available_outlined), selectedIcon: Icon(Icons.event_available_rounded), label: 'Requests'),
            NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum_rounded), label: 'Messages'),
            NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
          ]
        : const [
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search_rounded), selectedIcon: Icon(Icons.search_rounded), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Saved'),
            NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum_rounded), label: 'Messages'),
            NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
          ];

    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        height: 68,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: C.primary.withOpacity(.12),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: items,
      ),
      floatingActionButton: owner && _i == 1
          ? FloatingActionButton.extended(
              backgroundColor: C.primary,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PropertyFormScreen())),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New listing'),
            )
          : null,
    );
  }
}

// ============================ SHARED WIDGETS ===============================
class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(strokeWidth: 2.6, color: C.primary)));
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final Widget? action;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.body,
      this.action});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: C.sand, borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, size: 30, color: C.primary),
              ),
              const SizedBox(height: 18),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, height: 1.5)),
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      );
}

class ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) => EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load',
        body: 'Check your connection and try again.',
        action: OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      );
}

class Photo extends StatelessWidget {
  final String? url;
  final double? h, w;
  final BorderRadius? radius;
  const Photo(this.url, {super.key, this.h, this.w, this.radius});
  @override
  Widget build(BuildContext context) {
    final ph = Container(
      height: h,
      width: w,
      color: C.sand,
      child: const Center(
          child: Icon(Icons.image_outlined, color: C.muted, size: 28)),
    );
    final child = (url == null || url!.isEmpty)
        ? ph
        : Image.network(url!,
            height: h,
            width: w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => ph,
            loadingBuilder: (c, w2, p) =>
                p == null ? w2 : Container(height: h, width: w, color: C.sand));
    return radius == null
        ? child
        : ClipRRect(borderRadius: radius!, child: child);
  }
}

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final map = {
      'active': [C.primary, 'Live'],
      'pending': [C.warn, 'Under review'],
      'rejected': [C.danger, 'Rejected'],
      'rented': [C.muted, 'Rented out'],
      'draft': [C.muted, 'Draft'],
    };
    final v = map[status] ?? [C.muted, status];
    final c = v[0] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: c.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
      child: Text(v[1] as String,
          style: TextStyle(
              color: c, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property p;
  final bool saved;
  final VoidCallback? onSave;
  const PropertyCard({super.key, required this.p, this.saved = false, this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PropertyDetail(id: p.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Photo(p.gallery.isEmpty ? null : p.gallery.first,
                  h: 190,
                  w: double.infinity,
                  radius: const BorderRadius.vertical(top: Radius.circular(19))),
              if (p.featured)
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: C.ink, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Featured',
                        style: TextStyle(
                            color: C.mint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              if (onSave != null)
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 19,
                          color: saved ? C.danger : C.text),
                    ),
                  ),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.3)),
                    ),
                    if (p.owner?['is_verified'] == true)
                      const Icon(Icons.verified_rounded, size: 17, color: C.primary),
                  ]),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 14, color: C.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: C.muted, fontSize: 13.5)),
                    ),
                  ]),
                  const SizedBox(height: 11),
                  Row(children: [
                    _spec(Icons.bed_outlined, '${p.bedrooms}'),
                    _spec(Icons.shower_outlined, '${p.bathrooms}'),
                    if (p.sizeSqm != null) _spec(Icons.square_foot_rounded, '${p.sizeSqm} m²'),
                    const Spacer(),
                    Text(money(p.price, p.currency),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: C.primary)),
                    Text('/${p.period == 'year' ? 'yr' : 'mo'}',
                        style: const TextStyle(color: C.muted, fontSize: 12.5)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spec(IconData i, String t) => Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Row(children: [
          Icon(i, size: 16, color: C.muted),
          const SizedBox(width: 4),
          Text(t, style: const TextStyle(fontSize: 13, color: C.muted)),
        ]),
      );
}

// ============================== TENANT HOME ================================
class TenantHome extends StatefulWidget {
  const TenantHome({super.key});
  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome> {
  late Future<List<Property>> _future;
  Set<String> _saved = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Property>> _load() async {
    final list = await Api.browse(Filters());
    _saved = await Api.favoriteIds();
    return list;
  }

  Future<void> _toggle(Property p) async {
    final on = !_saved.contains(p.id);
    setState(() => on ? _saved.add(p.id) : _saved.remove(p.id));
    try {
      await Api.toggleFavorite(p.id, on);
    } catch (_) {
      if (mounted) setState(() => on ? _saved.remove(p.id) : _saved.add(p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.me!;
    return Scaffold(
      body: RefreshIndicator(
        color: C.primary,
        onRefresh: () async => setState(() => _future = _load()),
        child: FutureBuilder<List<Property>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            if (snap.hasError) {
              return ErrorState(onRetry: () => setState(() => _future = _load()));
            }
            final all = snap.data ?? [];
            final featured = all.where((p) => p.featured).toList();
            final rest = all.where((p) => !p.featured).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 58, 20, 26),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [C.ink, C.ink2]),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Muraho, ${me.fullName.split(' ').first}',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.6),
                                        fontSize: 13.5)),
                                const SizedBox(height: 5),
                                const Text('Find your next home',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        letterSpacing: -.8,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          const NotificationBell(),
                        ]),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ExploreScreen(autoFocus: true))),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: const Row(children: [
                              Icon(Icons.search_rounded, color: C.muted, size: 21),
                              SizedBox(width: 10),
                              Text('Search by district, sector or title',
                                  style: TextStyle(color: C.muted, fontSize: 14.5)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 46,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                      children: kTypeLabels.entries
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(right: 9),
                                child: ActionChip(
                                  label: Text(e.value),
                                  backgroundColor: C.sand,
                                  side: const BorderSide(color: C.line),
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13),
                                  onPressed: () {
                                    final f = Filters()..type = e.key;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ExploreScreen(preset: f)));
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                if (all.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.holiday_village_outlined,
                      title: 'No live listings yet',
                      body: 'New places appear here as soon as owners publish them and our team approves.',
                    ),
                  ),
                if (featured.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                      child: _SectionTitle('Featured this week')),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 246,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20, right: 8),
                        itemCount: featured.length,
                        itemBuilder: (_, i) => SizedBox(
                          width: 264,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: PropertyCard(
                              p: featured[i],
                              saved: _saved.contains(featured[i].id),
                              onSave: () => _toggle(featured[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (rest.isNotEmpty)
                  const SliverToBoxAdapter(child: _SectionTitle('Recently added')),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  sliver: SliverList.builder(
                    itemCount: rest.length,
                    itemBuilder: (_, i) => PropertyCard(
                      p: rest[i],
                      saved: _saved.contains(rest[i].id),
                      onSave: () => _toggle(rest[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5)),
      );
}

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});
  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _n = 0;
  @override
  void initState() {
    super.initState();
    _count();
  }

  Future<void> _count() async {
    try {
      final rows = await sb
          .from('notifications')
          .select('id')
          .eq('user_id', sb.auth.currentUser!.id)
          .eq('is_read', false);
      if (mounted) setState(() => _n = (rows as List).length);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        _count();
      },
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(13)),
          child: const Icon(Icons.notifications_none_rounded,
              color: Colors.white, size: 21),
        ),
        if (_n > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: C.mint, shape: BoxShape.circle),
              child: Text('$_n',
                  style: const TextStyle(
                      fontSize: 9, color: C.ink, fontWeight: FontWeight.w800)),
            ),
          ),
      ]),
    );
  }
}

// =============================== EXPLORE ===================================
class ExploreScreen extends StatefulWidget {
  final Filters? preset;
  final bool autoFocus;
  const ExploreScreen({super.key, this.preset, this.autoFocus = false});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Filters _f = widget.preset ?? Filters();
  final _search = TextEditingController();
  final _focus = FocusNode();
  late Future<List<Property>> _future;
  Set<String> _saved = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.text = _f.query;
    _future = _load();
    if (widget.autoFocus) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  Future<List<Property>> _load() async {
    final list = await Api.browse(_f, limit: 60);
    _saved = await Api.favoriteIds();
    return list;
  }

  void _run() => setState(() => _future = _load());

  void _onType(String v) {
    _f.query = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), _run);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => FilterSheet(filters: _f),
    );
    if (changed == true) _run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.canPop(context),
        titleSpacing: Navigator.canPop(context) ? 0 : 20,
        title: const Text('Search'),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Stack(clipBehavior: Clip.none, children: [
              const Icon(Icons.tune_rounded),
              if (_f.isActive)
                const Positioned(
                    right: -1,
                    top: -1,
                    child: CircleAvatar(radius: 4, backgroundColor: C.primary)),
            ]),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _search,
              focusNode: _focus,
              textInputAction: TextInputAction.search,
              onChanged: _onType,
              onSubmitted: (_) => _run(),
              decoration: InputDecoration(
                hintText: 'District, sector or keyword',
                prefixIcon: const Icon(Icons.search_rounded, color: C.muted),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _search.clear();
                          _f.query = '';
                          _run();
                        }),
              ),
            ),
          ),
          if (_f.isActive)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: TextButton.icon(
                  onPressed: () {
                    _f.reset();
                    _run();
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Clear filters'),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Property>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Loading();
                }
                if (snap.hasError) return ErrorState(onRetry: _run);
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Nothing matches yet',
                    body: 'Try a wider price range or a different district.',
                    action: OutlinedButton(
                        onPressed: () {
                          _f.reset();
                          _search.clear();
                          _f.query = '';
                          _run();
                        },
                        child: const Text('Reset search')),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: list.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                            '${list.length} ${list.length == 1 ? "place" : "places"} available',
                            style: const TextStyle(
                                color: C.muted, fontWeight: FontWeight.w600)),
                      );
                    }
                    final p = list[i - 1];
                    return PropertyCard(
                      p: p,
                      saved: _saved.contains(p.id),
                      onSave: () async {
                        final on = !_saved.contains(p.id);
                        setState(() => on ? _saved.add(p.id) : _saved.remove(p.id));
                        await Api.toggleFavorite(p.id, on);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSheet extends StatefulWidget {
  final Filters filters;
  const FilterSheet({super.key, required this.filters});
  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Filters f = widget.filters;

  @override
  Widget build(BuildContext context) {
    final districts = <String>[];
    kDistricts.forEach((_, v) => districts.addAll(v));
    districts.sort();

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                      color: C.line, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            const Text('Filters',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 22),
            const _Label('Property type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kTypeLabels.entries.map((e) {
                final on = f.type == e.key;
                return ChoiceChip(
                  label: Text(e.value),
                  selected: on,
                  onSelected: (_) => setState(() => f.type = on ? null : e.key),
                  selectedColor: C.primary.withOpacity(.12),
                  backgroundColor: C.sand,
                  side: BorderSide(color: on ? C.primary : C.line),
                  labelStyle: TextStyle(
                      color: on ? C.primary : C.text,
                      fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const _Label('District'),
            DropdownButtonFormField<String>(
              initialValue: f.district,
              isExpanded: true,
              hint: const Text('Any district'),
              items: districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => f.district = v),
            ),
            const SizedBox(height: 22),
            _Label('Monthly rent  ·  ${money(f.minPrice)} – ${money(f.maxPrice)}'),
            RangeSlider(
              values: RangeValues(f.minPrice, f.maxPrice),
              min: 0,
              max: 2000000,
              divisions: 40,
              activeColor: C.primary,
              onChanged: (v) => setState(() {
                f.minPrice = v.start;
                f.maxPrice = v.end;
              }),
            ),
            const SizedBox(height: 12),
            const _Label('Bedrooms (minimum)'),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5].map((n) {
                final on = f.minBeds == n;
                return ChoiceChip(
                  label: Text(n == 5 ? '5+' : '$n'),
                  selected: on,
                  onSelected: (_) => setState(() => f.minBeds = on ? null : n),
                  selectedColor: C.primary.withOpacity(.12),
                  backgroundColor: C.sand,
                  side: BorderSide(color: on ? C.primary : C.line),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            FurnishedSwitch(
              value: f.furnishedOnly,
              onChanged: (v) => setState(() => f.furnishedOnly = v),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  onPressed: () => setState(() => f.reset()),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Show results'),
                ),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class FurnishedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const FurnishedSwitch(
      {super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        activeColor: C.primary,
        onChanged: onChanged,
        title: const Text('Furnished only',
            style: TextStyle(fontWeight: FontWeight.w600)),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14.5)),
      );
}

// =========================== PROPERTY DETAIL ===============================
class PropertyDetail extends StatefulWidget {
  final String id;
  const PropertyDetail({super.key, required this.id});
  @override
  State<PropertyDetail> createState() => _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> {
  late Future<Property> _future = Api.byId(widget.id);
  final _pc = PageController();
  int _photo = 0;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
    _countView();
  }

  Future<void> _countView() async {
    try {
      await sb.rpc('increment_views', params: {'p_property_id': widget.id});
    } catch (_) {}
  }

  Future<void> _checkSaved() async {
    try {
      final ids = await Api.favoriteIds();
      if (mounted) setState(() => _saved = ids.contains(widget.id));
    } catch (_) {}
  }

  Future<void> _contact(Property p) async {
    try {
      final convId = await Api.openConversation(p.id);
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChatScreen(
                  conversationId: convId,
                  title: p.owner?['full_name'] ?? 'Owner',
                  subtitle: p.title)));
    } catch (e) {
      if (mounted) toast(context, 'Could not open the chat.', error: true);
    }
  }

  Future<void> _requestViewing(Property p) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ViewingSheet(property: p),
    );
    if (result == true && mounted) {
      toast(context, 'Request sent. The owner will confirm a time.');
    }
  }

  Future<void> _report(Property p) async {
    final reasons = [
      'Listing is fake or misleading',
      'Property already rented',
      'Owner asked for money upfront',
      'Wrong price or location',
      'Something else',
    ];
    String? picked;
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Report this listing'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ...reasons.map((r) => RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: r,
                  groupValue: picked,
                  activeColor: C.primary,
                  title: Text(r, style: const TextStyle(fontSize: 14)),
                  onChanged: (v) => ss(() => picked = v),
                )),
            TextField(
              controller: note,
              decoration: const InputDecoration(hintText: 'Add detail (optional)'),
              maxLines: 2,
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
                onPressed: picked == null ? null : () => Navigator.pop(ctx, true),
                child: const Text('Send')),
          ],
        ),
      ),
    );
    if (ok == true) {
      await sb.from('reports').insert({
        'reporter_id': sb.auth.currentUser!.id,
        'property_id': p.id,
        'reason': picked,
        'details': note.text.trim(),
      });
      if (mounted) toast(context, 'Thank you. Our team will look into it.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Property>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Loading();
          }
          if (snap.hasError) {
            return ErrorState(
                onRetry: () => setState(() => _future = Api.byId(widget.id)));
          }
          final p = snap.data!;
          final gallery = p.gallery;
          final isMine = p.ownerId == sb.auth.currentUser?.id;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: Colors.white,
                    leading: _circleBtn(Icons.arrow_back_rounded,
                        () => Navigator.pop(context)),
                    actions: [
                      if (!isMine)
                        _circleBtn(
                            _saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded, () async {
                          setState(() => _saved = !_saved);
                          await Api.toggleFavorite(p.id, _saved);
                        }, color: _saved ? C.danger : C.text),
                      _circleBtn(Icons.flag_outlined, () => _report(p)),
                      const SizedBox(width: 10),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(children: [
                        PageView.builder(
                          controller: _pc,
                          itemCount: gallery.isEmpty ? 1 : gallery.length,
                          onPageChanged: (i) => setState(() => _photo = i),
                          itemBuilder: (_, i) => Photo(
                              gallery.isEmpty ? null : gallery[i],
                              w: double.infinity),
                        ),
                        if (gallery.length > 1)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text('${_photo + 1} / ${gallery.length}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(p.title,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -.7,
                                      height: 1.2)),
                            ),
                            if (isMine) StatusPill(p.status),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.place_outlined,
                                size: 16, color: C.muted),
                            const SizedBox(width: 5),
                            Expanded(
                                child: Text(
                                    [p.addressLine, p.sector, p.district, p.province]
                                        .where((e) => e.isNotEmpty)
                                        .join(', '),
                                    style: const TextStyle(
                                        color: C.muted, fontSize: 14.5))),
                          ]),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                  horizontal: BorderSide(color: C.line)),
                            ),
                            child: Row(children: [
                              _fact(Icons.bed_outlined, '${p.bedrooms}',
                                  p.bedrooms == 1 ? 'Bedroom' : 'Bedrooms'),
                              _fact(Icons.shower_outlined, '${p.bathrooms}',
                                  p.bathrooms == 1 ? 'Bathroom' : 'Bathrooms'),
                              _fact(Icons.square_foot_rounded,
                                  p.sizeSqm == null ? '—' : '${p.sizeSqm}', 'm²'),
                              _fact(Icons.chair_outlined,
                                  p.furnished ? 'Yes' : 'No', 'Furnished'),
                            ]),
                          ),
                          const SizedBox(height: 22),
                          const Text('About this place',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text(
                              p.description.isEmpty
                                  ? 'The owner has not added a description yet. Message them for details.'
                                  : p.description,
                              style: const TextStyle(
                                  height: 1.6, fontSize: 15, color: Color(0xFF2C3B37))),
                          if (p.amenities.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Text('What this place has',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: p.amenities
                                  .map((a) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: C.sand,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: C.line)),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          const Icon(Icons.check_rounded,
                                              size: 15, color: C.primary),
                                          const SizedBox(width: 6),
                                          Text(a, style: const TextStyle(fontSize: 13.5)),
                                        ]),
                                      ))
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 24),
                          const Text('Where it is',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          _MapSpot(p: p),
                          const SizedBox(height: 24),
                          _OwnerCard(p: p),
                          const SizedBox(height: 20),
                          Row(children: [
                            const Icon(Icons.visibility_outlined,
                                size: 16, color: C.muted),
                            const SizedBox(width: 6),
                            Text('${p.views} views  ·  listed ${ago(p.createdAt)} ago',
                                style: const TextStyle(color: C.muted, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isMine)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: const Border(top: BorderSide(color: C.line)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 20,
                            offset: const Offset(0, -4))
                      ],
                    ),
                    child: Row(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(money(p.price, p.currency),
                              style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.5)),
                          Text('per ${p.period}',
                              style: const TextStyle(color: C.muted, fontSize: 12.5)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  side: const BorderSide(color: C.primary),
                                  foregroundColor: C.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14))),
                              onPressed: () => _requestViewing(p),
                              child: const Text('Book viewing'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _contact(p),
                              child: const Text('Message'),
                            ),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _circleBtn(IconData i, VoidCallback onTap, {Color color = C.text}) =>
      Padding(
        padding: const EdgeInsets.all(7),
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(i, size: 20, color: color)),
          ),
        ),
      );

  Widget _fact(IconData i, String v, String l) => Expanded(
        child: Column(children: [
          Icon(i, color: C.primary, size: 21),
          const SizedBox(height: 7),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          Text(l, style: const TextStyle(color: C.muted, fontSize: 11.5)),
        ]),
      );
}

/// SPOT: Google Maps. Add google_maps_flutter + kGoogleMapsKey and swap the
/// placeholder body for a real GoogleMap centred on p.lat / p.lng.
class _MapSpot extends StatelessWidget {
  final Property p;
  const _MapSpot({required this.p});
  @override
  Widget build(BuildContext context) {
    final hasPin = p.lat != null && p.lng != null;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: C.sand,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
      ),
      child: Row(children: [
        const SizedBox(width: 18),
        const Icon(Icons.map_outlined, color: C.primary, size: 28),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  [p.sector, p.district].where((e) => e.isNotEmpty).join(', '),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                  hasPin
                      ? 'Pin saved by the owner. Map view is coming soon.'
                      : 'The owner has not dropped a pin yet.',
                  style: const TextStyle(color: C.muted, fontSize: 13, height: 1.4)),
              if (hasPin) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => launchUrl(
                      Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lng}'),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Open in Maps'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 14),
      ]),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final Property p;
  const _OwnerCard({required this.p});
  @override
  Widget build(BuildContext context) {
    final o = p.owner;
    final name = (o?['full_name'] ?? 'Owner') as String;
    final phone = o?['phone'] as String?;
    final verified = o?['is_verified'] == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: C.sand,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.line)),
      child: Row(children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: C.primary,
          backgroundImage: (o?['avatar_url'] != null && (o!['avatar_url'] as String).isNotEmpty)
              ? NetworkImage(o['avatar_url'] as String)
              : null,
          child: (o?['avatar_url'] == null || (o!['avatar_url'] as String).isEmpty)
              ? Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700))
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(
                    child: Text(name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15.5))),
                if (verified) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.verified_rounded, size: 16, color: C.primary),
                ],
              ]),
              const SizedBox(height: 3),
              Text(verified ? 'Documents checked by HomeDirect' : 'Owner',
                  style: const TextStyle(color: C.muted, fontSize: 12.5)),
            ],
          ),
        ),
        if (phone != null && phone.isNotEmpty)
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => launchUrl(Uri.parse('tel:$phone')),
            icon: const Icon(Icons.call_rounded, color: C.primary, size: 20),
          ),
      ]),
    );
  }
}

class _ViewingSheet extends StatefulWidget {
  final Property property;
  const _ViewingSheet({required this.property});
  @override
  State<_ViewingSheet> createState() => _ViewingSheetState();
}

class _ViewingSheetState extends State<_ViewingSheet> {
  DateTime? _date;
  final _msg = TextEditingController();
  bool _busy = false;

  Future<void> _send() async {
    if (_date == null) {
      toast(context, 'Pick a day that works for you.');
      return;
    }
    setState(() => _busy = true);
    try {
      await sb.from('inquiries').insert({
        'property_id': widget.property.id,
        'tenant_id': sb.auth.currentUser!.id,
        'owner_id': widget.property.ownerId,
        'message': _msg.text.trim(),
        'preferred_date':
            '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
      });
      await Api.notify(widget.property.ownerId, 'New viewing request',
          '${Session.me!.fullName} wants to view ${widget.property.title}',
          linkId: widget.property.id);
      // SPOT: SMS alert to the owner goes here once an SMS provider is wired.
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      setState(() => _busy = false);
      if (mounted) toast(context, 'Could not send the request.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
                color: C.line, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 18),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Book a viewing',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('The owner confirms the exact time with you in chat.',
              style: const TextStyle(color: C.muted, fontSize: 14)),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              initialDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (d != null) setState(() => _date = d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
                color: C.sand,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.line)),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 19, color: C.primary),
              const SizedBox(width: 12),
              Text(
                  _date == null
                      ? 'Choose a preferred day'
                      : '${_date!.day}/${_date!.month}/${_date!.year}',
                  style: TextStyle(
                      color: _date == null ? C.muted : C.text,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _msg,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Anything the owner should know? (optional)'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _busy ? null : _send,
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2, color: Colors.white))
              : const Text('Send request'),
        ),
      ]),
    );
  }
}

// ============================== FAVORITES ==================================
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Property>> _future = Api.favorites();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved places'), titleSpacing: 20),
      body: RefreshIndicator(
        color: C.primary,
        onRefresh: () async => setState(() => _future = Api.favorites()),
        child: FutureBuilder<List<Property>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            if (snap.hasError) {
              return ErrorState(
                  onRetry: () => setState(() => _future = Api.favorites()));
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'Nothing saved yet',
                body: 'Tap the heart on a listing and it will wait for you here.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: list.length,
              itemBuilder: (_, i) => PropertyCard(
                p: list[i],
                saved: true,
                onSave: () async {
                  await Api.toggleFavorite(list[i].id, false);
                  setState(() => _future = Api.favorites());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================================ CHAT =====================================
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<Map<String, dynamic>>> _future = Api.conversations();
  @override
  Widget build(BuildContext context) {
    final uid = sb.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), titleSpacing: 20),
      body: RefreshIndicator(
        color: C.primary,
        onRefresh: () async => setState(() => _future = Api.conversations()),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            if (snap.hasError) {
              return ErrorState(
                  onRetry: () => setState(() => _future = Api.conversations()));
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.forum_outlined,
                title: 'No conversations yet',
                body: 'When you message an owner about a place, the thread shows up here.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 84, color: C.line),
              itemBuilder: (_, i) {
                final c = list[i];
                final iAmTenant = c['tenant_id'] == uid;
                final other = (iAmTenant ? c['owner'] : c['tenant']) as Map?;
                final prop = c['property'] as Map?;
                final name = (other?['full_name'] ?? 'User') as String;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Photo(prop?['cover_url'] as String?,
                        radius: BorderRadius.circular(12)),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text((prop?['title'] ?? '') as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: C.primary,
                              fontWeight: FontWeight.w600)),
                      Text((c['last_message'] ?? 'Say hello') as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: C.muted)),
                    ],
                  ),
                  trailing: Text(ago(DateTime.parse(c['last_message_at'] as String)),
                      style: const TextStyle(fontSize: 11.5, color: C.muted)),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreen(
                                conversationId: c['id'] as String,
                                title: name,
                                subtitle: (prop?['title'] ?? '') as String)));
                    setState(() => _future = Api.conversations());
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String conversationId, title, subtitle;
  const ChatScreen(
      {super.key,
      required this.conversationId,
      required this.title,
      required this.subtitle});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final Stream<List<Map<String, dynamic>>> _stream = sb
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('conversation_id', widget.conversationId)
      .order('created_at');

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty) return;
    _input.clear();
    try {
      await sb.from('messages').insert({
        'conversation_id': widget.conversationId,
        'sender_id': sb.auth.currentUser!.id,
        'body': body,
      });
    } catch (_) {
      if (mounted) toast(context, 'Message not sent.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = sb.auth.currentUser!.id;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16.5)),
            if (widget.subtitle.isNotEmpty)
              Text(widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: C.muted)),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _stream,
            builder: (context, snap) {
              if (!snap.hasData) return const Loading();
              final msgs = snap.data!;
              if (msgs.isEmpty) {
                return const EmptyState(
                  icon: Icons.waving_hand_outlined,
                  title: 'Start the conversation',
                  body: 'Ask about the rent, the deposit, or when you can visit.',
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scroll.hasClients) {
                  _scroll.jumpTo(_scroll.position.maxScrollExtent);
                }
              });
              return ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  final mine = m['sender_id'] == uid;
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .74),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                      decoration: BoxDecoration(
                        color: mine ? C.primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(mine ? 16 : 4),
                          bottomRight: Radius.circular(mine ? 4 : 16),
                        ),
                        border: mine ? null : Border.all(color: C.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text((m['body'] ?? '') as String,
                              style: TextStyle(
                                  color: mine ? Colors.white : C.text,
                                  fontSize: 15,
                                  height: 1.35)),
                          const SizedBox(height: 3),
                          Text(ago(DateTime.parse(m['created_at'] as String)),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: mine
                                      ? Colors.white.withOpacity(.7)
                                      : C.muted)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: C.line))),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'Write a message',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: C.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _send,
                child: const Padding(
                    padding: EdgeInsets.all(13),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 20)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ============================ NOTIFICATIONS ================================
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await sb
        .from('notifications')
        .select()
        .eq('user_id', sb.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .limit(60);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> _markAll() async {
    await sb
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', sb.auth.currentUser!.id)
        .eq('is_read', false);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [
        TextButton(onPressed: _markAll, child: const Text('Mark all read')),
        const SizedBox(width: 8),
      ]),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Loading();
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All quiet',
              body: 'Updates about your listings and requests will land here.',
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: C.line),
            itemBuilder: (_, i) {
              final n = list[i];
              final unread = n['is_read'] == false;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: unread ? C.primary.withOpacity(.12) : C.sand,
                  child: Icon(Icons.notifications_rounded,
                      size: 19, color: unread ? C.primary : C.muted),
                ),
                title: Text(n['title'] as String,
                    style: TextStyle(
                        fontWeight:
                            unread ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 15)),
                subtitle: Text((n['body'] ?? '') as String,
                    style: const TextStyle(color: C.muted, fontSize: 13.5)),
                trailing: Text(ago(DateTime.parse(n['created_at'] as String)),
                    style: const TextStyle(fontSize: 11.5, color: C.muted)),
              );
            },
          );
        },
      ),
    );
  }
}

// =========================== OWNER — DASHBOARD =============================
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  late Future<Map<String, dynamic>> _future = _load();

  Future<Map<String, dynamic>> _load() async {
    final uid = sb.auth.currentUser!.id;
    final props = await Api.mine();
    final inq = await sb
        .from('inquiries')
        .select('id, status')
        .eq('owner_id', uid);
    final pendingInq =
        (inq as List).where((e) => e['status'] == 'pending').length;
    return {
      'props': props,
      'views': props.fold<int>(0, (a, p) => a + p.views),
      'live': props.where((p) => p.status == 'active').length,
      'review': props.where((p) => p.status == 'pending').length,
      'requests': pendingInq,
    };
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.me!;
    return Scaffold(
      body: RefreshIndicator(
        color: C.primary,
        onRefresh: () async => setState(() => _future = _load()),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            if (snap.hasError) {
              return ErrorState(onRetry: () => setState(() => _future = _load()));
            }
            final d = snap.data!;
            final props = d['props'] as List<Property>;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 58, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [C.ink, C.ink2]),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your properties',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.6),
                                      fontSize: 13.5)),
                              const SizedBox(height: 5),
                              Text(me.fullName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      letterSpacing: -.8,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        const NotificationBell(),
                      ]),
                      const SizedBox(height: 22),
                      Row(children: [
                        _stat('${d['live']}', 'Live'),
                        const SizedBox(width: 10),
                        _stat('${d['views']}', 'Views'),
                        const SizedBox(width: 10),
                        _stat('${d['requests']}', 'Requests'),
                      ]),
                    ],
                  ),
                ),
                if (!me.isVerified)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: _VerifyBanner(
                        onDone: () => setState(() => _future = _load())),
                  ),
                if (d['review'] as int > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: C.warn.withOpacity(.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: C.warn.withOpacity(.35))),
                      child: Row(children: [
                        const Icon(Icons.hourglass_top_rounded,
                            color: C.warn, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              '${d['review']} listing(s) waiting for review. We usually approve within a day.',
                              style: const TextStyle(fontSize: 13.5, height: 1.4)),
                        ),
                      ]),
                    ),
                  ),
                const _SectionTitle('Your listings'),
                if (props.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: EmptyState(
                      icon: Icons.add_home_work_outlined,
                      title: 'No listings yet',
                      body: 'Add your first property and tenants can start messaging you.',
                      action: FilledButton(
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(200, 50)),
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PropertyFormScreen()));
                          setState(() => _future = _load());
                        },
                        child: const Text('Add a property'),
                      ),
                    ),
                  ),
                ...props.take(4).map((p) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OwnerListingTile(
                          p: p, onChanged: () => setState(() => _future = _load())),
                    )),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(v,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(l,
                style: TextStyle(
                    color: Colors.white.withOpacity(.6), fontSize: 12)),
          ]),
        ),
      );
}

class _VerifyBanner extends StatelessWidget {
  final VoidCallback onDone;
  const _VerifyBanner({required this.onDone});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: C.primary.withOpacity(.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.primary.withOpacity(.25))),
      child: Row(children: [
        const Icon(Icons.verified_user_outlined, color: C.primary),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Get the verified badge',
                style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 3),
            Text('Verified owners get more replies. Upload your ID once.',
                style: TextStyle(color: C.muted, fontSize: 12.5, height: 1.35)),
          ]),
        ),
        TextButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const VerificationScreen()));
            onDone();
          },
          child: const Text('Start'),
        ),
      ]),
    );
  }
}

// =========================== OWNER — LISTINGS ==============================
class OwnerListings extends StatefulWidget {
  const OwnerListings({super.key});
  @override
  State<OwnerListings> createState() => _OwnerListingsState();
}

class _OwnerListingsState extends State<OwnerListings> {
  late Future<List<Property>> _future = Api.mine();
  void _reload() => setState(() => _future = Api.mine());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My listings'), titleSpacing: 20),
      body: RefreshIndicator(
        color: C.primary,
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Property>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            if (snap.hasError) return ErrorState(onRetry: _reload);
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.holiday_village_outlined,
                title: 'Nothing listed yet',
                body: 'Tap "New listing" to publish your first property.',
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: list
                  .map((p) => OwnerListingTile(p: p, onChanged: _reload))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class OwnerListingTile extends StatelessWidget {
  final Property p;
  final VoidCallback onChanged;
  const OwnerListingTile({super.key, required this.p, required this.onChanged});

  Future<void> _menu(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit listing'),
              onTap: () => Navigator.pop(context, 'edit')),
          if (p.status == 'active')
            ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: const Text('Mark as rented out'),
                onTap: () => Navigator.pop(context, 'rented')),
          if (p.status == 'rented')
            ListTile(
                leading: const Icon(Icons.replay_rounded),
                title: const Text('Put back on the market'),
                onTap: () => Navigator.pop(context, 'relist')),
          ListTile(
              leading: const Icon(Icons.rocket_launch_outlined),
              title: const Text('Boost to featured'),
              subtitle: Text(kPaymentsPublicKey.isEmpty
                  ? 'Payments not connected yet'
                  : 'Show this listing at the top'),
              enabled: kPaymentsPublicKey.isNotEmpty,
              onTap: () => Navigator.pop(context, 'boost')),
          ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: C.danger),
              title: const Text('Delete', style: TextStyle(color: C.danger)),
              onTap: () => Navigator.pop(context, 'delete')),
          const SizedBox(height: 10),
        ]),
      ),
    );
    if (choice == null) return;

    if (choice == 'edit') {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => PropertyFormScreen(existing: p)));
      onChanged();
    } else if (choice == 'rented' || choice == 'relist') {
      await sb.from('properties').update(
          {'status': choice == 'rented' ? 'rented' : 'pending'}).eq('id', p.id);
      onChanged();
    } else if (choice == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete this listing?'),
          content: const Text('It disappears for everyone. This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep it')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: C.danger))),
          ],
        ),
      );
      if (ok == true) {
        await sb.from('properties').delete().eq('id', p.id);
        onChanged();
      }
    }
    // SPOT: 'boost' opens the aggregator checkout once kPaymentsPublicKey is set.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.line)),
      child: Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 6, 8),
          leading: SizedBox(
            width: 62,
            height: 62,
            child: Photo(p.gallery.isEmpty ? null : p.gallery.first,
                radius: BorderRadius.circular(14)),
          ),
          title: Text(p.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('${money(p.price, p.currency)} / ${p.period}',
                  style: const TextStyle(
                      color: C.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Row(children: [
                StatusPill(p.status),
                const SizedBox(width: 8),
                Text('${p.views} views',
                    style: const TextStyle(fontSize: 12, color: C.muted)),
              ]),
            ],
          ),
          trailing: IconButton(
              onPressed: () => _menu(context),
              icon: const Icon(Icons.more_vert_rounded)),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => PropertyDetail(id: p.id))),
        ),
        if (p.status == 'rejected' && (p.rejectReason ?? '').isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
                color: C.danger.withOpacity(.07),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(17))),
            child: Text('Rejected: ${p.rejectReason}',
                style: const TextStyle(fontSize: 12.5, color: C.danger, height: 1.4)),
          ),
      ]),
    );
  }
}

// ========================= OWNER — PROPERTY FORM ===========================
class PropertyFormScreen extends StatefulWidget {
  final Property? existing;
  const PropertyFormScreen({super.key, this.existing});
  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _size = TextEditingController();
  final _address = TextEditingController();
  final _sector = TextEditingController();

  String _type = 'apartment', _period = 'month';
  String _province = 'Kigali City', _district = 'Gasabo';
  int _beds = 1, _baths = 1;
  bool _furnished = false, _busy = false;
  final Set<String> _amenities = {};
  final List<String> _urls = [];
  final List<File> _newFiles = [];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _desc.text = e.description;
      _price.text = e.price.round().toString();
      _size.text = e.sizeSqm?.toString() ?? '';
      _address.text = e.addressLine;
      _sector.text = e.sector;
      _type = e.type;
      _period = e.period;
      if (kProvinces.contains(e.province)) _province = e.province;
      if ((kDistricts[_province] ?? []).contains(e.district)) _district = e.district;
      _beds = e.bedrooms;
      _baths = e.bathrooms;
      _furnished = e.furnished;
      _amenities.addAll(e.amenities);
      _urls.addAll(e.gallery);
    }
  }

  Future<void> _pick() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 72, maxWidth: 1600);
    if (files.isEmpty) return;
    setState(() => _newFiles.addAll(files.map((x) => File(x.path))));
  }

  Future<void> _save({required bool publish}) async {
    if (!_form.currentState!.validate()) return;
    if (_urls.isEmpty && _newFiles.isEmpty) {
      toast(context, 'Add at least one photo — listings with photos get replies.');
      return;
    }
    setState(() => _busy = true);
    try {
      final uid = sb.auth.currentUser!.id;
      final uploaded = <String>[];
      for (final f in _newFiles) {
        uploaded.add(await Api.uploadImage(f, 'property-photos'));
      }
      final all = [..._urls, ...uploaded];

      final data = {
        'owner_id': uid,
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'type': _type,
        'price': num.parse(_price.text.trim()),
        'period': _period,
        'bedrooms': _beds,
        'bathrooms': _baths,
        'size_sqm': _size.text.trim().isEmpty ? null : int.parse(_size.text.trim()),
        'furnished': _furnished,
        'province': _province,
        'district': _district,
        'sector': _sector.text.trim(),
        'address_line': _address.text.trim(),
        'amenities': _amenities.toList(),
        'cover_url': all.first,
        'status': publish ? 'pending' : 'draft',
      };

      String propId;
      if (widget.existing == null) {
        final row =
            await sb.from('properties').insert(data).select('id').single();
        propId = row['id'] as String;
      } else {
        propId = widget.existing!.id;
        await sb.from('properties').update(data).eq('id', propId);
        await sb.from('property_photos').delete().eq('property_id', propId);
      }

      if (all.length > 1) {
        await sb.from('property_photos').insert([
          for (var i = 0; i < all.length; i++)
            {'property_id': propId, 'url': all[i], 'sort_order': i}
        ]);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      toast(
          context,
          publish
              ? 'Sent for review. We approve most listings within a day.'
              : 'Saved as a draft.');
    } catch (e) {
      setState(() => _busy = false);
      if (mounted) toast(context, 'Could not save the listing.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit listing' : 'New listing')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            const _Label('Photos'),
            SizedBox(
              height: 104,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: _pick,
                    child: Container(
                      width: 104,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          color: C.sand,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: C.line)),
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: C.primary),
                            SizedBox(height: 6),
                            Text('Add', style: TextStyle(fontSize: 12, color: C.muted)),
                          ]),
                    ),
                  ),
                  ..._urls.map((u) => _thumb(
                      child: Photo(u, w: 104, h: 104, radius: BorderRadius.circular(14)),
                      onRemove: () => setState(() => _urls.remove(u)))),
                  ..._newFiles.map((f) => _thumb(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(f, width: 104, height: 104, fit: BoxFit.cover)),
                      onRemove: () => setState(() => _newFiles.remove(f)))),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _Label('Title'),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  hintText: 'e.g. Bright 2-bedroom apartment in Kacyiru'),
              validator: (v) =>
                  (v == null || v.trim().length < 8) ? 'Give it a clear title' : null,
            ),
            const SizedBox(height: 18),
            const _Label('Type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kTypeLabels.entries.map((e) {
                final on = _type == e.key;
                return ChoiceChip(
                  label: Text(e.value),
                  selected: on,
                  onSelected: (_) => setState(() => _type = e.key),
                  selectedColor: C.primary.withOpacity(.12),
                  backgroundColor: C.sand,
                  side: BorderSide(color: on ? C.primary : C.line),
                  labelStyle: TextStyle(
                      color: on ? C.primary : C.text, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                flex: 3,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _Label('Rent'),
                  TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        prefixText: 'RWF  ', hintText: '250000'),
                    validator: (v) {
                      final n = num.tryParse((v ?? '').trim());
                      return (n == null || n <= 0) ? 'Enter the rent' : null;
                    },
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _Label('Per'),
                  DropdownButtonFormField<String>(
                    initialValue: _period,
                    items: const [
                      DropdownMenuItem(value: 'month', child: Text('Month')),
                      DropdownMenuItem(value: 'year', child: Text('Year')),
                    ],
                    onChanged: (v) => setState(() => _period = v!),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _counter('Bedrooms', _beds, (v) => setState(() => _beds = v))),
              const SizedBox(width: 12),
              Expanded(child: _counter('Bathrooms', _baths, (v) => setState(() => _baths = v))),
            ]),
            const SizedBox(height: 18),
            const _Label('Size in m² (optional)'),
            TextFormField(
              controller: _size,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 85'),
            ),
            const SizedBox(height: 18),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _furnished,
              activeColor: C.primary,
              onChanged: (v) => setState(() => _furnished = v),
              title: const Text('Furnished',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            const _Label('Province'),
            DropdownButtonFormField<String>(
              initialValue: _province,
              items: kProvinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() {
                _province = v!;
                _district = kDistricts[v]!.first;
              }),
            ),
            const SizedBox(height: 16),
            const _Label('District'),
            DropdownButtonFormField<String>(
              initialValue: _district,
              items: (kDistricts[_province] ?? [])
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _district = v!),
            ),
            const SizedBox(height: 16),
            const _Label('Sector'),
            TextFormField(
              controller: _sector,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'e.g. Kacyiru'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Add the sector' : null,
            ),
            const SizedBox(height: 16),
            const _Label('Street / landmark'),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(hintText: 'e.g. Near Kacyiru Police Station'),
            ),
            // SPOT: map pin. With google_maps_flutter you can let the owner drag a
            // marker and write latitude / longitude into the same insert.
            const SizedBox(height: 22),
            const _Label('What this place has'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kAmenities.map((a) {
                final on = _amenities.contains(a);
                return FilterChip(
                  label: Text(a),
                  selected: on,
                  onSelected: (v) => setState(
                      () => v ? _amenities.add(a) : _amenities.remove(a)),
                  selectedColor: C.primary.withOpacity(.12),
                  backgroundColor: C.sand,
                  checkmarkColor: C.primary,
                  side: BorderSide(color: on ? C.primary : C.line),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const _Label('Description'),
            TextFormField(
              controller: _desc,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  hintText:
                      'Describe the place, the neighbourhood, water and power, and what you expect from a tenant.'),
              validator: (v) => (v == null || v.trim().length < 20)
                  ? 'Write at least a couple of sentences'
                  : null,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        decoration: const BoxDecoration(
            color: Colors.white, border: Border(top: BorderSide(color: C.line))),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              onPressed: _busy ? null : () => _save(publish: false),
              child: const Text('Save draft'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _busy ? null : () => _save(publish: true),
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white))
                  : Text(editing ? 'Save and resubmit' : 'Send for review'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _thumb({required Widget child, required VoidCallback onRemove}) =>
      Stack(children: [
        Padding(padding: const EdgeInsets.only(right: 10), child: child),
        Positioned(
          right: 14,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ]);

  Widget _counter(String label, int value, ValueChanged<int> onChange) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          Container(
            height: 54,
            decoration: BoxDecoration(
                color: C.sand,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.line)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: value > 0 ? () => onChange(value - 1) : null,
                    icon: const Icon(Icons.remove_rounded, size: 20)),
                Text('$value',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                IconButton(
                    onPressed: value < 20 ? () => onChange(value + 1) : null,
                    icon: const Icon(Icons.add_rounded, size: 20)),
              ],
            ),
          ),
        ],
      );
}

// ========================= OWNER — VIEWING REQUESTS ========================
class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});
  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();
  String _tab = 'pending';

  Future<List<Map<String, dynamic>>> _load() async {
    final me = Session.me!;
    final col = me.isOwner ? 'owner_id' : 'tenant_id';
    final rows = await sb
        .from('inquiries')
        .select(
            '*, property:properties(id, title, cover_url), tenant:profiles!inquiries_tenant_id_fkey(id, full_name, phone)')
        .eq(col, sb.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> _set(Map<String, dynamic> inq, String status) async {
    await sb.from('inquiries').update({'status': status}).eq('id', inq['id']);
    await Api.notify(
        inq['tenant_id'] as String,
        status == 'accepted' ? 'Viewing confirmed' : 'Viewing declined',
        '${(inq['property'] as Map?)?['title'] ?? 'Your request'} — ${status == 'accepted' ? 'the owner accepted. Agree the time in chat.' : 'the owner cannot host this visit.'}');
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['pending', 'accepted', 'declined', 'completed'];
    return Scaffold(
      appBar: AppBar(title: const Text('Viewing requests'), titleSpacing: 20),
      body: Column(children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: tabs.map((t) {
              final on = _tab == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t[0].toUpperCase() + t.substring(1)),
                  selected: on,
                  onSelected: (_) => setState(() => _tab = t),
                  selectedColor: C.primary.withOpacity(.12),
                  backgroundColor: C.sand,
                  side: BorderSide(color: on ? C.primary : C.line),
                  labelStyle: TextStyle(
                      color: on ? C.primary : C.text, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Loading();
              }
              if (snap.hasError) {
                return ErrorState(onRetry: () => setState(() => _future = _load()));
              }
              final list =
                  (snap.data ?? []).where((e) => e['status'] == _tab).toList();
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'Nothing $_tab',
                  body: 'Requests from tenants show up here as they come in.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final q = list[i];
                  final prop = q['property'] as Map?;
                  final tenant = q['tenant'] as Map?;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: C.line)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Photo(prop?['cover_url'] as String?,
                                radius: BorderRadius.circular(12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((prop?['title'] ?? 'Listing') as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(
                                    '${tenant?['full_name'] ?? 'Tenant'}  ·  wants ${q['preferred_date'] ?? 'a visit'}',
                                    style: const TextStyle(
                                        color: C.muted, fontSize: 12.5)),
                              ],
                            ),
                          ),
                        ]),
                        if ((q['message'] as String?)?.isNotEmpty == true) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: C.sand,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(q['message'] as String,
                                style: const TextStyle(fontSize: 13.5, height: 1.4)),
                          ),
                        ],
                        if (_tab == 'pending' && Session.me!.isOwner) ...[
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _set(q, 'declined'),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(46)),
                                onPressed: () => _set(q, 'accepted'),
                                child: const Text('Accept'),
                              ),
                            ),
                          ]),
                        ],
                        if (_tab == 'accepted' && Session.me!.isOwner) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: () => _set(q, 'completed'),
                                child: const Text('Mark as visited')),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ================================ PROFILE ==================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile get me => Session.me!;

  Future<void> _refresh() async {
    await Session.load();
    if (mounted) setState(() {});
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?'),
        content: const Text('You will need your email and password to get back in.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out', style: TextStyle(color: C.danger))),
        ],
      ),
    );
    if (ok != true) return;
    await Session.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 62, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [C.ink, C.ink2]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 33,
                backgroundColor: C.mint,
                backgroundImage: (me.avatarUrl != null && me.avatarUrl!.isNotEmpty)
                    ? NetworkImage(me.avatarUrl!)
                    : null,
                child: (me.avatarUrl == null || me.avatarUrl!.isEmpty)
                    ? Text(me.initials,
                        style: const TextStyle(
                            color: C.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 22))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(me.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ),
                      if (me.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: C.mint, size: 18),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Text(me.isOwner ? 'Property owner' : 'Looking to rent',
                        style: TextStyle(
                            color: Colors.white.withOpacity(.62), fontSize: 13.5)),
                    if (me.phone != null && me.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(me.phone!,
                          style: TextStyle(
                              color: Colors.white.withOpacity(.5), fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          _group([
            _row(Icons.person_outline_rounded, 'Edit profile', onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              _refresh();
            }),
            if (me.isOwner)
              _row(Icons.verified_user_outlined,
                  me.isVerified ? 'Verification — approved' : 'Get verified',
                  trailing: me.isVerified
                      ? const Icon(Icons.check_circle_rounded,
                          color: C.primary, size: 20)
                      : null, onTap: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VerificationScreen()));
                _refresh();
              }),
            if (!me.isOwner)
              _row(Icons.event_available_outlined, 'My viewing requests',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InquiriesScreen()))),
            _row(Icons.notifications_none_rounded, 'Notifications',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          ]),
          const SizedBox(height: 16),
          _group([
            _row(Icons.help_outline_rounded, 'How HomeDirect works',
                onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (_) => const _HowItWorksSheet(),
                    )),
            _row(Icons.shield_outlined, 'Stay safe when renting',
                onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (_) => const _SafetySheet(),
                    )),
            _row(Icons.mail_outline_rounded, 'Contact support',
                onTap: () => launchUrl(Uri.parse(
                    'mailto:support@homedirect.rw?subject=HomeDirect%20support'))),
          ]),
          const SizedBox(height: 16),
          _group([
            _row(Icons.logout_rounded, 'Sign out',
                color: C.danger, onTap: _signOut),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text('HomeDirect · v1.0',
                style: const TextStyle(color: C.muted, fontSize: 12)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _group(List<Widget> children) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.line)),
        child: Column(children: children),
      );

  Widget _row(IconData icon, String label,
          {VoidCallback? onTap, Widget? trailing, Color color = C.text}) =>
      ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(icon, size: 21, color: color == C.text ? C.primary : color),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15, color: color)),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: C.muted, size: 20),
      );
}

class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet();
  @override
  Widget build(BuildContext context) {
    const steps = [
      ['Search without an agent', 'Every listing belongs to the owner. No commission is added on top of the rent.'],
      ['Message the owner directly', 'Ask your questions in the app, so you have a record of what was agreed.'],
      ['Book a viewing', 'Pick a day, the owner confirms, and you meet at the property.'],
      ['Agree the rent between you', 'HomeDirect does not hold your money. Pay the owner the way you both agree.'],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
                color: C.line, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('How HomeDirect works',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 18),
        ...steps.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle_rounded, color: C.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s[0],
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(s[1],
                            style: const TextStyle(
                                color: C.muted, fontSize: 13.5, height: 1.45)),
                      ]),
                ),
              ]),
            )),
      ]),
    );
  }
}

class _SafetySheet extends StatelessWidget {
  const _SafetySheet();
  @override
  Widget build(BuildContext context) {
    const tips = [
      'Visit the property before you pay anything.',
      'Never send a deposit to someone you have not met at the house.',
      'Ask to see the owner ID and proof the house is theirs.',
      'Keep the conversation in the app so there is a record.',
      'If something feels wrong, report the listing — the flag icon is on every page.',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
                color: C.line, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Stay safe when renting',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 16),
        ...tips.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('•  ', style: TextStyle(color: C.primary, fontSize: 16)),
                Expanded(
                    child: Text(t,
                        style: const TextStyle(fontSize: 14.5, height: 1.45))),
              ]),
            )),
      ]),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController(text: Session.me!.fullName);
  final _phone = TextEditingController(text: Session.me!.phone ?? '');
  final _bio = TextEditingController(text: Session.me!.bio ?? '');
  File? _avatar;
  bool _busy = false;

  Future<void> _pickAvatar() async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
    if (x != null) setState(() => _avatar = File(x.path));
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      String? url;
      if (_avatar != null) url = await Api.uploadImage(_avatar!, 'avatars');
      await sb.from('profiles').update({
        'full_name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'bio': _bio.text.trim(),
        if (url != null) 'avatar_url': url,
      }).eq('id', sb.auth.currentUser!.id);
      await Session.load();
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, 'Profile updated');
    } catch (_) {
      setState(() => _busy = false);
      if (mounted) toast(context, 'Could not save your profile.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.me!;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: C.sand,
                  backgroundImage: _avatar != null
                      ? FileImage(_avatar!)
                      : (me.avatarUrl != null && me.avatarUrl!.isNotEmpty)
                          ? NetworkImage(me.avatarUrl!) as ImageProvider
                          : null,
                  child: (_avatar == null &&
                          (me.avatarUrl == null || me.avatarUrl!.isEmpty))
                      ? Text(me.initials,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800))
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                        color: C.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 15, color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          const _Label('Full name'),
          TextField(controller: _name),
          const SizedBox(height: 18),
          const _Label('Phone'),
          TextField(controller: _phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 18),
          const _Label('About you'),
          TextField(
            controller: _bio,
            maxLines: 4,
            decoration: const InputDecoration(
                hintText: 'A line or two so people know who they are dealing with.'),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white))
                : const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}

// ============================ VERIFICATION =================================
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();
  String _docType = 'national_id';
  bool _busy = false;

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await sb
        .from('verification_docs')
        .select()
        .eq('owner_id', sb.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> _upload() async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1800);
    if (x == null) return;
    setState(() => _busy = true);
    try {
      final uid = sb.auth.currentUser!.id;
      final file = File(x.path);
      final ext = file.path.split('.').last;
      final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await sb.storage.from('verification-docs').upload(path, file);
      await sb.from('verification_docs').insert({
        'owner_id': uid,
        'doc_type': _docType,
        'url': path, // private bucket: admins open it with a signed URL
      });
      if (!mounted) return;
      setState(() {
        _busy = false;
        _future = _load();
      });
      toast(context, 'Document sent. Our team reviews it within 48 hours.');
    } catch (_) {
      setState(() => _busy = false);
      if (mounted) toast(context, 'Upload failed. Try again.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner verification')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: C.primary.withOpacity(.07),
                borderRadius: BorderRadius.circular(16)),
            child: const Text(
                'Verified owners carry a badge on every listing, and tenants reply to them more often. '
                'Send a clear photo of your ID or a document showing you own the property. '
                'Only our review team can open it.',
                style: TextStyle(height: 1.5, fontSize: 14)),
          ),
          const SizedBox(height: 24),
          const _Label('Document type'),
          DropdownButtonFormField<String>(
            initialValue: _docType,
            items: const [
              DropdownMenuItem(value: 'national_id', child: Text('National ID')),
              DropdownMenuItem(value: 'passport', child: Text('Passport')),
              DropdownMenuItem(value: 'land_title', child: Text('Land title / lease')),
              DropdownMenuItem(value: 'utility_bill', child: Text('Utility bill')),
            ],
            onChanged: (v) => setState(() => _docType = v!),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _busy ? null : _upload,
            icon: const Icon(Icons.upload_rounded),
            label: Text(_busy ? 'Uploading…' : 'Upload document'),
          ),
          const SizedBox(height: 30),
          const Text('Sent for review',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (!snap.hasData) return const Loading();
              final list = snap.data!;
              if (list.isEmpty) {
                return const Text('Nothing sent yet.',
                    style: TextStyle(color: C.muted));
              }
              return Column(
                children: list.map((d) {
                  final st = d['status'] as String;
                  final color = st == 'approved'
                      ? C.primary
                      : st == 'rejected'
                          ? C.danger
                          : C.warn;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: C.line)),
                    child: Row(children: [
                      Icon(Icons.description_outlined, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                (d['doc_type'] as String)
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 3),
                            Text(
                                st == 'pending'
                                    ? 'Waiting for review'
                                    : st == 'approved'
                                        ? 'Approved'
                                        : 'Rejected — ${d['admin_note'] ?? 'see note'}',
                                style: TextStyle(color: color, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      Text(ago(DateTime.parse(d['created_at'] as String)),
                          style: const TextStyle(fontSize: 11.5, color: C.muted)),
                    ]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
