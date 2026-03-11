// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appName => 'EduFlow';

  @override
  String get appTagline => 'Elimu ya Maisha kwa Wakimbizi wa Afrika';

  @override
  String get aboutYou => 'Kuhusu Wewe';

  @override
  String get whyAreYouDisplaced => 'Kwa nini umekimbia makazi yako?';

  @override
  String get currentLocation => 'Mahali Ulipo Sasa';

  @override
  String get selectYourLocation => 'Chagua mahali ulipo';

  @override
  String get preferredLanguage => 'Lugha Unayopendelea';

  @override
  String get continueButton => 'Endelea';

  @override
  String get conflictDisplacement => 'Migogoro/Uhamisho';

  @override
  String get conflictDescription =>
      'Nilihama makazi yangu kutokana na migogoro au vurugu';

  @override
  String get climateDisaster => 'Maafa ya Hali ya Hewa';

  @override
  String get climateDescription =>
      'Nilihama makazi yangu kutokana na mafuriko, ukame, au mabadiliko ya hali ya hewa';

  @override
  String get otherReason => 'Nyingine';

  @override
  String get otherDescription => 'Sababu nyingine ya kuhama makazi';

  @override
  String get worksOffline => 'Inafanya Kazi Nje ya Mtandao';

  @override
  String get worksOfflineDesc => 'Pakua masomo na ujifunze bila mtandao';

  @override
  String get smsLearning => 'Mafunzo ya SMS';

  @override
  String smsLearningDesc(Object shortcode) {
    return 'Mnaweza kutumia huduma yetu ya SMS kwa kutuma maneno muhimu kwenda $shortcode.';
  }

  @override
  String get studyGroups => 'Vikundi vya Masomo';

  @override
  String get studyGroupsDesc => 'Ungana na wanafunzi wengine';

  @override
  String get getStarted => 'Anza Sasa';

  @override
  String get phoneLogin => 'Ingia kwa Simu';

  @override
  String get enterPhoneNumber => 'Ingiza namba yako ya simu';

  @override
  String get verificationCodeDesc => 'Tutakutumia namba ya siri ya uhakiki';

  @override
  String get phoneNumberLabel => 'Namba ya Simu';

  @override
  String get phoneNumberHint => '+254712345678';

  @override
  String get sendCode => 'Tuma Namba';

  @override
  String get enterCode => 'Ingiza namba ya siri';

  @override
  String sentCodeTo(String phoneNumber) {
    return 'Tumetuma namba ya siri ya tarakimu 6 kwa $phoneNumber';
  }

  @override
  String get verificationCodeLabel => 'Namba ya Uhakiki';

  @override
  String get verify => 'Hakiki';

  @override
  String get resendCode => 'Tuma Tena Namba';

  @override
  String get changePhoneNumber => 'Badilisha Namba ya Simu';

  @override
  String get pleaseEnterPhone => 'Tafadhali ingiza namba ya simu';

  @override
  String get pleaseEnterOtp => 'Tafadhali ingiza namba ya siri ya tarakimu 6';

  @override
  String get helpAndGuide => 'Msaada na Mwongozo';

  @override
  String get howToUseApp => 'Jinsi ya kutumia programu';

  @override
  String get gettingStartedTitle => 'Kuanza';

  @override
  String get gettingStartedDesc =>
      'Jifunze jinsi ya kutumia programu na kuanza safari yako ya masomo.';

  @override
  String get offlineLearningTitle => 'Masomo ya Nje ya Mtandao';

  @override
  String get offlineLearningDesc =>
      'Okoa data kwa kupakua masomo ili uyatumie mahali popote na wakati wowote.';

  @override
  String get smsLearningTitle => 'Masomo ya SMS (Bila Internet)';

  @override
  String get communityTitle => 'Vikundi vya Masomo';

  @override
  String get communityDesc =>
      'Jiunge au anzisha kikundi ili mjifunze pamoja na marafiki zako.';

  @override
  String get gotIt => 'Nimeelewa!';
}
