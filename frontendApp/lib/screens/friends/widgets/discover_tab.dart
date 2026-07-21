// lib/screens/friends/widgets/discover_tab.dart
import 'package:flutter/material.dart';
import '../../../models/friendship_model.dart';
import '../../../theme/app_theme.dart';
import 'user_card.dart';

class DiscoverTab extends StatelessWidget {
  final List<FriendSearchResult> results;
  final bool isSearching;
  final bool isLoading;
  final Function(String query) onSearchChanged;
  final Function(String userId) onSendRequest;
  final Function(String userId) onProfileTap;
  final TextEditingController searchController;

  const DiscoverTab({
    super.key,
    required this.results,
    required this.isSearching,
    required this.isLoading,
    required this.onSearchChanged,
    required this.onSendRequest,
    required this.onProfileTap,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: InputDecoration(
              hintText: 'Search by display name...',
              hintStyle: const TextStyle(color: AppTheme.textLight),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
              filled: true,
              fillColor: AppTheme.darkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            isSearching ? 'SEARCH RESULTS' : 'SUGGESTED FOR YOU',
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                : results.isEmpty
                ? Center(
              child: Text(
                isSearching ? 'No users found matching that name.' : 'No suggestions available right now.',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
            )
                : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final user = results[index];
                return UserCard(
                  initial: user.initial,
                  displayName: user.displayName,
                  subtitle: user.bio ?? user.email,
                  onProfileTap: () => onProfileTap(user.userId),
                  trailing: _buildActionWidget(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionWidget(FriendSearchResult user) {
    final status = user.friendshipStatus?.toLowerCase();

    if (status == 'friends' || status == 'accepted') {
      return const Text('Friends', style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500));
    }
    if (status == 'pending_incoming') {
      return const Text('Received', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 13, fontWeight: FontWeight.w500));
    }
    if (status == 'pending_outgoing' || status == 'sent') {
      return const Text('Pending', style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500));
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => onSendRequest(user.userId),
      child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}