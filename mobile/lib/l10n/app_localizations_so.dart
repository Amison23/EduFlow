// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppLocalizationsSo extends AppLocalizations {
  AppLocalizationsSo([String locale = 'so']) : super(locale);

  @override
  String get appName => 'EduFlow';

  @override
  String get appTagline => 'Barashada Guruubyada ee Dhammaan Baratayaasha';

  @override
  String get aboutYou => 'Kugusaabsan';

  @override
  String get whyAreYouDisplaced => 'Nooga warran xaaladdaada';

  @override
  String get currentLocation => 'Goobta aad hadda ku sugan tahay';

  @override
  String get selectYourLocation => 'Dooro goobtaada';

  @override
  String get preferredLanguage => 'Luuqadda aad door bidayso';

  @override
  String get continueButton => 'Sii wad';

  @override
  String get conflictDisplacement => 'Colaad/Barokac';

  @override
  String get conflictDescription =>
      'Waxa la iiga barokiciyay colaad ama rabshado';

  @override
  String get climateDisaster => 'Masiibada Cimilada';

  @override
  String get climateDescription =>
      'Waxa la iiga barokiciyay daadad, abaaro, ama isbeddelka cimilada';

  @override
  String get remoteRegion => 'Gobolka Fog';

  @override
  String get remoteRegionDescription =>
      'Waxaan ku noolahay meel fog oo helitaanka dugsiyadu ku xaddidan yahay';

  @override
  String get otherReason => 'Sababo kale';

  @override
  String get otherDescription => 'Xaalad kale';

  @override
  String get worksOffline => 'Wuxuu ku shaqeeyaa internet la\'aan';

  @override
  String get worksOfflineDesc =>
      'Soo dejiso casharrada oo baro adigoon internet haysan';

  @override
  String get smsLearning => 'Barashada SMS';

  @override
  String smsLearningDesc(Object shortcode) {
    return 'Internet ma haysid? Isticmaal adeeggayaga SMS adoo u diraya ereyo muhiim ah $shortcode.';
  }

  @override
  String get studyGroups => 'Kooxaha Waxbarashada';

  @override
  String get studyGroupsDesc => 'La xiriir baratayaasha kale';

  @override
  String get getStarted => 'Bilow';

  @override
  String get phoneLogin => 'Galitaanka Taleefanka';

  @override
  String get enterPhoneNumber => 'Geli lambarkaaga taleefanka';

  @override
  String get verificationCodeDesc =>
      'Waxaan kuu soo diri doonaa koodka xaqiijinta';

  @override
  String get phoneNumberLabel => 'Lambarka Taleefanka';

  @override
  String get phoneNumberHint => '+254712345678';

  @override
  String get sendCode => 'Diri Koodka';

  @override
  String get enterCode => 'Geli koodka';

  @override
  String sentCodeTo(String phoneNumber) {
    return 'Waxaan u dirnay kood 6-lambarka ah $phoneNumber';
  }

  @override
  String get verificationCodeLabel => 'Koodka Xaqiijinta';

  @override
  String get verify => 'Xaqiiji';

  @override
  String get resendCode => 'Dib u soo diri koodka';

  @override
  String get changePhoneNumber => 'Beddel Lambarka Taleefanka';

  @override
  String get pleaseEnterPhone => 'Fadlan geli lambarka taleefanka';

  @override
  String get pleaseEnterOtp => 'Fadlan geli koodka 6-lambarka ah';

  @override
  String get helpAndGuide => 'Caawinta & Hagaha';

  @override
  String get howToUseApp => 'Sida loo isticmaalo app-ka';

  @override
  String get gettingStartedTitle => 'Bilaabidda';

  @override
  String get gettingStartedDesc =>
      'Baro sida loo dhex maro oo loo bilaabo safarkaaga waxbarasho.';

  @override
  String get offlineLearningTitle => 'Barashada Internet la\'aanta';

  @override
  String get offlineLearningDesc =>
      'Badbaadi xogta adoo soo dejisanaya casharrada si aad u isticmaasho meel kasta, wakhti kasta.';

  @override
  String get smsLearningTitle => 'Casharrada SMS (Internet la\'aan)';

  @override
  String get communityTitle => 'Kooxaha Waxbarashada';

  @override
  String get communityDesc =>
      'Ku biir ama abuur koox si aad wax ula barato saaxiibbadaa.';

  @override
  String get gotIt => 'Waan fahmay!';

  @override
  String get settings => 'Dejinta';

  @override
  String get appearance => 'Muuqaalka';

  @override
  String get darkMode => 'Habka Mugdiga';

  @override
  String get language => 'Luuqadda';

  @override
  String get about => 'Ku saabsan';

  @override
  String get quickActions => 'Tallaabooyinka Degdegga ah';

  @override
  String get continueLearning => 'Sii wad Barashada';

  @override
  String get joinStudyGroup => 'Ku biir Kooxda Waxbarashada';

  @override
  String get subjects => 'Madooyinka';

  @override
  String get goodMorning => 'Subax wanaagsan!';

  @override
  String get readyToLearn => 'Ma u diyaarsan tahay inaad maanta wax barato?';

  @override
  String get lessonPacks => 'Xirmooyinka Casharka';

  @override
  String get retry => 'Isku day mar kale';

  @override
  String get noLessonsAvailable => 'Ma jiraan casharro la heli karo';

  @override
  String get checkBackLater => 'Mar kale iska hubi casharro cusub';

  @override
  String get multipleLessons => 'Casharro badan';

  @override
  String get lessons => 'Casharro';

  @override
  String get noLessonsInPack => 'Ma jiraan casharro ku jira xirmadan';

  @override
  String get loading => 'Waa la xoorinayaa...';

  @override
  String get min => 'daqiiqo';

  @override
  String get takeQuiz => 'Qaad Kediska';

  @override
  String get playingAudio => 'Dhegeysiga nuxurka codka...';

  @override
  String get smartRecommendations => 'Talooyinka Caqliga leh';

  @override
  String get recommendedForYou =>
      'Lagula taliyay adiga oo ku salaysan horumarkaaga';

  @override
  String get aiRecommended => 'AI ay ku talisay';

  @override
  String get learningProgress => 'Horumarka Waxbarashada';

  @override
  String get codeSent => 'Koodhka xaqiijinta ayaa la soo diray';
}
