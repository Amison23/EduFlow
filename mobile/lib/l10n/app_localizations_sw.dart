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
  String get appTagline => 'Mafunzo ya Maisha kwa Wanafunzi Wote';

  @override
  String get aboutYou => 'Kuhusu Wewe';

  @override
  String get whyAreYouDisplaced => 'Tueleze kuhusu hali yako';

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
  String get remoteRegion => 'Eneo la Mbali';

  @override
  String get remoteRegionDescription =>
      'Ninaishi katika eneo la mbali lenye upatikanaji mdogo wa shule';

  @override
  String get otherReason => 'Nyingine';

  @override
  String get otherDescription => 'Hali nyingine ya kimazingira';

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

  @override
  String get settings => 'Mipangilio';

  @override
  String get appearance => 'Muonekano';

  @override
  String get darkMode => 'Modi ya Usiku';

  @override
  String get language => 'Lugha';

  @override
  String get about => 'Kuhusu';

  @override
  String get quickActions => 'Hatua za Haraka';

  @override
  String get continueLearning => 'Endelea Kujifunza';

  @override
  String get joinStudyGroup => 'Jiunge na Kikundi';

  @override
  String get subjects => 'Masomo';

  @override
  String get goodMorning => 'Habari za Asubuhi!';

  @override
  String get readyToLearn => 'Uko tayari kujifunza leo?';

  @override
  String get lessonPacks => 'Vifurushi vya Masomo';

  @override
  String get retry => 'Jaribu Tena';

  @override
  String get noLessonsAvailable => 'Hakuna masomo yanayopatikana';

  @override
  String get checkBackLater => 'Angalia baadaye kwa maudhui mapya';

  @override
  String get multipleLessons => 'Masomo mengi';

  @override
  String get lessons => 'Masomo';

  @override
  String get noLessonsInPack => 'Hakuna masomo kwenye kifurushi hiki';

  @override
  String get loading => 'Inapakia...';

  @override
  String get min => 'dakika';

  @override
  String get takeQuiz => 'Fanya Maswali';

  @override
  String get playingAudio => 'Inacheza maelezo ya sauti...';

  @override
  String get smartRecommendations => 'Mapendekezo ya Smart';

  @override
  String get recommendedForYou => 'Inapendekezwa kwako kulingana na maendeleo';

  @override
  String get aiRecommended => 'Inapendekezwa na AI';

  @override
  String get learningProgress => 'Maendeleo ya Masomo';

  @override
  String get codeSent => 'Verification code sent';
}
