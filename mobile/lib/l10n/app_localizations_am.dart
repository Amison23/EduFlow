// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'EduFlow';

  @override
  String get appTagline => 'ለአፍሪካ ተፈናቃዮች የህይወት መስመር ትምህርት';

  @override
  String get aboutYou => 'ስለ እርሶ';

  @override
  String get whyAreYouDisplaced => 'ለምን ተፈናቀሉ?';

  @override
  String get currentLocation => 'ያሉበት ቦታ';

  @override
  String get selectYourLocation => 'ያሉበትን ቦታ ይምረጡ';

  @override
  String get preferredLanguage => 'ተመራጭ ቋንቋ';

  @override
  String get continueButton => 'ቀጥል';

  @override
  String get conflictDisplacement => 'ግጭት/መፈናቀል';

  @override
  String get conflictDescription => 'በግጭት ወይም በኃይል ምክንያት ተፈናቅያለሁ';

  @override
  String get climateDisaster => 'የአየር ንብረት አደጋ';

  @override
  String get climateDescription => 'በጎርፍ፣ በድርቅ ወይም በአየር ንብረት ለውጥ ምክንያት ተፈናቅያለሁ';

  @override
  String get otherReason => 'ሌላ';

  @override
  String get otherDescription => 'ሌላ የመፈናቀያ ምክንያት';

  @override
  String get worksOffline => 'ከመስመር ውጭ ይሰራል';

  @override
  String get worksOfflineDesc => 'ትምህርቶችን ያውርዱ እና ያለ ኢንተርኔት ይማሩ';

  @override
  String get smsLearning => 'የኤስኤምኤስ ትምህርት';

  @override
  String smsLearningDesc(Object shortcode) {
    return 'ኢንተርኔት የለም? ቁልፍ ቃላትን ወደ $shortcode በመላክ የእኛን የኤስኤምኤስ አገልግሎት ይጠቀሙ።';
  }

  @override
  String get studyGroups => 'የመማሪያ ቡድኖች';

  @override
  String get studyGroupsDesc => 'ከሌሎች ተማሪዎች ጋር ይገናኙ';

  @override
  String get getStarted => 'ይጀምሩ';

  @override
  String get phoneLogin => 'በስልክ ይግቡ';

  @override
  String get enterPhoneNumber => 'የስልክ ቁጥርዎን ያስገቡ';

  @override
  String get verificationCodeDesc => 'የማረጋገጫ ኮድ እንልክልዎታለን';

  @override
  String get phoneNumberLabel => 'የስልክ ቁጥር';

  @override
  String get phoneNumberHint => '+254712345678';

  @override
  String get sendCode => 'ኮድ ላክ';

  @override
  String get enterCode => 'ኮዱን ያስገቡ';

  @override
  String sentCodeTo(String phoneNumber) {
    return 'የ6 አሃዝ ኮድ ወደ $phoneNumber ልከናል';
  }

  @override
  String get verificationCodeLabel => 'የማረጋገጫ ኮድ';

  @override
  String get verify => 'አረጋግጥ';

  @override
  String get resendCode => 'ኮዱን ድጋሚ ላክ';

  @override
  String get changePhoneNumber => 'የስልክ ቁጥር ይቀይሩ';

  @override
  String get pleaseEnterPhone => 'እባክዎን የስልክ ቁጥር ያስገቡ';

  @override
  String get pleaseEnterOtp => 'እባክዎን የ6 አሃዝ ኮዱን ያስገቡ';

  @override
  String get helpAndGuide => 'እርዳታ እና መመሪያ';

  @override
  String get howToUseApp => 'መተግበሪያውን እንዴት መጠቀም እንደሚቻል';

  @override
  String get gettingStartedTitle => 'ለመጀመር';

  @override
  String get gettingStartedDesc =>
      'እንዴት መተግበሪያውን መጠቀም እና የመማር ጉዞዎን እንደሚጀምሩ ይወቁ።';

  @override
  String get offlineLearningTitle => 'ከመስመር ውጭ መማር';

  @override
  String get offlineLearningDesc =>
      'ትምህርቶችን በማውረድ በማንኛውም ቦታ እና ጊዜ በመጠቀም ዳታዎን ይቆጥቡ።';

  @override
  String get smsLearningTitle => 'የኤስኤምኤስ ትምህርት (ያለ ኢንተርኔት)';

  @override
  String get communityTitle => 'የመማሪያ ቡድኖች';

  @override
  String get communityDesc => 'ከጓደኞችዎ ጋር አብሮ ለመማር ቡድን ይቀላቀሉ ወይም ይፍጠሩ።';

  @override
  String get gotIt => 'ተረድቻለሁ!';
}
