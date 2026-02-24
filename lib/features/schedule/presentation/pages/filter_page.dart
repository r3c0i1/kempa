// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../core/theme/app_palettes.dart';
// import '../../../../core/theme/theme_cubit.dart';

// // Режимы расписания (взаимоисключающие)
// enum FilterMode { group, teacher, room }

// class FilterPage extends StatefulWidget {
//   const FilterPage({super.key});

//   @override
//   State<FilterPage> createState() => _FilterPageState();
// }

// class _FilterPageState extends State<FilterPage> {
//   static const double _borderRadius = 12.0;

//   // Текущий активный режим
//   FilterMode _activeMode = FilterMode.group;

//   // Данные фильтров
//   String _selectedGroup = "ПИ-211";
//   int _selectedSubgroup = 1;
//   String _selectedTeacher = "Котов К.К.";
//   String _selectedRoom = "2204";
//   String _selectedType = "Все занятия";

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, AppPalette>(
//       builder: (context, palette) {
//         return Scaffold(
//           backgroundColor: palette.base,
//           appBar: _buildAppBar(context, palette),
//           body: Column(
//             children: [
//               Expanded(
//                 child: ListView(
//                   padding: const EdgeInsets.all(20),
//                   physics: const BouncingScrollPhysics(),
//                   children: [
//                     _buildSectionTitle('КАТЕГОРИЯ ПОИСКА', palette),
//                     _buildModeSelector(palette),
                    
//                     const SizedBox(height: 32),
                    
//                     _buildSectionTitle('ПАРАМЕТРЫ', palette),
                    
//                     // Динамическое отображение полей в зависимости от режима
//                     if (_activeMode == FilterMode.group) ...[
//                       _buildFilterTile(
//                         label: 'Группа',
//                         value: _selectedGroup,
//                         icon: Icons.groups_rounded,
//                         palette: palette,
//                         onTap: () {},
//                       ),
//                       const SizedBox(height: 12),
//                       _buildSubgroupSelector(palette),
//                     ],

//                     if (_activeMode == FilterMode.teacher) ...[
//                       _buildFilterTile(
//                         label: 'Преподаватель',
//                         value: _selectedTeacher,
//                         icon: Icons.person_search_rounded,
//                         palette: palette,
//                         onTap: () {},
//                       ),
//                     ],

//                     if (_activeMode == FilterMode.room) ...[
//                       _buildFilterTile(
//                         label: 'Кабинет / Аудитория',
//                         value: _selectedRoom,
//                         icon: Icons.location_on_rounded,
//                         palette: palette,
//                         onTap: () {},
//                       ),
//                     ],
                    
//                     const SizedBox(height: 32),
                    
//                     _buildSectionTitle('ДОПОЛНИТЕЛЬНО', palette),
//                     _buildFilterTile(
//                       label: 'Тип занятий',
//                       value: _selectedType,
//                       icon: Icons.layers_rounded,
//                       palette: palette,
//                       onTap: () {},
//                     ),
//                     const SizedBox(height: 12),
//                     _buildFilterTile(
//                       label: 'Предмет',
//                       value: 'Все предметы',
//                       icon: Icons.book_rounded,
//                       palette: palette,
//                       onTap: () {},
//                     ),
//                   ],
//                 ),
//               ),
              
//               _buildApplyButton(palette),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(BuildContext context, AppPalette palette) {
//     return AppBar(
//       backgroundColor: palette.base,
//       elevation: 0,
//       centerTitle: true,
//       leading: IconButton(
//         icon: Icon(Icons.close_rounded, color: palette.text),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: Text(
//         'Фильтры',
//         style: GoogleFonts.jetBrainsMono(
//           color: palette.text,
//           fontWeight: FontWeight.w800,
//           fontSize: 18,
//         ),
//       ),
//     );
//   }

//   // Переключатель взаимоисключающих режимов
//   Widget _buildModeSelector(AppPalette palette) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: palette.surface.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(_borderRadius + 4),
//       ),
//       child: Row(
//         children: [
//           _modeItem('Группа', FilterMode.group, palette),
//           _modeItem('Препод', FilterMode.teacher, palette),
//           _modeItem('Кабинет', FilterMode.room, palette),
//         ],
//       ),
//     );
//   }

//   Widget _modeItem(String label, FilterMode mode, AppPalette palette) {
//     bool isSelected = _activeMode == mode;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _activeMode = mode),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: isSelected ? palette.accent : Colors.transparent,
//             borderRadius: BorderRadius.circular(_borderRadius),
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: GoogleFonts.inter(
//                 fontSize: 12,
//                 fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
//                 color: isSelected ? palette.base : palette.text.withOpacity(0.5),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, AppPalette palette) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4, bottom: 12),
//       child: Text(
//         title,
//         style: GoogleFonts.inter(
//           fontSize: 10,
//           fontWeight: FontWeight.w900,
//           color: palette.accent.withOpacity(0.6),
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterTile({
//     required String label,
//     required String value,
//     required IconData icon,
//     required AppPalette palette,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: palette.surface.withOpacity(0.4),
//           borderRadius: BorderRadius.circular(_borderRadius),
//           border: Border.all(color: palette.accent.withOpacity(0.1)),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: palette.accent, size: 20),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.inter(
//                     fontSize: 11,
//                     color: palette.text.withOpacity(0.3),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: GoogleFonts.inter(
//                     fontSize: 15,
//                     color: palette.text,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Icon(Icons.search_rounded, color: palette.accent.withOpacity(0.3), size: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSubgroupSelector(AppPalette palette) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: palette.surface.withOpacity(0.4),
//         borderRadius: BorderRadius.circular(_borderRadius),
//         border: Border.all(color: palette.accent.withOpacity(0.1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Подгруппа',
//                   style: GoogleFonts.inter(
//                       fontSize: 11, color: palette.text.withOpacity(0.3))),
//               Text(_selectedSubgroup == 0 ? 'Все' : '№$_selectedSubgroup',
//                   style: GoogleFonts.inter(
//                       fontSize: 15, color: palette.text, fontWeight: FontWeight.w700)),
//             ],
//           ),
//           Row(
//             children: [1, 2, 0].map((s) {
//               bool isSelected = _selectedSubgroup == s;
//               return GestureDetector(
//                 onTap: () => setState(() => _selectedSubgroup = s),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: const EdgeInsets.only(left: 8),
//                   width: 40,
//                   height: 35,
//                   decoration: BoxDecoration(
//                     color: isSelected ? palette.accent : palette.base.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       s == 0 ? '∞' : s.toString(),
//                       style: GoogleFonts.jetBrainsMono(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                         color: isSelected ? palette.base : palette.text.withOpacity(0.4),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplyButton(AppPalette palette) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
//       child: SizedBox(
//         width: double.infinity,
//         height: 56,
//         child: ElevatedButton(
//           onPressed: () => Navigator.pop(context),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: palette.accent,
//             foregroundColor: palette.base,
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(_borderRadius),
//             ),
//           ),
//           child: Text(
//             'СОХРАНИТЬ',
//             style: GoogleFonts.inter(
//               fontSize: 14,
//               fontWeight: FontWeight.w900,
//               letterSpacing: 1.5,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }