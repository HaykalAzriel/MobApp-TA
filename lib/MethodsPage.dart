import 'package:figma/Loading.dart';
import 'package:figma/Loading.dart';
import 'package:figma/Settings.dart';
import 'package:figma/image_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MethodsPage extends StatefulWidget {
  const MethodsPage({super.key});

  @override
  State<MethodsPage> createState() => _MethodsPageState();
}

class _MethodsPageState extends State<MethodsPage> {
  String? username;
  String? avatarUrl;

  String? _chosenEmbedMethod;
  String? _chosenAttack;
  String? _chosenML;
  String? _chosenDL;

  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final response =
          await Supabase.instance.client
              .from('profiles')
              .select('username, avatar_url')
              .eq('id', userId)
              .single();

      setState(() {
        username = response['username'] ?? 'Capstone Design';
        avatarUrl = response['avatar_url'];
      });
    }
  }

  void _showMethodDialog(BuildContext context) {
    final methods = [
      "DWT-DST-QRD-SS",
      "DWT-DST-SVD-SS",
      "DWT-DCT-SVD-SS",
      "DWT-DCT-QRD-SS",
    ];

    String? selectedMethod; // untuk menyimpan metode terpilih

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Color(0xFF67EFC4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFF0004FF), // warna border dialog
              width: 2, // ketebalan border
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Methods",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Choose your preferred embedding technique",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 30),
                // Dropdown
                DropdownButtonFormField<String>(
                  value: _chosenEmbedMethod,
                  items:
                      methods
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _chosenEmbedMethod = val),
                  decoration: InputDecoration(
                    labelText: "Select embedding method",
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), // warna teks label
                    ),
                    border: OutlineInputBorder(
                      // fallback (tidak aktif)
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0004FF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      // saat field aktif tapi tidak fokus
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0004FF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // saat field dalam keadaan fokus
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0004FF),
                        width: 2, // opsional: garis lebih tebal
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed:
                      _chosenEmbedMethod == null
                          ? null
                          : () {
                            Navigator.of(context).pop();
                            _showEvaluationDialog(context);
                          },
                  child: const Text("Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0004FF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dialog 2: pilih Attack / ML / DL
  void _showEvaluationDialog(BuildContext context) {
    final attackTypes = [
      "JPEG Compression",
      "Rotation",
      "Horizontal Flip",
      "Random Cropping",
      "Uniform Scaling",
      "Gamma Correction",
      "Color Quantization",
      "Noise Addition",
      "Statistical Averaging",
    ];

    final mlModels = [
      "Random Forest",
      "Decision Tree",
      "Support Vector Machine",
      "K-Nearest Neighbors",
    ];

    final dlModels = ["CNN"];

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Color(0xFF67EFC4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFF0004FF), // warna border dialog
              width: 2, // ketebalan border
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Methods",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Select your preferred algorithm model for evaluation.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Select Attack Type :"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _chosenAttack,
                    items:
                        attackTypes
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _chosenAttack = val),
                    decoration: _dropdownDecoration("Attack"),
                  ),
                  const SizedBox(height: 16),

                  const Text("Select Machine Learning :"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _chosenML,
                    items:
                        mlModels
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _chosenML = val),
                    decoration: _dropdownDecoration("Machine Learning"),
                  ),
                  const SizedBox(height: 16),

                  const Text("Select Deep Learning :"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _chosenDL,
                    items:
                        dlModels
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _chosenDL = val),
                    decoration: _dropdownDecoration("Deep Learning"),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed:
                            (_chosenAttack != null &&
                                    _chosenML != null &&
                                    _chosenDL != null)
                                ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Markitpages(),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Method: $_chosenEmbedMethod, Attack: $_chosenAttack, ML: $_chosenML, DL: $_chosenDL",
                                      ),
                                    ),
                                  );
                                }
                                : null,
                        child: const Text("OK"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0004FF),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0004FF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0004FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0004FF), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EACB),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              40,
              16,
              8,
            ), // lebih dekat ke atas
            child: Row(
              children: [
                const SizedBox(height: 60),
                CircleAvatar(
                  backgroundImage:
                      avatarUrl != null && avatarUrl!.isNotEmpty
                          ? NetworkImage(avatarUrl!)
                          : null,
                  child:
                      avatarUrl == null || avatarUrl!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hi, Welcome\n${username ?? 'Capstone Design'}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.white,
              color: Color(0xFF0004FF),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "IncPic",
            style: GoogleFonts.poppins(
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Your image, your identity",
            style: GoogleFonts.poppins(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Color(0xFF7C7C7C),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Select Watermarking Methods",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 19,
            ),
          ),
          Text(
            "Click the logo to choose your preferred embedding technique",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF7C7C7C),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showMethodDialog(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              height: 350,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(
                  28,
                ), // slightly larger radius for outer
                border: Border.all(
                  color: Colors.black12,
                  width: 4, // outer border thickness
                ),
              ),
              child: Center(
                child: Container(
                  height: 320, // slightly smaller than outer
                  width: double.infinity,
                  margin: const EdgeInsets.all(10), // space between borders
                  decoration: BoxDecoration(
                    color: const Color(0xFF67EACB),
                    borderRadius: BorderRadius.circular(24), // inner radius
                    border: Border.all(
                      color: const Color(0xFF67EACB), // inner border color
                      width: 2, // inner border thickness
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "IncPic",
                      style: GoogleFonts.racingSansOne(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Markitpages extends StatefulWidget {
  @override
  _MarkitpagesState createState() => _MarkitpagesState();
}

class _MarkitpagesState extends State<Markitpages> {
  @override
  Widget build(BuildContext context) {
    final hostImage = Provider.of<ImageState>(context).hostImage;
    final watermarkImage = Provider.of<ImageState>(context).watermarkImage;

    return Scaffold(
      backgroundColor: Color(0xFF67EACB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Hi, Welcome\nCapstone Design',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: LinearProgressIndicator(
                value: 1, // misalnya 100% selesai
                backgroundColor: Colors.white,
                color: Color(0xFF0004FF),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 20),
            Column(
              children: [
                Text(
                  'IncPic',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // atur jarak antar teks, makin kecil makin rapat
                Text(
                  'Your image, your identity',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                    color: Color(
                      0xFF7C7C7C,
                    ), // jika tidak ingin pakai GoogleFonts
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (hostImage != null)
              Column(
                children: [
                  Center(
                    child: Text(
                      'Host Image',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.file(hostImage, height: 200),
                  ),
                ],
              ),

            const SizedBox(height: 30),
            if (watermarkImage != null)
              Column(
                children: [
                  Center(
                    child: Text(
                      'Watermark Image',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.file(watermarkImage, height: 200),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            // Button to mark the image
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0004FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onPressed: () {
                  PageRoute route = MaterialPageRoute(
                    builder: (context) => ProgressLoadingPage(),
                  );
                  Navigator.push(context, route);
                },
                child: Text(
                  "Mark It",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
