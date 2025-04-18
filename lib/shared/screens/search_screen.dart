
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../features/groups/domain/entities/group_entity.dart';
import '../../features/groups/presentation/providers/group_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Screen for searching groups, assignments, and users
class SearchScreen extends StatefulWidget {
  /// Creates a SearchScreen
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  
  final List<GroupEntity> _groupResults = [];
  final List<UserEntity> _userResults = [];
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    
    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }
  
  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
    });
    
    // In a production app, this would search against the backend
    // For now, we'll simulate a search with delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock search results
    setState(() {
      _groupResults.clear();
      _userResults.clear();
      
      // Add mock data for demonstration
      if (_searchQuery.toLowerCase().contains('cs')) {
        _groupResults.add(
          const GroupEntity(
            id: 'group1',
            name: 'CS101 - Introduction to Programming',
            description: 'Learn the basics of programming',
            creatorId: 'user1',
            memberCount: 30,
            createdAt: null,
          ),
        );
        
        _groupResults.add(
          const GroupEntity(
            id: 'group2',
            name: 'CS240 - Data Structures',
            description: 'Advanced concepts in data structures',
            creatorId: 'user2',
            memberCount: 45,
            createdAt: null,
          ),
        );
      }
      
      if (_searchQuery.toLowerCase().contains('math')) {
        _groupResults.add(
          const GroupEntity(
            id: 'group3',
            name: 'MATH101 - Calculus I',
            description: 'Introduction to calculus',
            creatorId: 'user3',
            memberCount: 60,
            createdAt: null,
          ),
        );
      }
      
      if (_searchQuery.toLowerCase().contains('john')) {
        _userResults.add(
          const UserEntity(
            id: 'user1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            studentId: 'S12345',
            role: UserRole.student,
          ),
        );
      }
      
      if (_searchQuery.toLowerCase().contains('smith')) {
        _userResults.add(
          const UserEntity(
            id: 'user2',
            email: 'jane.smith@example.com',
            firstName: 'Jane',
            lastName: 'Smith',
            studentId: 'S54321',
            role: UserRole.student,
          ),
        );
      }
      
      _isSearching = false;
    });
  }
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _groupResults.clear();
      _userResults.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search groups, users...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          autofocus: true,
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildInitialContent()
          : _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _buildSearchResults(),
    );
  }
  
  Widget _buildInitialContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for groups, users, and more',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type in the search bar above',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    final hasResults = _groupResults.isNotEmpty || _userResults.isNotEmpty;
    
    if (!hasResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_groupResults.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Groups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              ...List.generate(
                _groupResults.length,
                (index) => _buildGroupResultItem(_groupResults[index]),
              ),
              const SizedBox(height: 24),
            ],
            
            if (_userResults.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              ...List.generate(
                _userResults.length,
                (index) => _buildUserResultItem(_userResults[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildGroupResultItem(GroupEntity group) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          group.name[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(group.name),
      subtitle: Text(
        group.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.group,
          arguments: group.id,
        );
      },
    );
  }
  
  Widget _buildUserResultItem(UserEntity user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueGrey,
        child: Text(
          user.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(user.fullName),
      subtitle: Text(user.role.displayName),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.profile,
          arguments: user.id,
        );
      },
    );
  }
}
