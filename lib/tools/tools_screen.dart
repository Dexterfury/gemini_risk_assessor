import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/search/my_data_stream.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/tools/tool_item.dart';
import 'package:provider/provider.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({
    super.key,
    this.groupID = '',
    this.isAdmin = false,
  });

  final String groupID;
  final bool isAdmin;

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final int _pageSize = 20;
  List<DocumentSnapshot> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  Stream<QuerySnapshot>? _dstiStream;

  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Tool Screen',
      screenClass: 'ToolsScreen',
    );
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    _dstiStream = FirebaseMethods.paginatedToolStream(
      userId: uid,
      groupID: widget.groupID,
      limit: _pageSize,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    Query query = FirebaseMethods.toolsQuery(
      userId: uid,
      groupID: widget.groupID,
    );

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    query = query.limit(_pageSize);

    final QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.length < _pageSize) {
      _hasMore = false;
    }

    setState(() {
      _items.addAll(querySnapshot.docs);
      _lastDocument =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
      _isLoading = false;
    });
  }

  bool _mergeStreamData(List<DocumentSnapshot> streamDocs) {
    bool hasChanged = false;
    final Set<String> streamDocIds = streamDocs.map((doc) => doc.id).toSet();
    final Set<String> localDocIds = _items.map((doc) => doc.id).toSet();

    // Find deleted documents
    final Set<String> deletedDocIds = localDocIds.difference(streamDocIds);

    // Remove deleted documents from _items
    if (deletedDocIds.isNotEmpty) {
      _items.removeWhere((doc) => deletedDocIds.contains(doc.id));
      hasChanged = true;
    }

    // Add new documents
    for (final doc in streamDocs) {
      if (!localDocIds.contains(doc.id)) {
        _items.insert(0, doc); // Insert at the beginning to maintain order
        hasChanged = true;
      }
    }

    if (hasChanged) {
      // Sort _items by createdAt in descending order
      _items.sort((a, b) => (b.data()
              as Map<String, dynamic>)[Constants.createdAt]
          .compareTo((a.data() as Map<String, dynamic>)[Constants.createdAt]));

      _lastDocument = _items.isNotEmpty ? _items.last : null;
    }

    return hasChanged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _dstiStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                _items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Merge stream data with existing items
            if (snapshot.hasData) {
              final hasChanged = _mergeStreamData(snapshot.data!.docs);
              if (hasChanged) {
                // Use Future.microtask to schedule a rebuild after this frame
                Future.microtask(() => setState(() {}));
              }
            }

            return _buildContent();
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    final results = _items
        .where(
          (element) =>
              element[Constants.title].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
        )
        .toList();

    return widget.groupID.isNotEmpty
        ? _buildGroupView(results)
        : const MyDataStream(
            generationType: GenerationType.tool,
          );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: widget.groupID.isNotEmpty
          ? const MyAppBar(
              leading: BackButton(),
              title: Constants.toolsExplainer,
            )
          : null,
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'You did not create any tools yet',
            textAlign: TextAlign.center,
            style: AppTheme.textStyle18w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupView(List<DocumentSnapshot> results) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: results.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text('No matching results')),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == results.length) {
                        return _buildLoadMoreButton();
                      }
                      final doc = results[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final tool = ToolModel.fromJson(data);
                      return ToolItem(
                        toolModel: tool,
                        groupID: widget.groupID,
                        isAdmin: widget.isAdmin,
                      );
                    },
                    childCount: results.length + 1,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      leading: const BackButton(),
      title: const FittedBox(
        child: Text(
          Constants.toolsExplainer,
        ),
      ),
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 56.0),
          child: MySearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!_hasMore) {
      return const SizedBox.shrink();
    }
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: _loadMoreItems,
            child: const Text('Load More'),
          );
  }
}
