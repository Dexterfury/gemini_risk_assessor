import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                    // remove focus
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: const Icon(Icons.cancel, color: Colors.grey),
                )
              : null,
        ),
      ),
    );
  }
}

// class MySearchBar extends StatelessWidget {
//   const MySearchBar({
//     Key? key,
//     required this.onSearch,
//     required this.controller,
//   }) : super(key: key);

//   final Function(String) onSearch;
//   final TextEditingController controller;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: TextField(
//         controller: controller,
//         onChanged: onSearch,
//         decoration: InputDecoration(
//           hintText: 'Search...',
//           fillColor: Colors.white,
//           filled: true,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           prefixIcon: const Icon(Icons.search),
//           suffixIcon: controller.text.isNotEmpty
//               ? GestureDetector(
//                   onTap: () {
//                     controller.clear();
//                     onSearch('');
//                   },
//                   child: const Icon(Icons.cancel, color: Colors.grey),
//                 )
//               : null,
//         ),
//       ),
//     );
//   }
// }

// class MySearchBar extends StatefulWidget {
//   const MySearchBar({
//     super.key,
//     required this.onSearch,
//   });

//   final Function(String) onSearch;

//   @override
//   State<MySearchBar> createState() => _MySearchBarState();
// }

// class _MySearchBarState extends State<MySearchBar> {
//   TextEditingController controller = TextEditingController();
//   bool _showClearButton = false;

//   @override
//   void initState() {
//     super.initState();
//     controller.addListener(_onTextChanged);
//   }

//   @override
//   void dispose() {
//     controller.removeListener(_onTextChanged);
//     super.dispose();
//   }

//   void _onTextChanged() {
//     setState(() {
//       _showClearButton = controller.text.isNotEmpty;
//     });
//   }

//   void _clearSearch() {
//     controller.clear();
//     // remove focus
//     FocusScope.of(context).requestFocus(FocusNode());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: TextField(
//         controller: controller,
//         onChanged: widget.onSearch,
//         decoration: InputDecoration(
//           hintText: 'Search...',
//           fillColor: Colors.white,
//           filled: true,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           prefixIcon: const Icon(
//             Icons.search,
//           ),
//           suffixIcon: _showClearButton
//               ? GestureDetector(
//                   onTap: _clearSearch,
//                   child: const Icon(
//                     Icons.cancel,
//                     color: Colors.grey,
//                   ),
//                 )
//               : null,
//         ),
//       ),
//     );
//   }
// }
