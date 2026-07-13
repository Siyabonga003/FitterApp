import 'package:flutter/material.dart';
import 'package:frontend_app/models/friendship_model.dart';
import 'package:frontend_app/services/friendship_service.dart';
import 'package:frontend_app/theme/app_theme.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<FriendshipResponse> _friends = [];
  List<FriendshipResponse> _incoming = [];
  List<FriendshipResponse> _outgoing = [];
  List<FriendSearchResult> _searchResults = [];

  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      FriendshipService.getFriends(),
      FriendshipService.getIncomingRequests(),
      FriendshipService.getOutgoingRequests(),
    ]);
    if (mounted) {
      setState(() {
        _friends = results[0] as List<FriendshipResponse>;
        _incoming = results[1] as List<FriendshipResponse>;
        _outgoing = results[2] as List<FriendshipResponse>;
        _isLoading = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await FriendshipService.searchUsers(query.trim());
    if (mounted) setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _sendRequest(String toUserId) async {
    await FriendshipService.sendRequest(toUserId);
    await _search(_searchController.text);
    _showSnack('Friend request sent!');
  }

  Future<void> _accept(String friendshipId) async {
    await FriendshipService.acceptRequest(friendshipId);
    await _loadAll();
    _showSnack('Friend request accepted!');
  }

  Future<void> _decline(String friendshipId) async {
    await FriendshipService.declineRequest(friendshipId);
    await _loadAll();
  }

  Future<void> _unfriend(String friendId) async {
    await FriendshipService.unfriend(friendId);
    await _loadAll();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Friends',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryOrange,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.textLight,
          tabs: [
            Tab(text: 'Friends (${_friends.length})'),
            Tab(text: 'Requests (${_incoming.length})'),
            const Tab(text: 'Find'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(
              color: AppTheme.primaryOrange))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(),
          _buildRequestsList(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const Center(
        child: Text('No friends yet — go find some! 🏃',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      color: AppTheme.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final f = _friends[index];
          final otherId =
              f.userId; // resolved by backend to the other person
          return _userCard(
            initial: f.initial,
            displayName: f.displayName,
            subtitle: f.email,
            trailing: TextButton(
              onPressed: () => _unfriend(otherId),
              child: const Text('Unfriend',
                  style: TextStyle(color: AppTheme.danger)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList() {
    return RefreshIndicator(
      onRefresh: _loadAll,
      color: AppTheme.primaryOrange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_incoming.isNotEmpty) ...[
            _sectionHeader('INCOMING'),
            ..._incoming.map((f) => _userCard(
              initial: f.initial,
              displayName: f.displayName,
              subtitle: f.email,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_rounded,
                        color: Colors.green),
                    onPressed: () => _accept(f.friendshipId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded,
                        color: AppTheme.danger),
                    onPressed: () => _decline(f.friendshipId),
                  ),
                ],
              ),
            )),
          ],
          if (_outgoing.isNotEmpty) ...[
            _sectionHeader('SENT'),
            ..._outgoing.map((f) => _userCard(
              initial: f.initial,
              displayName: f.displayName,
              subtitle: 'Request pending',
              trailing: TextButton(
                onPressed: () => _unfriend(f.friendId),
                child: const Text('Withdraw',
                    style: TextStyle(color: AppTheme.textLight)),
              ),
            )),
          ],
          if (_incoming.isEmpty && _outgoing.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text('No pending requests',
                    style: TextStyle(
                        color: AppTheme.textLight, fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: InputDecoration(
              hintText: 'Search by display name...',
              hintStyle: const TextStyle(color: AppTheme.textLight),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textLight),
              filled: true,
              fillColor: AppTheme.darkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear_rounded,
                    color: AppTheme.textLight),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchResults = []);
                },
              )
                  : null,
            ),
            onChanged: _search,
          ),
        ),
        if (_isSearching)
          const CircularProgressIndicator(color: AppTheme.primaryOrange)
        else
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
              child: Text(
                _searchController.text.isEmpty
                    ? 'Search for runners by name'
                    : 'No users found',
                style: const TextStyle(
                    color: AppTheme.textLight, fontSize: 14),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final u = _searchResults[index];
                return _userCard(
                  initial: u.initial,
                  displayName: u.displayName,
                  subtitle: u.bio ?? u.email,
                  trailing: _requestButton(u),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _requestButton(FriendSearchResult u) {
    if (u.friendshipStatus == 'ACCEPTED') {
      return const Text('Friends ✓',
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold));
    }
    if (u.friendshipStatus == 'PENDING') {
      return const Text('Pending',
          style: TextStyle(color: AppTheme.textLight));
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryOrange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () => _sendRequest(u.userId),
      child: const Text('Add',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1)),
    );
  }

  Widget _userCard({
    required String initial,
    required String displayName,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
            child: Text(initial,
                style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textLight, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}