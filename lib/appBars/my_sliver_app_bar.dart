import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/widgets/list_item.dart';

class MySliverAppBar extends StatelessWidget {
  const MySliverAppBar({
    super.key,
    required this.snapshot,
    required this.title,
    required this.onSearch,
    required this.searchResults,
    required this.searchController,
  });

  final AsyncSnapshot<QuerySnapshot> snapshot;
  final String title;
  final Function(String) onSearch;
  final Iterable<QueryDocumentSnapshot<Object?>> searchResults;
  final TextEditingController searchController;

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
          expandedHeight: 120.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
                padding: const EdgeInsets.only(top: 56.0), child: Container()

                // MySearchBar(
                //   onSearch: onSearch,
                //   controller: searchController,
                // ),
                ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: searchResults.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text('No matching results')),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = searchResults.elementAt(index);
                      final data = doc.data() as Map<String, dynamic>;
                      final item = AssessmentModel.fromJson(data);
                      return ListItem(
                        docTitle: title,
                        data: item,
                      );
                    },
                    childCount: searchResults.length,
                  ),
                ),
        ),
      ],
    );
  }
}
// class MySliverAppBar extends StatelessWidget {
//   const MySliverAppBar({
//     super.key,
//     required this.snapshot,
//     required this.title,
//     required this.onSearch,
//     required this.searchResults,
//   });

//   final AsyncSnapshot<QuerySnapshot> snapshot;
//   final String title;
//   final Function(String) onSearch;
//   final Iterable<QueryDocumentSnapshot<Object?>> searchResults;

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           leading: const BackButton(),
//           title: Text(title),
//           pinned: true,
//           floating: true,
//           snap: true,
//           expandedHeight: 120.0,
//           flexibleSpace: FlexibleSpaceBar(
//             background: Padding(
//               padding: const EdgeInsets.only(top: 56.0),
//               child: MySearchBar(onSearch: onSearch),
//             ),
//           ),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.all(8.0),
//           sliver: searchResults.isEmpty
//               ? const SliverFillRemaining(
//                   child: Center(child: Text('No matching results')),
//                 )
//               : SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final doc = searchResults.elementAt(index);
//                       final data = doc.data() as Map<String, dynamic>;
//                       final item = AssessmentModel.fromJson(data);
//                       return ListItem(
//                         docTitle: title,
//                         data: item,
//                       );
//                     },
//                     childCount: searchResults.length,
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }
// }
