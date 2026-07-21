import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_app/models/friendship_model.dart';
import 'package:frontend_app/services/friendship_service.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/screens/friends/widgets/discover_tab.dart';
import 'package:frontend_app/screens/friends/widgets/friends_list_tab.dart';
import 'package:frontend_app/screens/friends/widgets/requests_list_tab.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<FriendshipResponse> _friends = [];
  List<FriendshipResponse> _incoming = [];
  List<FriendshipResponse> _outgoing = [];
  List<FriendSearchResult> _discoverItems = [];

  bool _isMainLoading = false;
  bool _isDiscoverLoading = false;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _loadInitialSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isMainLoading = true);
    try {
      final resFriends = await FriendshipService.getFriends();
      final resIncoming = await FriendshipService.getIncomingRequests();
      final resOutgoing = await FriendshipService.getOutgoingRequests();
      setState(() {
        _friends = resFriends;
        _incoming = resIncoming;
        _outgoing = resOutgoing;
      });
    } finally {
      setState(() => _isMainLoading = false);
    }
  }

  Future<void> _loadInitialSuggestions() async {
    if (_isSearching) return;
    setState(() => _isDiscoverLoading = true);
    final suggestions = await FriendshipService.getSuggestions();
    if (!_isSearching) {
      setState(() {
        _discoverItems = suggestions;
        _isDiscoverLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = value.trim();
      if (query.isEmpty) {
        setState(() => _isSearching = false);
        _loadInitialSuggestions();
        return;
      }

      setState(() {
        _isSearching = true;
        _isDiscoverLoading = true;
      });

      final results = await FriendshipService.searchUsers(query);
      setState(() {
        _discoverItems = results;
        _isDiscoverLoading = false;
      });
    });
  }

  Future<void> _handleSendRequest(String userId) async {
    final result = await FriendshipService.sendRequest(userId);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent successfully!')),
      );
      _fetchAllData();
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged(_searchController.text);
      } else {
        _loadInitialSuggestions();
      }
    }
  }

  Future<void> _handleAccept(String friendshipId) async {
    final res = await FriendshipService.acceptRequest(friendshipId);
    if (res != null) _fetchAllData();
  }

  Future<void> _handleDecline(String friendshipId) async {
    await FriendshipService.declineRequest(friendshipId);
    _fetchAllData();
  }

  Future<void> _handleUnfriend(String id, String name) async {
    final confirm = await _showConfirmDialog('Unfriend $name', 'Are you sure you want to remove them?');
    if (confirm == true) {
      await FriendshipService.unfriend(id);
      _fetchAllData();
    }
  }

  Future<void> _handleCancelRequest(String id, String name) async {
    final confirm = await _showConfirmDialog('Cancel Request', 'Cancel sent request to $name?');
    if (confirm == true) {
      await FriendshipService.unfriend(id);
      _fetchAllData();
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textWhite,
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Action Destruction Option
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger.withOpacity(0.15),
                      foregroundColor: AppTheme.danger,
                      elevation: 0,
                      side: BorderSide(color: AppTheme.danger.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int requestCount = _incoming.length + _outgoing.length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBg,
          elevation: 0,
          title: const Text('Community', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            indicatorColor: AppTheme.primaryOrange,
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor: AppTheme.textLight,
            tabs: [
              const Tab(text: 'Friends'),
              Tab(text: requestCount > 0 ? 'Requests ($requestCount)' : 'Requests'),
              const Tab(text: 'Discover'),
            ],
          ),
        ),
        body: _isMainLoading && _friends.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
            : TabBarView(
          children: [
            FriendsListTab(
              friends: _friends,
              onRefresh: _fetchAllData,
              onUnfriend: _handleUnfriend,
              onProfileTap: (id) {},
            ),
            RequestsListTab(
              incoming: _incoming,
              outgoing: _outgoing,
              onRefresh: _fetchAllData,
              onAccept: _handleAccept,
              onDecline: _handleDecline,
              onCancel: _handleCancelRequest,
              onProfileTap: (id) {},
              sectionHeaderBuilder: _buildSectionHeader,
            ),
            DiscoverTab(
              results: _discoverItems,
              isSearching: _isSearching,
              isLoading: _isDiscoverLoading,
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onSendRequest: _handleSendRequest,
              onProfileTap: (id) {},
            ),
          ],
        ),
      ),
    );
  }
}