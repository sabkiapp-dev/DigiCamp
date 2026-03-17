/// Uncomment the file and run the following command
/// flutter pub add firebase_dynamic_links
/// to work with firebase dynamic links
///

// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:digicamp_interface/src/config/app_constants.dart';
//
// class DynamicLinkService {
//   static late FirebaseDynamicLinks _instance;
//
//   static Future<void> init() async {
//     _instance = _instance = FirebaseDynamicLinks.instance;
//     _instance.onLink.listen(_onLink);
//   }
//
//   static Future<void> _onLink(PendingDynamicLinkData data) async {
//     final link = data.link;
//     if (link.path == "/path") {
//     }
//   }
//
//   static Future<Uri> createAppLink() async {
//     final DynamicLinkParameters parameters = DynamicLinkParameters(
//       uriPrefix: 'https://template.page.link',
//       link: Uri.https(
//         'template.com',
//         '/app_link',
//         {},
//       ),
//       androidParameters: const AndroidParameters(
//         packageName: 'com.template',
//         minimumVersion: 0,
//       ),
//       // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
//       //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
//       // ),
//       socialMetaTagParameters: SocialMetaTagParameters(
//         title: kAppName,
//         description:
//         'Hey! I have found an app which is awesome',
//         imageUrl: "https://mage_url",
//       ),
//     );
//     final shortLink = await _instance.buildShortLink(parameters);
//     return shortLink.shortUrl;
//   }
// }
