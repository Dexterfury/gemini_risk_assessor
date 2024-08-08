import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_item.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_model.dart';
import 'package:gemini_risk_assessor/nearmiss/create_near_miss.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';

class NearMissesScreen extends StatefulWidget {
  const NearMissesScreen({
    Key? key,
    required this.groupID,
    required this.isAdmin,
  }) : super(key: key);
  final String groupID;
  final bool isAdmin;

  @override
  State<NearMissesScreen> createState() => _NearMissesScreenState();
}

class _NearMissesScreenState extends State<NearMissesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final int _pageSize = 20;
  List<DocumentSnapshot> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  Stream<QuerySnapshot>? _nearMissesStream;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeStream() {
    _nearMissesStream = FirebaseMethods.paginatedNearMissStream(
      groupID: widget.groupID,
      limit: _pageSize,
    );
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseMethods.nearMissessQuery(
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
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Near Misses Screen',
      screenClass: 'NearMissesScreen',
    );
    _initializeStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _nearMissesStream,
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
              element[Constants.description].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
        )
        .toList();

    return _buildGroupView(results);
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: MyAppBar(
        leading: BackButton(),
        title: Constants.nearMisses,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No Near Misses Yet!',
                textAlign: TextAlign.center,
                style: AppTheme.textStyle18w500,
              ),
              const SizedBox(height: 10),
              OpenContainer(
                closedBuilder: (context, action) {
                  return SizedBox(
                    height: 50.0,
                    child: MainAppButton(
                      label: ' Create a Near Miss',
                      borderRadius: 15.0,
                      onTap: action,
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return CreateNearMiss(groupID: widget.groupID);
                },
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 500),
                closedElevation: AppTheme.cardElevation,
                openElevation: 4,
              ),
            ],
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
                      final nearMiss = NearMissModel.fromJson(data);

                      return NearMissItem(
                        nearMiss: nearMiss,
                        isAdmin: widget.isAdmin,
                        groupID: widget.groupID,
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
        child: Text(Constants.nearMisses),
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
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateNearMiss(groupID: widget.groupID),
              ),
            );
          },
          icon: Icon(FontAwesomeIcons.plus),
        )
      ],
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

// class NearMissesScreen extends StatefulWidget {
//   const NearMissesScreen({
//     super.key,
//     required this.groupID,
//     required this.isAdmin,
//   });
//   final String groupID;
//   final bool isAdmin;

//   @override
//   State<NearMissesScreen> createState() => _DiscussionScreenState();
// }

// class _DiscussionScreenState extends State<NearMissesScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     AnalyticsHelper.logScreenView(screenName: 'Near Misses Screen', screenClass: 'NearMissesScreen',);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseMethods.nearMissessStream(
//             groupID: widget.groupID,
//           ),
//           builder:
//               (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.hasError) {
//               return const Center(child: Text('Something went wrong'));
//             }

//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.data!.docs.isEmpty) {
//               return Scaffold(
//                 appBar: widget.groupID.isNotEmpty
//                     ? const MyAppBar(
//                         leading: BackButton(),
//                         title: Constants.nearMissesTitle,
//                       )
//                     : null,
//                 body: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'No Near Misses Yet!',
//                           textAlign: TextAlign.center,
//                           style: AppTheme.textStyle18w500,
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         OpenContainer(
//                           closedBuilder: (context, action) {
//                             return SizedBox(
//                               height: 50.0,
//                               child: MainAppButton(
//                                 label: ' Create a Near Miss',
//                                 borderRadius: 15.0,
//                                 onTap: action,
//                               ),
//                             );
//                           },
//                           openBuilder: (context, action) {
//                             // navigate to screen depending on the clicked icon
//                             return CreateNearMiss(groupID: widget.groupID);
//                           },
//                           closedShape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15)),
//                           transitionType: ContainerTransitionType.fadeThrough,
//                           transitionDuration: const Duration(milliseconds: 500),
//                           closedElevation: AppTheme.cardElevation,
//                           openElevation: 4,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }

//             return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 final results = snapshot.data!.docs.where(
//                   (element) => element[Constants.description]
//                       .toString()
//                       .toLowerCase()
//                       .contains(
//                         _searchQuery.toLowerCase(),
//                       ),
//                 );

//                 return CustomScrollView(
//                   slivers: [
//                     SliverAppBar(
//                       leading: const BackButton(),
//                       title: const FittedBox(
//                         child: Text(
//                           Constants.nearMisses,
//                         ),
//                       ),
//                       pinned: true,
//                       floating: true,
//                       snap: true,
//                       expandedHeight: 120.0,
//                       flexibleSpace: FlexibleSpaceBar(
//                         background: Padding(
//                           padding: const EdgeInsets.only(top: 56.0),
//                           child: MySearchBar(
//                             controller: _searchController,
//                             onChanged: (value) {
//                               setState(() {
//                                 _searchQuery = value;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       actions: [
//                         IconButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     CreateNearMiss(groupID: widget.groupID),
//                               ),
//                             );
//                           },
//                           icon: Icon(FontAwesomeIcons.plus),
//                         )
//                       ],
//                     ),
//                     SliverPadding(
//                       padding: const EdgeInsets.all(8.0),
//                       sliver: results.isEmpty
//                           ? const SliverFillRemaining(
//                               child: Center(child: Text('No matching results')),
//                             )
//                           : SliverList(
//                               delegate: SliverChildBuilderDelegate(
//                                 (context, index) {
//                                   final doc = results.elementAt(index);
//                                   final data =
//                                       doc.data() as Map<String, dynamic>;
//                                   final nearMiss = NearMissModel.fromJson(data);
//                                   return NearMissItem(nearMiss: nearMiss);
//                                 },
//                                 childCount: results.length,
//                               ),
//                             ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
