import 'package:flutter/material.dart';

void main() => runApp(const HomeDirectApp());

// ===========================================================================
// THEME + APP ROOT
// ===========================================================================
const kSeed = Color(0xFF0E7C66);
const kBg = Color(0xFFF6F8F7);
const kBorder = Color(0xFFE2E8E6);

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
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ===========================================================================
// APP-WIDE ROLE STATE (role switcher)
// ===========================================================================
enum AppRole { tenant, owner, admin }

final ValueNotifier<AppRole> currentRole = ValueNotifier(AppRole.tenant);

// ===========================================================================
// MODELS + MOCK DATA
// ===========================================================================
class Property {
  final String id, title, area, city, type, description, houseRules;
  final String ownerName, memberSince, responseTime;
  final int price, deposit, beds, baths, sizeSqm, views;
  final double rating, ownerRating;
  final int reviews;
  final List<String> images, amenities, leaseOptions;
  final bool ownerVerified;
  String status; // Published / Draft / Pending
  bool isFavorite;
  Property({
    required this.id,
    required this.title,
    required this.area,
    required this.city,
    required this.type,
    required this.description,
    required this.houseRules,
    required this.ownerName,
    required this.memberSince,
    required this.responseTime,
    required this.price,
    required this.deposit,
    required this.beds,
    required this.baths,
    required this.sizeSqm,
    required this.views,
    required this.rating,
    required this.ownerRating,
    required this.reviews,
    required this.images,
    required this.amenities,
    required this.leaseOptions,
    required this.ownerVerified,
    this.status = 'Published',
    this.isFavorite = false,
  });
}

String _img(String s) => 'https://picsum.photos/seed/$s/900/700';

final List<Property> properties = [
  Property(
    id: 'p1',
    title: 'Sunny 2-Bedroom Apartment',
    area: 'Kacyiru',
    city: 'Kigali',
    type: 'Apartment',
    description:
        'Bright, airy apartment minutes from the city centre. Newly painted, '
        'tiled floors and a private balcony overlooking the hills.',
    houseRules: 'No smoking indoors. No loud music after 10pm. Pets on request.',
    ownerName: 'Aline U.',
    memberSince: '2023',
    responseTime: '~1 hour',
    price: 450000,
    deposit: 900000,
    beds: 2,
    baths: 1,
    sizeSqm: 78,
    views: 340,
    rating: 4.8,
    ownerRating: 4.9,
    reviews: 32,
    images: [_img('hd-a1'), _img('hd-a2'), _img('hd-a3')],
    amenities: ['Wifi', 'Parking', 'Water', 'Security', 'Furnished'],
    leaseOptions: ['6 months', '1 year'],
    ownerVerified: true,
  ),
  Property(
    id: 'p2',
    title: 'Modern Studio Near ALU',
    area: 'Nyarutarama',
    city: 'Kigali',
    type: 'Studio',
    description:
        'Compact, fully-furnished studio perfect for students or young '
        'professionals. Walking distance to shops and transport.',
    houseRules: 'No smoking. Quiet hours after 10pm.',
    ownerName: 'Jean-Paul M.',
    memberSince: '2024',
    responseTime: '~2 hours',
    price: 220000,
    deposit: 440000,
    beds: 1,
    baths: 1,
    sizeSqm: 34,
    views: 210,
    rating: 4.6,
    ownerRating: 4.7,
    reviews: 18,
    images: [_img('hd-b1'), _img('hd-b2')],
    amenities: ['Wifi', 'Water', 'Furnished', 'Security'],
    leaseOptions: ['3 months', '6 months', '1 year'],
    ownerVerified: true,
  ),
  Property(
    id: 'p3',
    title: 'Spacious Family House',
    area: 'Kibagabaga',
    city: 'Kigali',
    type: 'House',
    description:
        'Standalone family home with a large garden and gated parking for two '
        'cars. Backup generator and borehole water.',
    houseRules: 'Family-friendly. Garden to be kept tidy. No subletting.',
    ownerName: 'Grace K.',
    memberSince: '2022',
    responseTime: '~30 min',
    price: 1200000,
    deposit: 2400000,
    beds: 4,
    baths: 3,
    sizeSqm: 210,
    views: 512,
    rating: 4.9,
    ownerRating: 5.0,
    reviews: 47,
    images: [_img('hd-c1'), _img('hd-c2'), _img('hd-c3')],
    amenities: ['Parking', 'Water', 'Security', 'Generator', 'Pet-friendly'],
    leaseOptions: ['1 year', '2 years'],
    ownerVerified: true,
  ),
  Property(
    id: 'p4',
    title: 'Cozy 1-Bedroom Flat',
    area: 'Remera',
    city: 'Kigali',
    type: 'Apartment',
    description:
        'Well-kept one-bedroom flat close to the bus terminal and markets. '
        'Great value for a central location.',
    houseRules: 'No smoking indoors.',
    ownerName: 'Eric N.',
    memberSince: '2024',
    responseTime: '~3 hours',
    price: 300000,
    deposit: 600000,
    beds: 1,
    baths: 1,
    sizeSqm: 45,
    views: 132,
    rating: 4.4,
    ownerRating: 4.3,
    reviews: 12,
    images: [_img('hd-d1'), _img('hd-d2')],
    amenities: ['Wifi', 'Water', 'Security'],
    leaseOptions: ['6 months', '1 year'],
    ownerVerified: false,
    status: 'Pending',
  ),
  Property(
    id: 'p5',
    title: 'Executive 3-Bedroom Apartment',
    area: 'Kimihurura',
    city: 'Kigali',
    type: 'Apartment',
    description:
        'Upscale apartment in a prime location with lift access, AC and secure '
        'underground parking. Finished to a high standard.',
    houseRules: 'No smoking. No parties. Respect neighbours.',
    ownerName: 'Patrick H.',
    memberSince: '2021',
    responseTime: '~1 hour',
    price: 900000,
    deposit: 1800000,
    beds: 3,
    baths: 2,
    sizeSqm: 145,
    views: 421,
    rating: 4.9,
    ownerRating: 4.8,
    reviews: 55,
    images: [_img('hd-e1'), _img('hd-e2'), _img('hd-e3')],
    amenities: ['Wifi', 'Parking', 'Water', 'Security', 'AC', 'Generator'],
    leaseOptions: ['1 year'],
    ownerVerified: true,
  ),
  Property(
    id: 'p6',
    title: 'Furnished Room, Shared House',
    area: 'Nyamirambo',
    city: 'Kigali',
    type: 'Room',
    description:
        'Private furnished room in a friendly shared house. Shared kitchen and '
        'lounge. Bills included.',
    houseRules: 'Shared spaces kept clean. No overnight guests without notice.',
    ownerName: 'Sandrine B.',
    memberSince: '2023',
    responseTime: '~4 hours',
    price: 150000,
    deposit: 150000,
    beds: 1,
    baths: 1,
    sizeSqm: 20,
    views: 98,
    rating: 4.5,
    ownerRating: 4.6,
    reviews: 9,
    images: [_img('hd-f1'), _img('hd-f2')],
    amenities: ['Wifi', 'Water', 'Furnished'],
    leaseOptions: ['3 months', '6 months'],
    ownerVerified: true,
    status: 'Draft',
  ),
];

class Booking {
  final Property property;
  final String tenantName;
  String status;
  final String moveIn, moveOut;
  Booking(this.property, this.status, this.moveIn, this.moveOut,
      {this.tenantName = 'You'});
}

final List<Booking> bookings = [
  Booking(properties[0], 'Active', '01 Mar 2025', '28 Feb 2026'),
  Booking(properties[4], 'Requested', '15 Aug 2025', '14 Aug 2026'),
  Booking(properties[3], 'Completed', '01 Jan 2024', '31 Dec 2024'),
  Booking(properties[1], 'Cancelled', '10 Feb 2025', '09 Aug 2025'),
];

class ChatThreadData {
  final String name;
  final String preview;
  final bool online;
  final List<(String, bool)> messages;
  ChatThreadData(this.name, this.preview, this.online, this.messages);
}

final List<ChatThreadData> chats = [
  ChatThreadData('Aline U.', 'Great, see you at 2pm', true, [
    ('Hi! Is the Kacyiru apartment still available?', true),
    ('Yes it is! Would you like to visit?', false),
    ('That would be great. Tomorrow afternoon?', true),
    ('Great, see you at 2pm', false),
  ]),
  ChatThreadData('Patrick H.', 'The deposit is two months.', false, [
    ('What are the deposit terms?', true),
    ('The deposit is two months.', false),
  ]),
  ChatThreadData('Grace K.', 'You can move in from March.', false, [
    ('When can I move in?', true),
    ('You can move in from March.', false),
  ]),
];

class SavedSearch {
  final String label, summary;
  bool alerts;
  SavedSearch(this.label, this.summary, this.alerts);
}

final List<SavedSearch> savedSearches = [
  SavedSearch('Apartments in Kacyiru', '2 beds under RWF 500,000', true),
  SavedSearch('Studios near ALU', 'Furnished under RWF 300,000', false),
];

String rwf(int a) {
  final s = a.toString();
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

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

// ===========================================================================
// SHARED WIDGETS
// ===========================================================================
class NetImage extends StatelessWidget {
  final String url;
  final double? height, width;
  const NetImage(this.url, {super.key, this.height, this.width});
  @override
  Widget build(BuildContext context) {
    return Image.network(url,
        height: height, width: width, fit: BoxFit.cover,
        loadingBuilder: (c, child, p) {
      if (p == null) return child;
      return Container(
          height: height,
          width: width,
          color: const Color(0xFFE6ECEA),
          child: const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))));
    }, errorBuilder: (c, e, s) {
      return Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF0E7C66), Color(0xFF19A88B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: const Center(
            child: Icon(Icons.home_rounded, color: Colors.white54, size: 40)),
      );
    });
  }
}

Widget card({required Widget child, EdgeInsets? padding}) => Container(
      padding: padding ?? const EdgeInsets.all(14),
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
      child: child,
    );

Widget sectionTitle(String t) =>
    Text(t, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800));

Widget statusChip(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );

Color statusColor(String s) {
  switch (s) {
    case 'Active':
    case 'Confirmed':
    case 'Published':
    case 'Approved':
      return const Color(0xFF0E7C66);
    case 'Requested':
    case 'Payment':
    case 'Pending':
    case 'Draft':
      return Colors.orange.shade700;
    case 'Cancelled':
    case 'Declined':
    case 'Rejected':
      return Colors.red.shade600;
    default:
      return Colors.blueGrey;
  }
}

Widget statCard(IconData icon, String value, String label, Color color) =>
    Expanded(
      child: card(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );

Widget settingTile(BuildContext c, IconData icon, String title,
    {String? sub, Widget? trailing, VoidCallback? onTap, bool danger = false}) {
  final color = danger ? Colors.red : Colors.black87;
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      subtitle: sub == null ? null : Text(sub),
      trailing: trailing ??
          (danger ? null : const Icon(Icons.chevron_right, color: Colors.grey)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: onTap ?? () => snack(c, '$title — coming soon'),
    ),
  );
}

Widget pill(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );

// ===========================================================================
// AUTH & ONBOARDING
// ===========================================================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    void enter(AppRole r) {
      currentRole.value = r;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const RootShell()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.home_rounded,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 28),
              Text('HomeDirect',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)),
              const SizedBox(height: 12),
              Text('Rent directly from owners.\nNo brokers. No hidden fees.',
                  style: TextStyle(
                      fontSize: 17, height: 1.4, color: cs.onSurfaceVariant)),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: const Text('Get started'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: 24),
              Center(
                  child: Text('Preview an experience',
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 13))),
              const SizedBox(height: 10),
              Row(
                children: [
                  _preview(context, 'Tenant', Icons.search,
                      () => enter(AppRole.tenant)),
                  const SizedBox(width: 10),
                  _preview(context, 'Owner', Icons.vpn_key,
                      () => enter(AppRole.owner)),
                  const SizedBox(width: 10),
                  _preview(context, 'Admin', Icons.admin_panel_settings,
                      () => enter(AppRole.admin)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preview(
          BuildContext c, String label, IconData icon, VoidCallback onTap) =>
      Expanded(
        child: OutlinedButton(
          onPressed: onTap,
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _field('Email', hint: 'you@example.com'),
              const SizedBox(height: 16),
              _field('Password',
                  hint: '********',
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () =>
                        snack(context, 'Password reset — coming soon'),
                    child: const Text('Forgot password?')),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const RootShell())),
                child: const Text('Log in'),
              ),
              const SizedBox(height: 18),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or',
                        style: TextStyle(color: Colors.grey.shade500))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 18),
              _oauth(context, 'Continue with Google', Icons.g_mobiledata),
              const SizedBox(height: 10),
              _oauth(context, 'Continue with Apple', Icons.apple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _oauth(BuildContext c, String label, IconData icon) =>
      OutlinedButton.icon(
        onPressed: () => snack(c, '$label — coming soon'),
        icon: Icon(icon),
        label: Text(label),
      );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  AppRole? _role;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create your account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('First, tell us who you are',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 18),
              Row(children: [
                _roleCard('I\'m looking\nfor a home', Icons.search,
                    _role == AppRole.tenant,
                    () => setState(() => _role = AppRole.tenant)),
                const SizedBox(width: 12),
                _roleCard('I own\nproperty', Icons.vpn_key,
                    _role == AppRole.owner,
                    () => setState(() => _role = AppRole.owner)),
              ]),
              const SizedBox(height: 20),
              _field('Full name', hint: 'Jane Doe'),
              const SizedBox(height: 16),
              _field('Email', hint: 'you@example.com'),
              const SizedBox(height: 16),
              _field('Password', hint: 'At least 8 characters', obscure: true),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _role == null
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OtpScreen(role: _role!))),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String t, IconData i, bool sel, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: sel ? cs.primary.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: sel ? cs.primary : kBorder, width: sel ? 2 : 1),
          ),
          child: Column(children: [
            Icon(i, size: 28, color: sel ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(t,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: sel ? cs.primary : cs.onSurface)),
          ]),
        ),
      ),
    );
  }
}

class OtpScreen extends StatelessWidget {
  final AppRole role;
  const OtpScreen({super.key, required this.role});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verify your phone',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('We sent a 6-digit code to your number.',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 28),
              const TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: TextStyle(
                    fontSize: 24,
                    letterSpacing: 12,
                    fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                    counterText: '',
                    hintText: '------',
                    filled: true,
                    fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileSetupScreen(role: role))),
                child: const Text('Verify'),
              ),
              Center(
                  child: TextButton(
                      onPressed: () => snack(context, 'Code resent (mock)'),
                      child: const Text('Resend code'))),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSetupScreen extends StatelessWidget {
  final AppRole role;
  const ProfileSetupScreen({super.key, required this.role});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Complete your profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Add a photo and verify your ID for a trusted badge.',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => snack(context, 'Photo picker — coming soon'),
                  child: Stack(children: [
                    CircleAvatar(
                        radius: 48,
                        backgroundColor: cs.primary.withOpacity(0.12),
                        child: Icon(Icons.person_rounded,
                            size: 48, color: cs.primary)),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                            radius: 16,
                            backgroundColor: cs.primary,
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 16, color: Colors.white))),
                  ]),
                ),
              ),
              const SizedBox(height: 28),
              _field('Phone number', hint: '+250 7XX XXX XXX'),
              const SizedBox(height: 16),
              const Text('ID document (for verification badge)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    snack(context, 'Document upload — coming soon'),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload ID document'),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  currentRole.value = role;
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const RootShell()),
                      (r) => false);
                },
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _field(String label,
    {String? hint, bool obscure = false, Widget? suffix}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffix,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kSeed, width: 1.6)),
        ),
      ),
    ],
  );
}

// ===========================================================================
// ROOT SHELL — swaps experience by role
// ===========================================================================
class RootShell extends StatelessWidget {
  const RootShell({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppRole>(
      valueListenable: currentRole,
      builder: (_, role, __) {
        switch (role) {
          case AppRole.tenant:
            return const TenantShell();
          case AppRole.owner:
            return const OwnerShell();
          case AppRole.admin:
            return const AdminShell();
        }
      },
    );
  }
}

// ===========================================================================
// TENANT SHELL
// ===========================================================================
class TenantShell extends StatefulWidget {
  const TenantShell({super.key});
  @override
  State<TenantShell> createState() => _TenantShellState();
}

class _TenantShellState extends State<TenantShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    const screens = [
      ExploreScreen(),
      SavedScreen(),
      TenantBookingsScreen(),
      ChatsScreen(),
      AccountScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
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
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chats'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Account'),
        ],
      ),
    );
  }
}

// ---- Explore ----
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _filter = 'All';
  final _filters = const ['All', 'Apartment', 'House', 'Studio', 'Room'];
  List<Property> get _visible => _filter == 'All'
      ? properties
      : properties.where((p) => p.type == _filter).toList();

  Future<void> _open(Property p) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final featured = properties.take(3).toList();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi there',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 14)),
                          Row(children: [
                            Icon(Icons.location_on, size: 18, color: cs.primary),
                            const SizedBox(width: 4),
                            const Text('Kigali, Rwanda',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                          ]),
                        ],
                      ),
                    ),
                    CircleAvatar(
                        radius: 22,
                        backgroundColor: cs.primary.withOpacity(0.12),
                        child: Icon(Icons.person, color: cs.primary)),
                  ]),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SearchScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(children: [
                        Icon(Icons.search, color: cs.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Text('Search area, e.g. Kacyiru',
                            style: TextStyle(color: Colors.grey.shade500)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.tune,
                              color: Colors.white, size: 20),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                              border:
                                  Border.all(color: sel ? cs.primary : kBorder),
                            ),
                            child: Text(f,
                                style: TextStyle(
                                    color: sel ? Colors.white : cs.onSurface,
                                    fontWeight: FontWeight.w600)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  sectionTitle('Featured near you'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 232,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => FeaturedCard(
                    property: featured[i],
                    onTap: () => _open(featured[i]),
                    onFav: () => setState(() =>
                        featured[i].isFavorite = !featured[i].isFavorite)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: sectionTitle(
                  _filter == 'All' ? 'All homes' : '$_filter homes'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final p = _visible[i];
              return Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 0, 20, i == _visible.length - 1 ? 24 : 16),
                child: PropertyCard(
                    property: p,
                    onTap: () => _open(p),
                    onFav: () => setState(() => p.isFavorite = !p.isFavorite)),
              );
            }, childCount: _visible.length),
          ),
        ]),
      ),
    );
  }
}

class FeaturedCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap, onFav;
  const FeaturedCard(
      {super.key,
      required this.property,
      required this.onTap,
      required this.onFav});
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
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child:
                      NetImage(property.images.first, height: 140, width: 260)),
              Positioned(
                  top: 10,
                  right: 10,
                  child: FavButton(active: property.isFavorite, onTap: onFav)),
              Positioned(bottom: 10, left: 10, child: pill(property.type)),
            ]),
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
                  Row(children: [
                    Icon(Icons.star, size: 15, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    Text('${property.rating}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text('${property.area}, ${property.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 12))),
                  ]),
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

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap, onFav;
  const PropertyCard(
      {super.key,
      required this.property,
      required this.onTap,
      required this.onFav});
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
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: NetImage(property.images.first, height: 190)),
              Positioned(
                  top: 12,
                  right: 12,
                  child: FavButton(active: property.isFavorite, onTap: onFav)),
              Positioned(top: 12, left: 12, child: pill(property.type)),
              if (property.ownerVerified)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified, size: 14, color: cs.primary),
                      const SizedBox(width: 4),
                      const Text('Verified owner',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16))),
                    Icon(Icons.star, size: 17, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    Text('${property.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 15, color: cs.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text('${property.area}, ${property.city}',
                        style:
                            TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _spec(Icons.bed_outlined, '${property.beds} bed'),
                    const SizedBox(width: 16),
                    _spec(Icons.bathtub_outlined, '${property.baths} bath'),
                    const Spacer(),
                    Text(rwf(property.price),
                        style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    Text('/mo',
                        style:
                            TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spec(IconData i, String l) => Row(children: [
        Icon(i, size: 17, color: Colors.grey.shade600),
        const SizedBox(width: 5),
        Text(l,
            style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ]);
}

class FavButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const FavButton({super.key, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
        ]),
        child: Icon(active ? Icons.favorite : Icons.favorite_border,
            size: 19, color: active ? Colors.redAccent : Colors.black54),
      ),
    );
  }
}

// ---- Search + Filters + Sort + Map/List toggle ----
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _mapView = false;
  String _sort = 'Most relevant';
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder)),
          child: const Row(children: [
            Icon(Icons.search, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
                child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: 'City, neighbourhood, landmark',
                        border: InputBorder.none))),
          ]),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(children: [
              OutlinedButton.icon(
                onPressed: () => _openFilters(context),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Filters'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sort,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                  ),
                  items: const [
                    'Most relevant',
                    'Price: low to high',
                    'Price: high to low',
                    'Newest',
                  ]
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child:
                              Text(s, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() => _sort = v!),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => setState(() => _mapView = !_mapView),
                icon: Icon(_mapView ? Icons.view_list : Icons.map_outlined),
              ),
            ]),
          ),
          Expanded(
            child: _mapView
                ? _mapPlaceholder(cs)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: properties.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => PropertyCard(
                        property: properties[i],
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PropertyDetailScreen(
                                    property: properties[i]))),
                        onFav: () => setState(() => properties[i].isFavorite =
                            !properties[i].isFavorite)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _mapPlaceholder(ColorScheme cs) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFDDE7E3),
            borderRadius: BorderRadius.circular(18)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 56, color: cs.primary),
              const SizedBox(height: 12),
              const Text('Map view',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Pins & clusters render here once\nGoogle Maps is wired in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      );

  void _openFilters(BuildContext context) {
    RangeValues price = const RangeValues(150000, 900000);
    int beds = 0, baths = 0;
    String type = 'Any';
    final selectedAmenities = <String>{};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 16),
                const Text('Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('Price range (RWF / month)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                RangeSlider(
                  values: price,
                  min: 100000,
                  max: 1500000,
                  divisions: 28,
                  labels: RangeLabels(
                      rwf(price.start.round()), rwf(price.end.round())),
                  onChanged: (v) => setSheet(() => price = v),
                ),
                const SizedBox(height: 8),
                const Text('Property type',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Any', 'Apartment', 'House', 'Studio', 'Room']
                      .map((t) => ChoiceChip(
                            label: Text(t),
                            selected: type == t,
                            onSelected: (_) => setSheet(() => type = t),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                _counter('Bedrooms', beds, (v) => setSheet(() => beds = v)),
                _counter('Bathrooms', baths, (v) => setSheet(() => baths = v)),
                const SizedBox(height: 8),
                const Text('Amenities',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    'Wifi', 'Parking', 'Water', 'Furnished', 'Security', 'AC',
                    'Generator', 'Pet-friendly'
                  ]
                      .map((a) => FilterChip(
                            label: Text(a),
                            selected: selectedAmenities.contains(a),
                            onSelected: (s) => setSheet(() => s
                                ? selectedAmenities.add(a)
                                : selectedAmenities.remove(a)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => snack(ctx, 'Move-in date picker (mock)'),
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('Move-in date: Any'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    snack(context, 'Filters applied (mock)');
                  },
                  child: const Text('Show results'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _counter(String label, int value, ValueChanged<int> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline)),
          Text(value == 0 ? 'Any' : '$value+'),
          IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline)),
        ]),
      );
}

// ---- Property Detail ----
class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});
  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _pc = PageController();
  int _page = 0;
  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.white,
          leading: _circle(Icons.arrow_back, () => Navigator.pop(context)),
          actions: [
            _circle(
                p.isFavorite ? Icons.favorite : Icons.favorite_border,
                () => setState(() => p.isFavorite = !p.isFavorite),
                color: p.isFavorite ? Colors.redAccent : Colors.black87),
            _circle(Icons.flag_outlined, () => _reportSheet(context)),
            const SizedBox(width: 4),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              PageView(
                controller: _pc,
                onPageChanged: (i) => setState(() => _page = i),
                children: p.images.map((u) => NetImage(u)).toList(),
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
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(i == _page ? 1 : 0.6),
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  pill(p.type),
                  const Spacer(),
                  Icon(Icons.star, size: 18, color: Colors.amber.shade600),
                  const SizedBox(width: 4),
                  Text('${p.rating}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('  (${p.reviews} reviews)',
                      style:
                          TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ]),
                const SizedBox(height: 12),
                Text(p.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.location_on, size: 17, color: cs.primary),
                  const SizedBox(width: 4),
                  Text('${p.area}, ${p.city}',
                      style:
                          TextStyle(color: cs.onSurfaceVariant, fontSize: 15)),
                ]),
                const SizedBox(height: 18),
                Row(children: [
                  _specBox(Icons.bed_outlined, '${p.beds}', 'Bedrooms', cs),
                  const SizedBox(width: 12),
                  _specBox(
                      Icons.bathtub_outlined, '${p.baths}', 'Bathrooms', cs),
                  const SizedBox(width: 12),
                  _specBox(Icons.square_foot, '${p.sizeSqm}', 'm2', cs),
                ]),
                const SizedBox(height: 20),
                card(
                  child: Column(children: [
                    _kv('Rent', '${rwf(p.price)} / month', cs, bold: true),
                    const Divider(height: 20),
                    _kv('Deposit', rwf(p.deposit), cs),
                    const Divider(height: 20),
                    _kv('Lease options', p.leaseOptions.join(', '), cs),
                  ]),
                ),
                const SizedBox(height: 22),
                const Text('About this home',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(p.description,
                    style: TextStyle(
                        height: 1.5,
                        fontSize: 14.5,
                        color: cs.onSurface.withOpacity(0.8))),
                const SizedBox(height: 22),
                const Text('What this place offers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
                                border: Border.all(color: kBorder)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(amenityIcon(a), size: 18, color: cs.primary),
                              const SizedBox(width: 8),
                              Text(a),
                            ]),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 22),
                const Text('House rules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(p.houseRules,
                    style: TextStyle(
                        height: 1.5, color: cs.onSurface.withOpacity(0.8))),
                const SizedBox(height: 22),
                const Text('Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                      color: const Color(0xFFDDE7E3),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_pin, color: cs.primary, size: 36),
                        Text('${p.area}, ${p.city}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Map loads once Google Maps is wired in',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Availability',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                card(
                  padding: EdgeInsets.zero,
                  child: CalendarDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (d) =>
                        snack(context, 'Selected ${d.day}/${d.month} (mock)'),
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Hosted by',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _ownerCard(context, p),
                const SizedBox(height: 22),
                const Text('Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _review(context, 'Claudine',
                    'Exactly as described. Owner replied fast and move-in was smooth.',
                    5),
                _review(context, 'Yves',
                    'Good location and fair price. Water and security were reliable.',
                    4),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ]),
        child: SafeArea(
          top: false,
          child: Row(children: [
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
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatThreadScreen(
                          data: ChatThreadData(p.ownerName, '', true, [
                        ('Hi, I\'m interested in ${p.title}.', true)
                      ])))),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              child: const Text('Contact'),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => BookingFlowScreen(property: p))),
              style: FilledButton.styleFrom(minimumSize: const Size(150, 52)),
              child: const Text('Request to book'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _circle(IconData i, VoidCallback onTap, {Color? color}) => Padding(
        padding: const EdgeInsets.all(6),
        child: GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(i, color: color ?? Colors.black87, size: 20)),
        ),
      );

  Widget _kv(String k, String v, ColorScheme cs, {bool bold = false}) => Row(
        children: [
          Text(k, style: TextStyle(color: cs.onSurfaceVariant)),
          const Spacer(),
          Text(v,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: bold ? cs.primary : Colors.black87)),
        ],
      );

  Widget _specBox(IconData i, String v, String l, ColorScheme cs) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder)),
          child: Column(children: [
            Icon(i, color: cs.primary, size: 22),
            const SizedBox(height: 6),
            Text(v,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(l, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          ]),
        ),
      );

  Widget _ownerCard(BuildContext context, Property p) {
    final cs = Theme.of(context).colorScheme;
    return card(
      child: Row(children: [
        CircleAvatar(
            radius: 26,
            backgroundColor: cs.primary.withOpacity(0.12),
            child: Icon(Icons.person, color: cs.primary, size: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(p.ownerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(width: 6),
                if (p.ownerVerified)
                  Icon(Icons.verified, size: 16, color: cs.primary),
              ]),
              const SizedBox(height: 3),
              Text(
                  'Rating ${p.ownerRating} - Replies ${p.responseTime} - Member since ${p.memberSince}',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _review(BuildContext context, String name, String text, int stars) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
                radius: 16,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Text(name[0],
                    style: TextStyle(
                        color: cs.primary, fontWeight: FontWeight.w700))),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Row(
                children: List.generate(
                    5,
                    (i) => Icon(Icons.star,
                        size: 14,
                        color: i < stars
                            ? Colors.amber.shade600
                            : Colors.grey.shade300))),
          ]),
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

  void _reportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('Report this listing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...[
              'Fraud / scam',
              'Misrepresentation',
              'Already rented',
              'Inappropriate content'
            ].map((r) => ListTile(
                  title: Text(r),
                  onTap: () {
                    Navigator.pop(ctx);
                    snack(context, 'Reported: $r (mock)');
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---- Booking flow ----
class BookingFlowScreen extends StatefulWidget {
  final Property property;
  const BookingFlowScreen({super.key, required this.property});
  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _step = 0;
  DateTime? _moveIn, _moveOut;
  bool _agreed = false;
  String _payMethod = 'Mobile Money (MTN / Airtel)';
  final _titles = ['Dates', 'Details', 'Agreement', 'Payment'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Book - ${_titles[_step]}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: List.generate(4, (i) {
                final done = i <= _step;
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                        color: done ? cs.primary : const Color(0xFFDDE3E1),
                        borderRadius: BorderRadius.circular(4)),
                  ),
                );
              }),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _body(context, cs),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: FilledButton(
              onPressed: () {
                if (_step < 3) {
                  setState(() => _step++);
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      icon:
                          Icon(Icons.check_circle, color: cs.primary, size: 40),
                      title: const Text('Request sent!'),
                      content: Text(
                          'Your booking request for ${widget.property.title} was sent to ${widget.property.ownerName}. You will be notified when they respond.'),
                      actions: [
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text(_step < 3 ? 'Continue' : 'Confirm & send request'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ColorScheme cs) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('When would you like to move in?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _dateTile(context, 'Move-in date', _moveIn,
                (d) => setState(() => _moveIn = d)),
            const SizedBox(height: 12),
            _dateTile(context, 'Move-out / end date', _moveOut,
                (d) => setState(() => _moveOut = d)),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Message to owner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                  hintText: 'Introduce yourself and any questions',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            _field('Number of occupants', hint: 'e.g. 2'),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rental agreement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sumRow('Property', widget.property.title),
                  _sumRow('Rent', '${rwf(widget.property.price)} / month'),
                  _sumRow('Deposit', rwf(widget.property.deposit)),
                  _sumRow(
                      'Move-in',
                      _moveIn == null
                          ? '-'
                          : '${_moveIn!.day}/${_moveIn!.month}/${_moveIn!.year}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _agreed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: const Text(
                  'I agree to the rental terms and e-sign this agreement'),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...[
              'Mobile Money (MTN / Airtel)',
              'Card',
              'Pay off-platform (upload proof)'
            ].map((m) => RadioListTile<String>(
                  value: m,
                  groupValue: _payMethod,
                  onChanged: (v) => setState(() => _payMethod = v!),
                  title: Text(m),
                  contentPadding: EdgeInsets.zero,
                )),
            const SizedBox(height: 8),
            card(
              child: Column(children: [
                _sumRow('First month rent', rwf(widget.property.price)),
                _sumRow('Deposit', rwf(widget.property.deposit)),
                const Divider(),
                _sumRow('Total due now',
                    rwf(widget.property.price + widget.property.deposit),
                    bold: true),
              ]),
            ),
            const SizedBox(height: 8),
            Text(
                'Payments are processed securely once the provider is wired in.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        );
    }
  }

  Widget _dateTile(BuildContext context, String label, DateTime? value,
      ValueChanged<DateTime> onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder)),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 20),
          const SizedBox(width: 12),
          Text(value == null
              ? label
              : '$label: ${value.day}/${value.month}/${value.year}'),
          const Spacer(),
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }

  Widget _sumRow(String k, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(k, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Text(v,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );
}

// ---- Saved (wishlist + saved searches) ----
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Wishlist'),
            Tab(text: 'Saved searches'),
          ]),
        ),
        body: TabBarView(children: [
          _wishlist(context),
          _searches(context),
        ]),
      ),
    );
  }

  Widget _wishlist(BuildContext context) {
    final saved = properties.where((p) => p.isFavorite).toList();
    if (saved.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.favorite_border, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('No saved homes yet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text('Tap the heart on any listing to save it',
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: saved.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => PropertyCard(
          property: saved[i],
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(property: saved[i]))),
          onFav: () {}),
    );
  }

  Widget _searches(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: savedSearches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final s = savedSearches[i];
        return card(
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kSeed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.saved_search, color: kSeed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.label,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(s.summary,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            _AlertSwitch(search: s),
          ]),
        );
      },
    );
  }
}

class _AlertSwitch extends StatefulWidget {
  final SavedSearch search;
  const _AlertSwitch({required this.search});
  @override
  State<_AlertSwitch> createState() => _AlertSwitchState();
}

class _AlertSwitchState extends State<_AlertSwitch> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Alerts', style: TextStyle(fontSize: 11)),
      Switch(
          value: widget.search.alerts,
          onChanged: (v) => setState(() => widget.search.alerts = v)),
    ]);
  }
}

// ---- Tenant bookings + detail ----
class TenantBookingsScreen extends StatelessWidget {
  const TenantBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    List<Booking> by(List<String> st) =>
        bookings.where((b) => st.contains(b.status)).toList();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My bookings'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Active'),
              Tab(text: 'Past'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _list(context, by(['Requested', 'Confirmed', 'Payment'])),
          _list(context, by(['Active'])),
          _list(context, by(['Completed'])),
          _list(context, by(['Cancelled', 'Declined'])),
        ]),
      ),
    );
  }

  Widget _list(BuildContext context, List<Booking> items) {
    if (items.isEmpty) {
      return Center(
          child: Text('Nothing here yet',
              style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        final b = items[i];
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BookingDetailScreen(booking: b))),
          child: card(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      NetImage(b.property.images.first, height: 76, width: 76)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${b.moveIn} to ${b.moveOut}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 8),
                    statusChip(b.status, statusColor(b.status)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ]),
          ),
        );
      },
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});
  @override
  Widget build(BuildContext context) {
    final steps = ['Requested', 'Confirmed', 'Payment', 'Active', 'Completed'];
    final order = {
      'Requested': 0,
      'Confirmed': 1,
      'Payment': 2,
      'Active': 3,
      'Completed': 4,
      'Cancelled': -1,
      'Declined': -1,
    };
    final current = order[booking.status] ?? 0;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NetImage(booking.property.images.first, height: 170)),
          const SizedBox(height: 14),
          Text(booking.property.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('${booking.property.area}, ${booking.property.city}',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 18),
          const Text('Status',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          if (current < 0)
            statusChip(booking.status, statusColor(booking.status))
          else
            Column(
              children: List.generate(steps.length, (i) {
                final done = i <= current;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            done ? cs.primary : const Color(0xFFDDE3E1),
                        child: Icon(done ? Icons.check : Icons.circle,
                            size: 12, color: Colors.white),
                      ),
                      if (i < steps.length - 1)
                        Container(
                            width: 2,
                            height: 26,
                            color: i < current
                                ? cs.primary
                                : const Color(0xFFDDE3E1)),
                    ]),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(steps[i],
                          style: TextStyle(
                              fontWeight:
                                  done ? FontWeight.w700 : FontWeight.w400,
                              color: done ? Colors.black : Colors.grey)),
                    ),
                  ],
                );
              }),
            ),
          const SizedBox(height: 20),
          const Text('Lease terms',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          card(
            child: Column(children: [
              _row('Move-in', booking.moveIn),
              const Divider(),
              _row('Move-out', booking.moveOut),
              const Divider(),
              _row('Rent', '${rwf(booking.property.price)} / month'),
              const Divider(),
              _row('Deposit', rwf(booking.property.deposit)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Payments',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          card(
            child: Column(children: [
              _row('Deposit', 'Paid'),
              const Divider(),
              _row('March rent', 'Paid'),
              const Divider(),
              _row('April rent', 'Due 01 Apr'),
            ]),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => snack(context, 'Downloading agreement (mock)'),
            icon: const Icon(Icons.download),
            label: const Text('Download agreement (PDF)'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => snack(context, 'Reschedule request (mock)'),
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('Request reschedule'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => snack(context, 'Cancellation request (mock)'),
            icon: const Icon(Icons.close),
            label: const Text('Cancel booking'),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Row(children: [
        Text(k, style: TextStyle(color: Colors.grey.shade700)),
        const Spacer(),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]);
}

// ---- Chats ----
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
        itemBuilder: (_, i) {
          final c = chats[i];
          return ListTile(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ChatThreadScreen(data: c))),
            leading: Stack(children: [
              CircleAvatar(
                  radius: 26,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  child: Text(c.name[0],
                      style: TextStyle(
                          color: cs.primary, fontWeight: FontWeight.w700))),
              if (c.online)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
            ]),
            title: Text(c.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle:
                Text(c.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text('2:14 PM',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          );
        },
      ),
    );
  }
}

class ChatThreadScreen extends StatefulWidget {
  final ChatThreadData data;
  const ChatThreadScreen({super.key, required this.data});
  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late List<(String, bool)> _messages;
  final _ctrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.data.messages);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add((_ctrl.text.trim(), true));
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary.withOpacity(0.12),
              child: Text(widget.data.name[0],
                  style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14))),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.data.name, style: const TextStyle(fontSize: 16)),
              Text(widget.data.online ? 'Online' : 'Offline',
                  style: TextStyle(
                      fontSize: 11,
                      color:
                          widget.data.online ? Colors.green : Colors.grey)),
            ],
          ),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final mine = m.$2;
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: mine ? cs.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: mine ? null : Border.all(color: kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(m.$1,
                            style: TextStyle(
                                color: mine ? Colors.white : Colors.black87)),
                        if (mine)
                          const Text('read',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 9)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                top: 6),
            child: Row(children: [
              IconButton(
                  onPressed: () => snack(context, 'Attach file (mock)'),
                  icon: const Icon(Icons.attach_file)),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                backgroundColor: cs.primary,
                child: IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Colors.white)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ---- Account (shared settings + role switch) ----
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            CircleAvatar(
                radius: 34,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(Icons.person, size: 36, color: cs.primary)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Syhff',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  Icon(Icons.verified, size: 18, color: cs.primary),
                ]),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('Verified',
                      style: TextStyle(
                          color: cs.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 24),
          settingTile(context, Icons.person_outline, 'Edit profile'),
          settingTile(
              context, Icons.verified_user_outlined, 'Verification status',
              sub: 'Verified'),
          settingTile(context, Icons.notifications_outlined,
              'Notification preferences',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotifPrefsScreen()))),
          settingTile(context, Icons.language, 'Language & currency',
              sub: 'English - RWF',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen()))),
          settingTile(context, Icons.help_outline, 'Help & FAQ',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()))),
          settingTile(context, Icons.privacy_tip_outlined,
              'Data export & account deletion'),
          const SizedBox(height: 8),
          const Text('Switch experience',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(children: [
            _roleBtn(context, 'Tenant', Icons.search, AppRole.tenant),
            const SizedBox(width: 8),
            _roleBtn(context, 'Owner', Icons.vpn_key, AppRole.owner),
            const SizedBox(width: 8),
            _roleBtn(
                context, 'Admin', Icons.admin_panel_settings, AppRole.admin),
          ]),
          const SizedBox(height: 16),
          settingTile(context, Icons.logout, 'Log out',
              danger: true,
              onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (r) => false)),
        ],
      ),
    );
  }

  Widget _roleBtn(
          BuildContext c, String label, IconData icon, AppRole role) =>
      Expanded(
        child: OutlinedButton(
          onPressed: () => currentRole.value = role,
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
          child:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      );
}

class NotifPrefsScreen extends StatefulWidget {
  const NotifPrefsScreen({super.key});
  @override
  State<NotifPrefsScreen> createState() => _NotifPrefsScreenState();
}

class _NotifPrefsScreenState extends State<NotifPrefsScreen> {
  final Map<String, bool> _p = {
    'Push notifications': true,
    'Email': true,
    'SMS': false,
    'Booking updates': true,
    'New messages': true,
    'Price drops on saved homes': true,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _p.keys
            .map((k) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                  child: SwitchListTile(
                    title: Text(k),
                    value: _p[k]!,
                    onChanged: (v) => setState(() => _p[k] = v),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _lang = 'English';
  String _currency = 'RWF - Rwandan Franc';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language & currency')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Language', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...['English', 'Kinyarwanda', 'Francais'].map((l) => RadioListTile(
              value: l,
              groupValue: _lang,
              onChanged: (v) => setState(() => _lang = v!),
              title: Text(l))),
          const SizedBox(height: 12),
          const Text('Currency', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...['RWF - Rwandan Franc', 'USD - US Dollar', 'KES - Kenyan Shilling']
              .map((c) => RadioListTile(
                  value: c,
                  groupValue: _currency,
                  onChanged: (v) => setState(() => _currency = v!),
                  title: Text(c))),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final faqs = {
      'How does HomeDirect work?':
          'You rent directly from verified owners - no brokers, no hidden fees.',
      'Is my deposit safe?':
          'Deposits are held and released according to the agreed terms in your lease.',
      'How do I get verified?':
          'Upload an ID document in your profile; our team reviews it for a verified badge.',
      'How are owners vetted?':
          'Owners submit proof of ownership which is reviewed before a listing is published.',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...faqs.entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14)),
                child: ExpansionTile(
                  shape: const Border(),
                  title: Text(e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                        alignment: Alignment.centerLeft, child: Text(e.value))
                  ],
                ),
              )),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => snack(context, 'Support ticket (mock)'),
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact support'),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// OWNER SHELL
// ===========================================================================
class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});
  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    const screens = [
      OwnerDashboard(),
      OwnerListings(),
      OwnerRequests(),
      OwnerEarnings(),
      AccountScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              selectedIcon: Icon(Icons.home_work),
              label: 'Listings'),
          NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox),
              label: 'Requests'),
          NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: 'Earnings'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Account'),
        ],
      ),
    );
  }
}

// ---- Owner dashboard ----
class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final published = properties.where((p) => p.status == 'Published').length;
    final totalViews = properties.fold<int>(0, (s, p) => s + p.views);
    final requests = bookings.where((b) => b.status == 'Requested').length;
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Welcome back, Syhff',
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          const Text('Here is how your properties are doing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          Row(children: [
            statCard(Icons.home_work, '$published', 'Active listings',
                cs.primary),
            const SizedBox(width: 12),
            statCard(Icons.visibility, '$totalViews', 'Total views',
                Colors.blue.shade600),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            statCard(Icons.inbox, '$requests', 'New requests',
                Colors.orange.shade700),
            const SizedBox(width: 12),
            statCard(Icons.percent, '82%', 'Occupancy', Colors.purple.shade400),
          ]),
          const SizedBox(height: 24),
          sectionTitle('Earnings summary'),
          const SizedBox(height: 12),
          card(
            child: Column(children: [
              _er('Gross rent collected', rwf(4350000), cs, bold: true),
              const Divider(height: 20),
              _er('Platform commission (5%)', '- ${rwf(217500)}', cs),
              const Divider(height: 20),
              _er('Net payout', rwf(4132500), cs, highlight: true),
            ]),
          ),
          const SizedBox(height: 24),
          sectionTitle('Listing performance'),
          const SizedBox(height: 12),
          ...properties.take(4).map((p) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: card(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetImage(p.images.first, height: 54, width: 54)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text('${p.views} views  -  ${p.reviews} inquiries',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    statusChip(p.status, statusColor(p.status)),
                  ]),
                ),
              )),
        ],
      ),
    );
  }

  Widget _er(String k, String v, ColorScheme cs,
          {bool bold = false, bool highlight = false}) =>
      Row(children: [
        Text(k, style: TextStyle(color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(v,
            style: TextStyle(
                fontSize: highlight ? 18 : 14,
                fontWeight:
                    (bold || highlight) ? FontWeight.w800 : FontWeight.w600,
                color: highlight ? cs.primary : Colors.black87)),
      ]);
}

// ---- Owner listings ----
class OwnerListings extends StatefulWidget {
  const OwnerListings({super.key});
  @override
  State<OwnerListings> createState() => _OwnerListingsState();
}

class _OwnerListingsState extends State<OwnerListings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddPropertyWizard())),
        icon: const Icon(Icons.add),
        label: const Text('Add property'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
        itemCount: properties.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final p = properties[i];
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ListingManageScreen(property: p))),
            child: card(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: NetImage(p.images.first, height: 72, width: 72)),
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
                      Text('${rwf(p.price)} / month',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(children: [
                        statusChip(p.status, statusColor(p.status)),
                        const SizedBox(width: 8),
                        if (p.ownerVerified)
                          Icon(Icons.verified,
                              size: 15,
                              color: Theme.of(context).colorScheme.primary),
                      ]),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ---- Add property wizard ----
class AddPropertyWizard extends StatefulWidget {
  const AddPropertyWizard({super.key});
  @override
  State<AddPropertyWizard> createState() => _AddPropertyWizardState();
}

class _AddPropertyWizardState extends State<AddPropertyWizard> {
  int _step = 0;
  final _steps = [
    'Basics',
    'Location',
    'Details',
    'Amenities',
    'House rules',
    'Photos',
    'Verification',
    'Review'
  ];
  final _amenities = <String>{};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Add property - ${_steps[_step]}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: List.generate(_steps.length, (i) {
                final done = i <= _step;
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                        color: done ? cs.primary : const Color(0xFFDDE3E1),
                        borderRadius: BorderRadius.circular(4)),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _body(context, cs),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (_step < _steps.length - 1) {
                      setState(() => _step++);
                    } else {
                      Navigator.pop(context);
                      snack(context, 'Listing saved as draft (mock)');
                    }
                  },
                  child: Text(
                      _step < _steps.length - 1 ? 'Continue' : 'Publish'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ColorScheme cs) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Title', hint: 'e.g. Sunny 2-bedroom apartment'),
            const SizedBox(height: 16),
            const Text('Property type',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Apartment', 'House', 'Studio', 'Room']
                  .map((t) => ChoiceChip(
                      label: Text(t), selected: t == 'Apartment', onSelected: (_) {}))
                  .toList(),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Address', hint: 'Street / KG 000 St'),
            const SizedBox(height: 16),
            _field('Neighbourhood', hint: 'e.g. Kacyiru'),
            const SizedBox(height: 16),
            Container(
              height: 160,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDE7E3),
                  borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_location_alt_outlined,
                      size: 40, color: cs.primary),
                  const Text('Drop a pin to confirm location'),
                  Text('(Map picker once Google Maps is wired in)',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                ]),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: _field('Bedrooms', hint: '2')),
              const SizedBox(width: 12),
              Expanded(child: _field('Bathrooms', hint: '1')),
            ]),
            const SizedBox(height: 16),
            _field('Size (m2)', hint: '78'),
            const SizedBox(height: 16),
            _field('Monthly rent (RWF)', hint: '450000'),
            const SizedBox(height: 16),
            _field('Deposit (RWF)', hint: '900000'),
            const SizedBox(height: 16),
            const Text('Lease options',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['3 months', '6 months', '1 year', '2 years']
                  .map((t) => FilterChip(
                      label: Text(t), selected: false, onSelected: (_) {}))
                  .toList(),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select all that apply',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Wifi', 'Parking', 'Water', 'Furnished', 'Security', 'AC',
                'Generator', 'Pet-friendly'
              ]
                  .map((a) => FilterChip(
                        avatar: Icon(amenityIcon(a), size: 18),
                        label: Text(a),
                        selected: _amenities.contains(a),
                        onSelected: (s) => setState(() =>
                            s ? _amenities.add(a) : _amenities.remove(a)),
                      ))
                  .toList(),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('House rules',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
              maxLines: 6,
              decoration: InputDecoration(
                  hintText:
                      'e.g. No smoking indoors. Quiet hours after 10pm.',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder()),
            ),
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Photos',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('First photo is the cover. Drag to reorder once added.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                GestureDetector(
                  onTap: () => snack(context, 'Photo picker (mock)'),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder)),
                    child: const Icon(Icons.add_a_photo_outlined,
                        color: Colors.grey),
                  ),
                ),
                ...List.generate(
                    2,
                    (i) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: NetImage(_img('hd-new$i')))),
              ],
            ),
          ],
        );
      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Proof of ownership',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
                'Upload a title deed or utility bill. Our team reviews it before your "Verified" badge is granted.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => snack(context, 'Document upload (mock)'),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload ownership document'),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review your listing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Everything look good?',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text(
                      'Publish now to go live, or save as a draft to finish later. New listings enter verification before appearing in search.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                snack(context, 'Saved as draft (mock)');
              },
              child: const Text('Save as draft'),
            ),
          ],
        );
    }
  }
}

// ---- Listing manage ----
class ListingManageScreen extends StatefulWidget {
  final Property property;
  const ListingManageScreen({super.key, required this.property});
  @override
  State<ListingManageScreen> createState() => _ListingManageScreenState();
}

class _ListingManageScreenState extends State<ListingManageScreen> {
  late bool _published = widget.property.status == 'Published';
  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage listing'), actions: [
        IconButton(
            onPressed: () => snack(context, 'Edit listing (mock)'),
            icon: const Icon(Icons.edit_outlined)),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NetImage(p.images.first, height: 170)),
          const SizedBox(height: 14),
          Text(p.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('${p.area}, ${p.city}  -  ${rwf(p.price)}/mo',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          card(
            child: Column(children: [
              Row(children: [
                const Expanded(
                    child: Text('Published',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Switch(
                    value: _published,
                    onChanged: (v) {
                      setState(() {
                        _published = v;
                        p.status = v ? 'Published' : 'Draft';
                      });
                    }),
              ]),
              const Divider(),
              Row(children: [
                const Expanded(child: Text('Verification')),
                if (p.ownerVerified)
                  Row(children: [
                    Icon(Icons.verified, size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    const Text('Verified'),
                  ])
                else
                  TextButton(
                      onPressed: () =>
                          snack(context, 'Verification submitted (mock)'),
                      child: const Text('Submit docs')),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            statCard(Icons.visibility, '${p.views}', 'Views', Colors.blue.shade600),
            const SizedBox(width: 12),
            statCard(Icons.chat_bubble_outline, '${p.reviews}', 'Inquiries',
                Colors.orange.shade700),
          ]),
          const SizedBox(height: 20),
          sectionTitle('Availability'),
          const SizedBox(height: 4),
          Text('Tap dates to block them (e.g. already rented).',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 8),
          card(
            padding: EdgeInsets.zero,
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (d) =>
                  snack(context, 'Blocked ${d.day}/${d.month} (mock)'),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => snack(context, 'Delete listing (mock)'),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete listing'),
          ),
        ],
      ),
    );
  }
}

// ---- Owner requests + tenancies ----
class OwnerRequests extends StatelessWidget {
  const OwnerRequests({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Booking requests'),
            Tab(text: 'Active tenancies'),
          ]),
        ),
        body: TabBarView(children: [
          _requests(context),
          _tenancies(context),
        ]),
      ),
    );
  }

  Widget _requests(BuildContext context) {
    final reqs = ['Jean Bosco', 'Marie Claire'];
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: reqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final p = properties[i];
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      RequestDetailScreen(tenant: reqs[i], property: p))),
          child: card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.12),
                      child: Text(reqs[i][0],
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(reqs[i],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          Icon(Icons.verified,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary),
                        ]),
                        Text('wants to book ${p.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  statusChip('Requested', statusColor('Requested')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: const Size(0, 42)),
                      onPressed: () => _declineDialog(context),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 42)),
                      onPressed: () => snack(context, 'Request accepted (mock)'),
                      child: const Text('Accept'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tenancies(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(properties[0].title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15))),
                statusChip('Active', statusColor('Active')),
              ]),
              const SizedBox(height: 4),
              Text('Tenant: Aline U.  -  until 28 Feb 2026',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => snack(context, 'Renew tenancy (mock)'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                    child: const Text('Renew'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => snack(context, 'Marked complete (mock)'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                    child: const Text('Complete'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  void _declineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline request'),
        content: const TextField(
          decoration: InputDecoration(hintText: 'Reason (optional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                snack(context, 'Request declined (mock)');
              },
              child: const Text('Decline')),
        ],
      ),
    );
  }
}

class RequestDetailScreen extends StatelessWidget {
  final String tenant;
  final Property property;
  const RequestDetailScreen(
      {super.key, required this.tenant, required this.property});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking request')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          card(
            child: Row(children: [
              CircleAvatar(
                  radius: 30,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  child: Text(tenant[0],
                      style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 22))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(tenant,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 6),
                      Icon(Icons.verified, size: 16, color: cs.primary),
                    ]),
                    const SizedBox(height: 2),
                    Text('Rating 4.7  -  Verified ID  -  Member since 2024',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          sectionTitle('Requested property'),
          const SizedBox(height: 10),
          card(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NetImage(property.images.first, height: 56, width: 56)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${rwf(property.price)} / month  -  move-in 15 Aug',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          sectionTitle('Message'),
          const SizedBox(height: 10),
          card(
            child: const Text(
                'Hello! I am relocating to Kigali for work and your place looks perfect. I can move in mid-August for a one-year lease. Happy to share references.'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatThreadScreen(
                        data: ChatThreadData(tenant, '', true,
                            [('Hi, thanks for your request!', true)])))),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Message tenant'),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => snack(context, 'Declined (mock)'),
                child: const Text('Decline'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => snack(context, 'Accepted (mock)'),
                child: const Text('Accept'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ---- Owner earnings ----
class OwnerEarnings extends StatelessWidget {
  const OwnerEarnings({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ledger = [
      ('Kacyiru apartment', 450000, 22500),
      ('Kimihurura apartment', 900000, 45000),
      ('Kibagabaga house', 1200000, 60000),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          card(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net payout this month',
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(rwf(4132500),
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: cs.primary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          sectionTitle('Payout method'),
          const SizedBox(height: 10),
          settingTile(context, Icons.smartphone, 'Mobile Money',
              sub: 'MTN - +250 7XX XXX XXX'),
          settingTile(context, Icons.account_balance, 'Bank account',
              sub: 'Add a bank account'),
          const SizedBox(height: 12),
          sectionTitle('Commission ledger'),
          const SizedBox(height: 4),
          Text('Rent collected minus 5% platform commission = your payout.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          ...ledger.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.$1,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _lr('Rent collected', rwf(e.$2)),
                      _lr('Commission (5%)', '- ${rwf(e.$3)}'),
                      const Divider(),
                      _lr('Net payout', rwf(e.$2 - e.$3), bold: true),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => snack(context, 'Invoice history (mock)'),
            icon: const Icon(Icons.receipt_long),
            label: const Text('View invoice history'),
          ),
        ],
      ),
    );
  }

  Widget _lr(String k, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(k, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Text(v,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );
}

// ===========================================================================
// ADMIN SHELL
// ===========================================================================
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    const screens = [
      AdminOverview(),
      AdminVerify(),
      AdminDisputes(),
      AdminModeration(),
      AccountScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Overview'),
          NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified),
              label: 'Verify'),
          NavigationDestination(
              icon: Icon(Icons.gavel_outlined),
              selectedIcon: Icon(Icons.gavel),
              label: 'Disputes'),
          NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Moderation'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Account'),
        ],
      ),
    );
  }
}

// ---- Admin overview ----
class AdminOverview extends StatelessWidget {
  const AdminOverview({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bars = [40.0, 55.0, 48.0, 70.0, 65.0, 85.0, 92.0];
    final maxBar = bars.reduce((a, b) => a > b ? a : b);
    return Scaffold(
      appBar: AppBar(title: const Text('Platform overview')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            statCard(Icons.trending_up, 'RWF 18.4M', 'GMV (30d)', cs.primary),
            const SizedBox(width: 12),
            statCard(Icons.home_work, '1,204', 'Active listings',
                Colors.blue.shade600),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            statCard(Icons.payments, 'RWF 920K', 'Commission (30d)',
                Colors.green.shade700),
            const SizedBox(width: 12),
            statCard(Icons.group, '8,530', 'Total users',
                Colors.orange.shade700),
          ]),
          const SizedBox(height: 24),
          sectionTitle('User growth'),
          const SizedBox(height: 12),
          card(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bars
                        .map((b) => Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 130 * (b / maxBar),
                                decoration: BoxDecoration(
                                    color: cs.primary
                                        .withOpacity(0.35 + 0.65 * (b / maxBar)),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6))),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map((d) => Text(d,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          sectionTitle('Needs attention'),
          const SizedBox(height: 12),
          _attn(context, Icons.verified_outlined, '7 verifications pending',
              Colors.orange.shade700),
          _attn(context, Icons.gavel_outlined, '2 open disputes',
              Colors.red.shade600),
          _attn(context, Icons.flag_outlined, '4 flagged items',
              Colors.purple.shade400),
        ],
      ),
    );
  }

  Widget _attn(BuildContext c, IconData icon, String label, Color color) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: card(
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      );
}

// ---- Admin verify ----
class AdminVerify extends StatelessWidget {
  const AdminVerify({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verification queue'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Properties'),
            Tab(text: 'Identities'),
          ]),
        ),
        body: TabBarView(children: [
          _propQueue(context),
          _idQueue(context),
        ]),
      ),
    );
  }

  Widget _propQueue(BuildContext context) {
    final queue = properties.where((p) => !p.ownerVerified).toList()
      ..addAll(properties.take(2));
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: queue.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final p = queue[i];
        return card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: NetImage(p.images.first, height: 56, width: 56)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('by ${p.ownerName}  -  ownership doc submitted',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _approveRow(context),
            ],
          ),
        );
      },
    );
  }

  Widget _idQueue(BuildContext context) {
    final ids = ['Jean Bosco', 'Marie Claire', 'Patrick H.'];
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: ids.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.12),
                  child: Text(ids[i][0],
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ids[i],
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('National ID submitted',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _approveRow(context),
          ],
        ),
      ),
    );
  }

  Widget _approveRow(BuildContext context) => Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red, minimumSize: const Size(0, 42)),
            onPressed: () => snack(context, 'Rejected (mock)'),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Reject'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
            onPressed: () => snack(context, 'Approved (mock)'),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Approve'),
          ),
        ),
      ]);
}

// ---- Admin disputes ----
class AdminDisputes extends StatelessWidget {
  const AdminDisputes({super.key});
  @override
  Widget build(BuildContext context) {
    final disputes = [
      ('Deposit not refunded', 'Aline U. vs Eric N.', 'Payment'),
      ('Listing misrepresented', 'Marie Claire vs Patrick H.', 'Listing'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: disputes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final d = disputes[i];
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DisputeDetailScreen(title: d.$1, parties: d.$2))),
            child: card(
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.gavel, color: Colors.red.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.$1,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(d.$2,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                statusChip('Open', Colors.orange.shade700),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class DisputeDetailScreen extends StatelessWidget {
  final String title, parties;
  const DisputeDetailScreen(
      {super.key, required this.title, required this.parties});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispute')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(parties, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          sectionTitle('Case summary'),
          const SizedBox(height: 10),
          card(
            child: const Text(
                'Tenant reports the deposit was not refunded within the agreed 14 days after moving out. Owner claims deductions for cleaning. Both parties have submitted evidence via chat attachments.'),
          ),
          const SizedBox(height: 20),
          sectionTitle('Resolution'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => snack(context, 'Commission waived (mock)'),
            icon: const Icon(Icons.money_off),
            label: const Text('Adjust / waive commission'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => snack(context, 'Refund ordered (mock)'),
            icon: const Icon(Icons.replay),
            label: const Text('Order partial refund'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => snack(context, 'Dispute resolved (mock)'),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark resolved'),
          ),
        ],
      ),
    );
  }
}

// ---- Admin moderation ----
class AdminModeration extends StatelessWidget {
  const AdminModeration({super.key});
  @override
  Widget build(BuildContext context) {
    final flags = [
      (Icons.photo_outlined, 'Photo flagged as misleading', 'Kimihurura apartment'),
      (Icons.rate_review_outlined, 'Review flagged as spam', 'by user #4821'),
      (Icons.message_outlined, 'Message reported as abusive', 'in chat #A19'),
      (Icons.report_gmailerrorred_outlined, 'Listing reported as fraud',
          'Remera flat'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Content moderation')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: flags.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final f = flags[i];
          return card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(f.$1, color: Colors.purple.shade400),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$2,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(f.$3,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 42)),
                      onPressed: () => snack(context, 'Kept (mock)'),
                      child: const Text('Keep'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 42),
                          backgroundColor: Colors.red),
                      onPressed: () => snack(context, 'Removed (mock)'),
                      child: const Text('Remove'),
                    ),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
