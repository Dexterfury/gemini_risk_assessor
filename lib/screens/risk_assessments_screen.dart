import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/search/my_data_stream.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';
import 'package:provider/provider.dart';

class RiskAssessmentsScreen extends StatefulWidget {
  const RiskAssessmentsScreen({
    super.key,
    this.groupID = '',
  });

  final String groupID;

  @override
  State<RiskAssessmentsScreen> createState() => _RiskAssessmentsScreenState();
}

class _RiskAssessmentsScreenState extends State<RiskAssessmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final int _pageSize = 20;
  List<DocumentSnapshot> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  Stream<QuerySnapshot>? _assessmentStream;

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView(
      screenName: 'Risk Assessments Screen',
      screenClass: 'RiskAssessmentsScreen',
    );
    _initializeStream();
  }

  void _initializeStream() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    _assessmentStream = FirebaseMethods.paginatedAssessmentStream(
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

    Query query = FirebaseMethods.assessmentQuery(
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

  void _mergeStreamData(List<DocumentSnapshot> streamDocs) {
    final Set<String> existingIds = _items.map((doc) => doc.id).toSet();
    final List<DocumentSnapshot> newDocs =
        streamDocs.where((doc) => !existingIds.contains(doc.id)).toList();

    if (newDocs.isNotEmpty) {
      _items = [...newDocs, ..._items];
      _lastDocument = _items.isNotEmpty ? _items.last : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _assessmentStream,
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
              _mergeStreamData(snapshot.data!.docs);
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
            generationType: GenerationType.riskAssessment,
          );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: widget.groupID.isNotEmpty
          ? const MyAppBar(
              leading: BackButton(),
              title: Constants.riskAssessments,
            )
          : null,
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'You did not create any risk assessments',
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
                      final item = AssessmentModel.fromJson(data);
                      return ListItem(
                        docTitle: Constants.riskAssessment,
                        groupID: widget.groupID,
                        data: item,
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
          Constants.riskAssessments,
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
