import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/search/my_search_bar.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';

class MySliverAppBar extends StatelessWidget {
  const MySliverAppBar({
    super.key,
    required this.snapshot,
    required this.title,
    required this.onSearch,
  });

  final AsyncSnapshot<QuerySnapshot> snapshot;
  final String title;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
            leading: const BackButton(),
            title: Text(title),
            pinned: true,
            floating: true,
            snap: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: MySearchBar(
                onSearch: onSearch,
              ),
            )),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final item = AssessmentModel.fromJson(data);
                return ListItem(
                  data: item,
                );
              },
              childCount: snapshot.data!.docs.length,
            ),
          ),
        ),
      ],
    );
  }
}
