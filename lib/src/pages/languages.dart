// import 'package:flutter/material.dart';
// import 'package:flutter_svg_provider/flutter_svg_provider.dart';
//
// import '../../generated/l10n.dart';
// import '../elements/SearchBarWidget.dart';
// import '../elements/ShoppingCartButtonWidget.dart';
// import '../models/language.dart';
// import '../repository/settings_repository.dart' as settingRepo;
//
// class LanguagesWidget extends StatefulWidget {
//   @override
//   _LanguagesWidgetState createState() => _LanguagesWidgetState();
// }
//
// class _LanguagesWidgetState extends State<LanguagesWidget> {
//   late LanguagesList languagesList;
//
//   @override
//   void initState() {
//     languagesList = LanguagesList();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           S.of(context).languages,
//           style: Theme.of(context)
//               .textTheme
//               .headlineSmall
//               ?.merge(TextStyle(letterSpacing: 1.3)),
//         ),
//         actions: <Widget>[
//           new ShoppingCartButtonWidget(
//               iconColor: Theme.of(context).hintColor,
//               labelColor: Theme.of(context).colorScheme.secondary),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: SearchBarWidget(),
//             ),
//             SizedBox(height: 15),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: ListTile(
//                 contentPadding: EdgeInsets.symmetric(vertical: 0),
//                 leading: Icon(
//                   Icons.translate,
//                   color: Theme.of(context).hintColor,
//                 ),
//                 title: Text(
//                   S.of(context).app_language,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: Theme.of(context).textTheme.headlineLarge
//                 ),
//                 subtitle: Text(S.of(context).select_your_preferred_languages),
//               ),
//             ),
//             SizedBox(height: 10),
//             ListView.separated(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               primary: false,
//               itemCount: languagesList.languages.length,
//               separatorBuilder: (context, index) {
//                 return SizedBox(height: 10);
//               },
//               itemBuilder: (context, index) {
//                 Language _language = languagesList.languages.elementAt(index);
//                 settingRepo
//                     .getDefaultLanguage(settingRepo
//                         .setting.value.mobileLanguage.value.languageCode)
//                     .then((_langCode) {
//                   if (_langCode == _language.code) {
//                     setState(() {
//                       _language.selected = true;
//                     });
//                   }
//                 });
//                 return InkWell(
//                   onTap: () async {
//                     var _lang = _language.code.split("_");
//                     if (_lang.length > 1)
//                       settingRepo.setting.value.mobileLanguage.value =
//                           new Locale(_lang.elementAt(0), _lang.elementAt(1));
//                     else
//                       settingRepo.setting.value.mobileLanguage.value =
//                           new Locale(_lang.elementAt(0));
//                     settingRepo.setting.notifyListeners();
//                     languagesList.languages.forEach((_l) {
//                       setState(() {
//                         _l.selected = false;
//                       });
//                     });
//                     _language.selected = !_language.selected;
//                     settingRepo.setDefaultLanguage(_language.code);
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor.withOpacity(0.9),
//                       boxShadow: [
//                         BoxShadow(
//                             color:
//                                 Theme.of(context).focusColor.withOpacity(0.1),
//                             blurRadius: 5,
//                             offset: Offset(0, 2)),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: <Widget>[
//                         Stack(
//                           alignment: AlignmentDirectional.center,
//                           children: <Widget>[
//                             Container(
//                               height: 40,
//                               width: 40,
//                               padding: EdgeInsets.only(top: 12),
//                               child: Text(
//                                 _language.code.toUpperCase(),
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
//                               ),
//                               decoration: BoxDecoration(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(40)),
//                                   color: Theme.of(context).colorScheme.secondary
//                                   // image: DecorationImage(image: _language.isSvgFlag ?  Svg(_language.flag) : AssetImage(_language.flag), fit: BoxFit.cover),
//                                   ),
//                             ),
//                             Container(
//                               height: _language.selected ? 40 : 0,
//                               width: _language.selected ? 40 : 0,
//                               decoration: BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(40)),
//                                 color: Theme.of(context).colorScheme.secondary
//                                     .withOpacity(_language.selected ? 0.85 : 0),
//                               ),
//                               child: Icon(
//                                 Icons.check,
//                                 size: _language.selected ? 24 : 0,
//                                 color: Theme.of(context)
//                                     .primaryColor
//                                     .withOpacity(_language.selected ? 0.85 : 0),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(width: 15),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 _language.englishName,
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 2,
//                                 style: Theme.of(context).textTheme.titleMedium,
//                               ),
//                               Text(
//                                 _language.localName,
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 2,
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
