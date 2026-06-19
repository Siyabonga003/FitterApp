import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // 1. IMMERSIVE MAP CANVAS VECTOR GROUND
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0B111E), // Ultra dark map background contrast tint
            child: CustomPaint(
              painter: MapGridLinePainter(),
            ),
          ),

          // 2. LIVE FLOATING TELEMETRY RUNNER BUBBLES (Mock Locations)
          Positioned(
            top: 220,
            left: 80,
            child: _buildLiveRunnerAvatar('S', 'Siya (You)', true),
          ),
          Positioned(
            top: 160,
            right: 100,
            child: _buildLiveRunnerAvatar('P', 'Peter', false),
          ),
          Positioned(
            bottom: 340,
            left: 140,
            child: _buildLiveRunnerAvatar('M', 'Mary', false),
          ),

          // 3. FLOATING COMPASS & LOCATION CONTROLS
          Positioned(
            top: 50,
            right: 16,
            child: Column(
              children: [
                _buildMapActionButton(Icons.my_location_rounded),
                const SizedBox(height: 12),
                _buildMapActionButton(Icons.layers_outlined),
              ],
            ),
          ),

          // 4. FLOATING TOP INTERACTION SEARCH ANCHOR
          Positioned(
            top: 50,
            left: 16,
            right: 80,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: AppTheme.textLight, size: 20),
                  SizedBox(width: 12),
                  Text('Find friends or routes...', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                ],
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slider Top Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  // Title Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ACTIVE FRIENDS NEARBY', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8)),
                        Text('2 Live Now', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Horizontal List View of active buddies
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildFriendPanelCard('Peter', 'Active 2m ago', '⚡ 5:10 /km', 'P'),
                        _buildFriendPanelCard('Mary', 'Active 12m ago', '🏁 4.2 km', 'M'),
                        _buildFriendPanelCard('John', 'Offline', 'Yesterday', 'J'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRunnerAvatar(String initial, String name, bool isUser) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUser ? AppTheme.primaryOrange : AppTheme.darkCard,
            border: Border.all(
              color: isUser ? Colors.white : AppTheme.primaryOrange.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isUser ? AppTheme.primaryOrange : Colors.black).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1F2C42),
            child: Text(initial, style: TextStyle(color: isUser ? Colors.white : AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
          ),
          child: Text(name, style: const TextStyle(color: AppTheme.textWhite, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildMapActionButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textWhite, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildFriendPanelCard(String name, String status, String metric, String initial) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12, bottom: 20, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                child: Text(initial, style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status, style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
              const SizedBox(height: 2),
              Text(metric, style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class MapGridLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}