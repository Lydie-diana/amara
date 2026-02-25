// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أمارا';

  @override
  String get tagline => 'النكهة الأفريقية، تُوصَّل إليك';

  @override
  String get splashLoading => 'جارٍ التحميل...';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ الآن';

  @override
  String get onboarding1Title => 'المطبخ الأفريقي\nفي متناول يدك';

  @override
  String get onboarding1Desc =>
      'اكتشف مئات الأطباق الأصيلة التي يعدّها أفضل المطاعم الأفريقية في مدينتك.';

  @override
  String get onboarding2Title => 'توصيل سريع\nوموثوق';

  @override
  String get onboarding2Desc =>
      'تتبّع طلبك في الوقت الفعلي واستقبل أطباقك الساخنة في أقل من 45 دقيقة.';

  @override
  String get onboarding3Title => 'دفع سهل\nوآمن';

  @override
  String get onboarding3Desc =>
      'Mobile Money أو بطاقة مصرفية أو نقداً — اختر طريقة الدفع المناسبة لك.';

  @override
  String get authWelcomeTo => 'مرحباً بك في';

  @override
  String get authPhoneTitle => 'أمارا 🍛';

  @override
  String get authPhoneSubtitle => 'أدخل رقم هاتفك\nللمتابعة';

  @override
  String get authPhoneHint => '00 00 00 00 00';

  @override
  String get authPhoneSmsInfo =>
      'سيتم إرسال رمز التحقق عبر الرسائل القصيرة إلى هذا الرقم.';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authOrWith => 'أو المتابعة بـ';

  @override
  String get authGoogleButton => 'المتابعة مع Google';

  @override
  String get otpTitle => 'التحقق';

  @override
  String otpSubtitle(String phone) {
    return 'تم إرسال الرمز إلى\n$phone';
  }

  @override
  String otpResendIn(int seconds) {
    return 'إعادة إرسال خلال $seconds ث';
  }

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String get otpVerify => 'تحقق';

  @override
  String get otpError => 'رمز غير صحيح، حاول مجدداً';

  @override
  String get otpResent => 'تم إعادة إرسال الرمز!';

  @override
  String get profileTitle => 'ملفك الشخصي';

  @override
  String get profileSubtitle => 'أخبرنا كيف ننادي عليك';

  @override
  String get profileNameLabel => 'الاسم الأول والأخير *';

  @override
  String get profileNameHint => 'مثال: كوفي منساه';

  @override
  String get profileEmailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get profileEmailHint => 'بريدك@example.com';

  @override
  String get profileSave => 'هيا نبدأ! 🚀';

  @override
  String get profileNameRequired => 'هذا الحقل مطلوب';

  @override
  String get profileNameTooShort => 'الحد الأدنى حرفان';

  @override
  String get profileEmailInvalid => 'بريد إلكتروني غير صالح';

  @override
  String homeGreeting(String name) {
    return 'يوم سعيد، $name 👋';
  }

  @override
  String get homeLocation => 'أبيدجان، كوت ديفوار';

  @override
  String get homeSearchHint => 'ابحث عن مطعم أو طبق...';

  @override
  String get homeCuisines => 'المطابخ';

  @override
  String get homePopular => 'الأكثر شعبية قربك';

  @override
  String get homeNew => 'وافدون جدد';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryStew => 'يخنة';

  @override
  String get categoryGrill => 'مشويات';

  @override
  String get categoryRice => 'أرز';

  @override
  String get categorySalad => 'سلطة';

  @override
  String get categoryPizza => 'بيتزا';

  @override
  String get categoryBurger => 'برغر';

  @override
  String get categoryDrink => 'مشروب';

  @override
  String get categoryDessert => 'حلوى';

  @override
  String get restaurantOpen => 'مفتوح';

  @override
  String get restaurantClosed => 'مغلق';

  @override
  String get restaurantFeatured => '⭐ مشهور';

  @override
  String get restaurantFreeDelivery => 'مجاني';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشاف';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navProfile => 'الملف';

  @override
  String get promoTag1 => 'عرض خاص';

  @override
  String get promoTitle1 => 'توصيل مجاني';

  @override
  String get promoSubtitle1 => 'على طلبك الأول';

  @override
  String get promoTag2 => 'جديد';

  @override
  String get promoTitle2 => 'مطبخ أفريقي';

  @override
  String get promoSubtitle2 => 'الأصالة في متناولك';

  @override
  String get promoTag3 => 'خصم';

  @override
  String get promoTitle3 => '-20% الليلة';

  @override
  String get promoSubtitle3 => 'مطاعم شريكة مختارة';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorNetwork => 'خطأ في الشبكة، حاول مجدداً';

  @override
  String get errorGeneric => 'حدث خطأ ما';
}
