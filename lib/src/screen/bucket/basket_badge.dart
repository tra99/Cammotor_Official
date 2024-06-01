// import 'package:flutter/material.dart';

// class BasketBadge extends StatelessWidget {
//   final ValueNotifier<int> basketCountNotifier;

//   const BasketBadge({Key? key, required this.basketCountNotifier}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<int>(
//       valueListenable: basketCountNotifier,
//       builder: (context, value, child) {
//         return Stack(
//           children: [
//             Icon(Icons.shopping_cart),
//             if (value > 0)
//               Positioned(
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(1),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   constraints: const BoxConstraints(
//                     minWidth: 12,
//                     minHeight: 12,
//                   ),
//                   child: Text(
//                     '$value',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               )
//           ],
//         );
//       },
//     );
//   }
// }
