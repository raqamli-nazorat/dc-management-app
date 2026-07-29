# Biometric PIN Unlock Plan

## Maqsad

PIN code oynasida biometrik autentifikatsiya mavjudligini tekshirish va mavjud bo'lsa foydalanuvchiga barmoq izi yoki yuz orqali tasdiqlanib ilovaga kirish imkonini berish.

Bu funksiya faqat iOS va Android uchun sozlanadi. Web, macOS va Windows hozircha scope ichida emas.

## Qisqa Xulosa

Hozirgi app oqimida PIN code backend paroli sifatida ishlatiladi: foydalanuvchi PIN kiritganda login API qayta chaqiriladi va yangi token olinadi. `local_auth` esa backendga login qilmaydi; u faqat qurilma darajasida foydalanuvchi tasdiqlandi yoki tasdiqlanmadi degan natija beradi.

Shu sababli biometrika quyidagicha ishlashi kerak:

- PIN page ochilganda qurilmada biometrika mavjudligi va sozlanganligi tekshiriladi.
- Agar biometrika mavjud bo'lsa, PIN oynasida biometrik kirish tugmasi ko'rsatiladi.
- Foydalanuvchi biometrik tasdiqdan muvaffaqiyatli o'tsa, app mavjud tokenlar orqali sessiyani qayta ochadi.
- Agar token mavjud bo'lmasa, foydalanuvchi login page'ga yuboriladi.
- Biometrika PIN/parol loginini almashtirmaydi; u faqat saqlangan sessiyani ochish uchun shortcut bo'ladi.

## Scope

### Kiritiladi

- `local_auth` paketini qo'shish.
- Android va iOS platforma sozlamalarini kiritish.
- PIN page ochilganda biometrik imkoniyatni tekshirish.
- PIN page'da biometrik login tugmasi yoki gesture entry point qo'shish.
- Muvaffaqiyatli biometrik autentifikatsiyadan keyin mavjud token bilan sessiyani ochish.
- Token yo'q bo'lsa login page'ga yo'naltirish.
- Figma dev link asosida keyingi bosqichda PIN page redesign qilish uchun aniq joy qoldirish.
- Error case'larni UI va BLoC darajasida boshqarish.
- Unit/widget testlar uchun qabul mezonlarini belgilash.

### Kiritilmaydi

- Yangi backend endpoint.
- Biometrika orqali backenddan yangi token olish.
- PIN/parolni qurilmada saqlash.
- Secure storage migratsiyasi.
- Biometrik sozlamani profil sahifasidan yoqish/o'chirish.
- Web, macOS yoki Windows qo'llab-quvvatlashi.

## Figma Dev Link

PIN code oynasini redesign qilish uchun Figma dev link keyin beriladi.

Link joyi:

```text
Light mode: Implement this design from Figma.
@https://www.figma.com/design/dHyxWsT12fgB8rquYemVyT/Raqamli-Nazorat-design?node-id=340-133173&m=dev
Dark mode: Implement this design from Figma.
@https://www.figma.com/design/dHyxWsT12fgB8rquYemVyT/Raqamli-Nazorat-design?node-id=292-42995&m=dev
Icon qo'shilgan va uni generate qilib ishlatish mumkin.
```

Implementation vaqtida redesign ishlari ushbu plan bilan birga ko'rib chiqiladi, lekin biometrik sessiya mantiqi UI dizaynidan mustaqil saqlanishi kerak.

## Paket

Paket:

```yaml
dependencies:
  local_auth: ^3.0.2
```

`local_auth` qurilma autentifikatsiyasini chaqiradi:

- Android: fingerprint, face unlock yoki device credential imkoniyatlari platformaga bog'liq.
- iOS: Touch ID va Face ID.
- `authenticate()` natijasi `true` bo'lsa, foydalanuvchi lokal qurilma orqali tasdiqlangan hisoblanadi.
- Paket backend token yaratmaydi, refresh qilmaydi va parolni bilmaydi.

## Mavjud Auth Oqimi

Hozirgi holat:

1. Login page username va password bilan login API chaqiradi.
2. Login muvaffaqiyatli bo'lsa tokenlar storage'ga saqlanadi.
3. `StorageKeys.loginUsername` va `StorageKeys.pinLength` saqlanadi.
4. App background timeoutdan keyin `SessionBloc` `pinRequired` holatiga o'tadi.
5. PIN page ochiladi.
6. Foydalanuvchi PIN kiritadi.
7. PIN backend paroli sifatida login API'ga yuboriladi.
8. Login muvaffaqiyatli bo'lsa `SessionLoggedIn(token, roles)` orqali app home yoki role select oqimiga o'tadi.

Yangi biometrik oqim mavjud PIN oqimini buzmasligi kerak. PIN fallback doimo ishlashi shart.

## Yangi Biometrik Oqim

### Happy Path

1. `SessionBloc` holati `pinRequired` bo'ladi.
2. Router foydalanuvchini PIN page'ga olib keladi.
3. `PinBloc` yoki alohida biometric helper/service qurilmada biometrika borligini tekshiradi.
4. Agar biometrika mavjud va enrolled bo'lsa, UI biometrik tugmani ko'rsatadi.
5. Foydalanuvchi biometrik tugmani bosadi.
6. System biometric prompt ochiladi.
7. Foydalanuvchi barmoq izi yoki yuz orqali tasdiqlanadi.
8. App mavjud access tokenni storage'dan tekshiradi.
9. Token mavjud bo'lsa `SessionBloc` sessiyani `authenticated` holatiga qaytaradi.
10. Router avtomatik ravishda keyingi protected page'ga o'tkazadi.

### Token Yo'q Holati

1. Foydalanuvchi biometrikadan muvaffaqiyatli o'tadi.
2. App access token mavjud emasligini aniqlaydi.
3. Sessiya to'liq auth talab qiladigan holatga o'tkaziladi.
4. Router foydalanuvchini login page'ga yuboradi.
5. UI foydalanuvchiga qayta login qilish kerakligini bildiradi.

Bu holatda PIN page'da qolib ketish mumkin emas.

## Tavsiya Qilingan Arxitektura

### 1. Biometric Service

Yangi core service:

```text
lib/core/services/biometric_auth_service.dart
```

Mas'uliyat:

- `LocalAuthentication` instance bilan ishlash.
- Qurilmada biometrika ishlatish mumkinligini tekshirish.
- Enrolled biometrika bor yoki yo'qligini aniqlash.
- Biometrik promptni chaqirish.
- `LocalAuthException` xatolarini app ichki enumiga map qilish.

Tavsiya qilingan public API:

```dart
class BiometricAuthService {
  Future<BiometricAvailability> checkAvailability();
  Future<BiometricAuthResult> authenticate();
}
```

### 2. Biometric Availability Enum

Tavsiya qilingan holatlar:

```dart
enum BiometricAvailability {
  available,
  notSupported,
  notEnrolled,
  unavailable,
}
```

Ma'nosi:

- `available`: biometric tugmani ko'rsatish mumkin.
- `notSupported`: qurilma yoki platforma qo'llamaydi.
- `notEnrolled`: biometrika hardware bor, lekin foydalanuvchi barmoq/face sozlamagan.
- `unavailable`: vaqtinchalik yoki noma'lum sabab bilan ishlamayapti.

### 3. Biometric Auth Result Enum

Tavsiya qilingan holatlar:

```dart
enum BiometricAuthResult {
  success,
  userCanceled,
  failed,
  lockedOut,
  unavailable,
}
```

Ma'nosi:

- `success`: token tekshiruviga o'tish mumkin.
- `userCanceled`: foydalanuvchi promptni yopdi; PIN fallback ko'rsatiladi.
- `failed`: autentifikatsiya muvaffaqiyatsiz; PIN fallback ko'rsatiladi.
- `lockedOut`: juda ko'p urinish sabab biometrika vaqtincha bloklangan; PIN fallback ko'rsatiladi.
- `unavailable`: system UI yoki hardware mavjud emas; PIN fallback ko'rsatiladi.

### 4. SessionBloc Event

`SessionBloc`ga alohida event qo'shish tavsiya qilinadi:

```dart
class SessionBiometricUnlocked extends SessionEvent {
  const SessionBiometricUnlocked();
}
```

Mas'uliyat:

- Token mavjudligini tekshirish.
- Token mavjud bo'lsa `authenticated` emit qilish.
- Token mavjud bo'lmasa `unauthenticated` emit qilish.
- Role holatini storage'dan tiklash.
- Auto-lock timeout qiymatini state'ga qaytarish.
- Last active timestampni yangilash.

Muhim: bu event yangi token yaratmaydi va login API chaqirmaydi.

### 5. PinBloc O'zgarishlari

`PinBloc` quyidagi eventlarni olishi mumkin:

```dart
class PinBiometricAvailabilityChecked extends PinEvent {}
class PinBiometricPressed extends PinEvent {}
```

Yoki BLoC ichida aniqroq nom bilan:

```dart
class PinBiometricRequested extends PinEvent {
  const PinBiometricRequested();
}
```

`PinState`ga qo'shiladigan maydonlar:

```dart
final BiometricAvailability biometricAvailability;
final BiometricAuthResult? biometricResult;
final bool biometricPromptInProgress;
```

UI mantiqi:

- `biometricAvailability == available` bo'lsa biometric button ko'rsatiladi.
- `biometricPromptInProgress == true` bo'lsa PIN keypad vaqtincha disabled bo'lishi mumkin.
- `userCanceled` holatida error toast ko'rsatmaslik ma'qul; foydalanuvchi o'zi yopgan bo'ladi.
- `lockedOut`, `unavailable`, `failed` holatlarida qisqa lokalizatsiyalangan xabar ko'rsatiladi.

### 6. PIN Page Listener

Biometrik auth muvaffaqiyatli bo'lganda UI `SessionBloc`ga event yuboradi:

```dart
context.read<SessionBloc>().add(const SessionBiometricUnlocked());
```

Token yo'q holatini `SessionBloc` hal qiladi. Router esa mavjud guard orqali login page'ga olib boradi.

## Platforma Sozlamalari

### Android

#### 1. Manifest Permission

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

#### 2. MainActivity

`MainActivity` `FlutterFragmentActivity`dan meros olishi kerak:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

#### 3. minSdk

`local_auth` Android SDK 24+ talab qiladi. `android/app/build.gradle.kts` ichida `minSdk` 24 dan past bo'lmasligi kerak:

```kotlin
minSdk = 24
```

Agar loyiha Flutter default `minSdk`dan foydalanishda davom etsa, build vaqtida real qiymat 24+ ekanini tekshirish kerak.

#### 4. Theme

Android 8 va undan past versiyalarda crash bo'lmasligi uchun `LaunchTheme` AppCompat theme bilan mos bo'lishi kerak. Agar testlarda biometric prompt Android 8 qurilmada crash bersa, theme parent AppCompat variantiga o'tkaziladi.

Hozir scope iOS va Android bo'lgani uchun Android 8 real support talabi bo'lsa alohida tekshiriladi.

### iOS

#### 1. Face ID Usage Description

`ios/Runner/Info.plist` ichiga qo'shiladi:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Hisobingizga tez va xavfsiz kirish uchun Face ID ishlatiladi.</string>
```

#### 2. Deployment Target

iOS minimum target 13.0 yoki undan yuqori bo'lishi kerak. Loyihada hozir 13.0 sozlangan, lekin implementatsiya oldidan qayta tekshiriladi.

## Error Caselar

### 1. Qurilma Biometrikani Qo'llamaydi

Holat:

- `canCheckBiometrics == false`
- `isDeviceSupported() == false`

Kutilgan natija:

- Biometrik tugma ko'rsatilmaydi.
- PIN input normal ishlaydi.
- Foydalanuvchiga ortiqcha error ko'rsatilmaydi.

### 2. Biometrika Sozlanmagan

Holat:

- Qurilma biometric hardware'ga ega.
- `getAvailableBiometrics()` bo'sh qaytadi.

Kutilgan natija:

- Biometrik tugma ko'rsatilmaydi yoki disabled holatda bo'ladi.
- PIN fallback ishlaydi.
- Agar user tugmani bosib keyin aniqlansa, "Qurilmada biometrika sozlanmagan" xabari ko'rsatiladi.

### 3. Foydalanuvchi Promptni Bekor Qildi

Holat:

- `LocalAuthExceptionCode.userCanceled`
- yoki `authenticate()` false qaytaradi.

Kutilgan natija:

- PIN page'da qoladi.
- PIN keypad enabled bo'ladi.
- Error toast ko'rsatish shart emas; foydalanuvchi ongli ravishda bekor qilgan.

### 4. System Prompt Bekor Qilindi

Holat:

- App backgroundga o'tdi.
- Telefon qo'ng'irog'i yoki system event promptni yopdi.
- `LocalAuthExceptionCode.systemCanceled`
- `LocalAuthExceptionCode.timeout`

Kutilgan natija:

- PIN page'da qoladi.
- PIN fallback ishlaydi.
- `persistAcrossBackgrounding: true` ishlatilsa, app foregroundga qaytganda prompt qayta urinishi mumkin.
- Agar retry amalga oshmasa, foydalanuvchi PIN orqali kirishi mumkin.

### 5. Biometrika Vaqtincha Bloklandi

Holat:

- Juda ko'p noto'g'ri urinish.
- `LocalAuthExceptionCode.temporaryLockout`
- `LocalAuthExceptionCode.biometricLockout`

Kutilgan natija:

- PIN fallback ishlaydi.
- Xabar: "Biometrik kirish vaqtincha bloklandi. PIN orqali davom eting."
- Appning mavjud PIN throttle timeri bilan aralashtirilmaydi, chunki bu OS biometric lockout.

### 6. Hardware Vaqtincha Mavjud Emas

Holat:

- Sensor boshqa app tomonidan ishlatilmoqda.
- Hardware vaqtincha unavailable.
- `LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable`

Kutilgan natija:

- PIN fallback ishlaydi.
- Biometrik tugma disabled yoki yashirilgan holatga o'tishi mumkin.

### 7. Biometric UI Ochilmadi

Holat:

- `LocalAuthExceptionCode.uiUnavailable`
- Android Activity context mavjud emas.

Kutilgan natija:

- PIN fallback ishlaydi.
- Log yoziladi.
- Foydalanuvchiga umumiy xabar ko'rsatiladi.
- Android `FlutterFragmentActivity` sozlamasi qayta tekshiriladi.

### 8. Auth In Progress

Holat:

- Foydalanuvchi tugmani tez-tez bosdi.
- `LocalAuthExceptionCode.authInProgress`

Kutilgan natija:

- Ikkinchi prompt ochilmaydi.
- `biometricPromptInProgress` flag tugma double-tap holatini bloklaydi.
- PIN keypad normal holatga qaytadi.

### 9. Biometrika Muvaffaqiyatli, Token Bor

Holat:

- `authenticate()` true.
- `TokenService.getToken()` bo'sh emas.

Kutilgan natija:

- `SessionBiometricUnlocked` sessiyani authenticated qiladi.
- Router PIN page'dan chiqadi.
- Agar active role bor bo'lsa home yoki oldingi protected route davom etadi.
- Agar role selection kerak bo'lsa, mavjud guard role select page'ga olib boradi.

### 10. Biometrika Muvaffaqiyatli, Token Yo'q

Holat:

- `authenticate()` true.
- Access token yo'q yoki bo'sh.

Kutilgan natija:

- `SessionBloc` `unauthenticated` emit qiladi.
- Router login page'ga yuboradi.
- Login identifikatori va PIN uzunligi masalasi alohida ko'riladi: xavfsiz default - token yo'q bo'lsa to'liq login talab qilish.

### 11. Token Bor, Lekin Eskirgan

Holat:

- Access token bor, lekin keyingi API so'rovda 401 qaytadi.

Kutilgan natija:

- Mavjud `RefreshInterceptor` refresh token orqali access tokenni yangilashga urinadi.
- Refresh muvaffaqiyatli bo'lsa user appda qoladi.
- Refresh muvaffaqiyatsiz bo'lsa `SessionExpired` ishlaydi.
- `SessionExpired` hozir cached login mavjud bo'lsa PIN page'ga qaytaradi. Biometrik unlockdan keyingi refresh failure holatida login page'ga to'g'ridan-to'g'ri o'tish kerakmi yoki PIN page'ga qaytish kerakmi product qarori sifatida belgilanadi.

Tavsiya: agar refresh token ham yaroqsiz bo'lsa login page'ga o'tkazish xavfsizroq va tushunarliroq.

### 12. User Logout Qilgan

Holat:

- `SessionLogoutRequested` barcha auth ma'lumotlarini tozalaydi.

Kutilgan natija:

- Biometrik tugma ko'rsatilmaydi.
- App login page'ga o'tadi.
- Biometrika logoutdan keyin kirish imkonini bermasligi shart.

### 13. App Kill Qilinganidan Keyin Ochildi

Holat:

- App cold start bo'ldi.
- Cached login bor.
- Token bor yoki yo'q.

Kutilgan natija:

- Token bor va sessiya mantiqi ruxsat bersa, background timeoutga qarab PIN page ochiladi.
- PIN page biometrikani tekshiradi.
- Token bor bo'lsa biometrika orqali appga kirish mumkin.
- Token yo'q bo'lsa biometrika orqali login qilinmaydi, login page talab qilinadi.

### 14. Device Biometric Enrollment O'zgargan

Holat:

- Foydalanuvchi telefon sozlamalarida yangi barmoq/face qo'shdi yoki o'chirdi.

Kutilgan natija:

- App har PIN page ochilganda availabilityni qayta tekshiradi.
- Eski cached availabilityga ishonilmaydi.
- Hozircha enrollment change detection yoki secure key invalidation scope ichida emas.

## Localization

Yangi user-facing stringlar `.arb` fayllarga qo'shiladi:

- `biometricUnlock`
- `biometricPromptReason`
- `biometricNotAvailable`
- `biometricNotEnrolled`
- `biometricLocked`
- `biometricTryPin`
- `sessionExpiredLoginAgain`

Uzbek base:

```json
{
  "biometricUnlock": "Biometrika orqali kirish",
  "biometricPromptReason": "Hisobingizga kirishni tasdiqlang",
  "biometricNotAvailable": "Biometrik kirish mavjud emas",
  "biometricNotEnrolled": "Qurilmada biometrika sozlanmagan",
  "biometricLocked": "Biometrik kirish vaqtincha bloklandi",
  "biometricTryPin": "PIN orqali davom eting",
  "sessionExpiredLoginAgain": "Sessiya tugagan. Qayta login qiling"
}
```

English:

```json
{
  "biometricUnlock": "Use biometrics",
  "biometricPromptReason": "Confirm access to your account",
  "biometricNotAvailable": "Biometric sign-in is not available",
  "biometricNotEnrolled": "No biometrics are set up on this device",
  "biometricLocked": "Biometric sign-in is temporarily locked",
  "biometricTryPin": "Continue with PIN",
  "sessionExpiredLoginAgain": "Session expired. Please sign in again"
}
```

ARB o'zgargandan keyin:

```bash
flutter gen-l10n
```

## UI Talablar

Figma dev link kelgandan keyin final UI shu dizaynga moslanadi. Hozirgi plan bo'yicha UI minimal talablari:

- PIN input doim ko'rinadi.
- Biometrik button faqat `available` holatda ko'rinadi.
- Button double tapdan himoyalangan bo'ladi.
- Prompt ochiq paytda PIN keypad disabled bo'lishi mumkin.
- Prompt bekor qilinsa, PIN keypad darhol qayta ishlashi kerak.
- Error matnlar PIN error matnlari bilan bir xil joylashuv uslubiga mos bo'lishi kerak.
- Material `Icons.*` ishlatilmaydi; mavjud asset yoki Figma redesigndagi asset ishlatiladi.
- Har qanday yangi o'lcham `flutter_screenutil` orqali `.w`, `.h`, `.r`, `.sp` bilan yoziladi.
- Yangi rang kerak bo'lsa `AppColors` tokeniga qo'shiladi; raw hex page/widget ichida ishlatilmaydi.
- Barcha yangi matnlar l10n orqali olinadi.

## Security Qarorlar

### Token Saqlash

Hozirgi plan mavjud storage oqimini o'zgartirmaydi. Biometrika mavjud token orqali sessiyani ochadi.

Risk:

- Agar tokenlar `shared_preferences`da saqlanayotgan bo'lsa, bu secure storage darajasida himoyalanmagan.

Hozirgi qaror:

- Scope minimal bo'lgani uchun secure storage migratsiyasi qilinmaydi.

Keyingi tavsiya:

- Auth token va refresh tokenlarni platform secure storage'ga ko'chirish.
- Biometrik unlock bilan birga tokenlarni OS keystore/keychain orqali himoyalash.

### PIN/Password Saqlamaslik

PIN yoki password qurilmada plaintext saqlanmaydi. Biometrik auth muvaffaqiyatli bo'lsa ham backend login API uchun password yaratishga urinilmaydi.

### Biometrika Logoutdan Keyin Ishlamasligi

Logout barcha token va cached login ma'lumotlarini tozalaydi. Logoutdan keyin biometric unlock foydalanuvchini appga kiritmasligi shart.

## Implementation Bosqichlari

### Bosqich 1: Dependency va Platform Setup

Fayllar:

- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/.../MainActivity.kt`
- `android/app/build.gradle.kts`
- `ios/Runner/Info.plist`

Ishlar:

1. `local_auth` qo'shish.
2. Android biometric permission qo'shish.
3. Android `MainActivity`ni `FlutterFragmentActivity`ga o'tkazish.
4. Android `minSdk` 24+ ekanini kafolatlash.
5. iOS `NSFaceIDUsageDescription` qo'shish.
6. `flutter pub get` ishlatish.

### Bosqich 2: Core Biometric Service

Fayl:

- `lib/core/services/biometric_auth_service.dart`

Ishlar:

1. `LocalAuthentication` wrapper yozish.
2. Availability check qo'shish.
3. Authenticate method qo'shish.
4. `LocalAuthExceptionCode` mapping yozish.
5. Service'ni `injection_container.dart`ga register qilish.

### Bosqich 3: SessionBloc Unlock Event

Fayllar:

- `lib/app/bloc/session_event.dart`
- `lib/app/bloc/session_bloc.dart`
- ehtimol `lib/app/bloc/session_state.dart`

Ishlar:

1. `SessionBiometricUnlocked` event qo'shish.
2. Event handler yozish.
3. Token borligini tekshirish.
4. Token yo'q bo'lsa `unauthenticated` emit qilish.
5. Token bor bo'lsa `authenticated` emit qilish.
6. Last active timestampni yangilash.
7. Active role va auto lock timeoutni tiklash.

### Bosqich 4: PinBloc Biometric State

Fayllar:

- `lib/features/auth/presentation/pin/bloc/pin_event.dart`
- `lib/features/auth/presentation/pin/bloc/pin_state.dart`
- `lib/features/auth/presentation/pin/bloc/pin_bloc.dart`

Ishlar:

1. Availability check event qo'shish.
2. Biometric pressed event qo'shish.
3. State'ga biometric fields qo'shish.
4. PIN page yaratilganda availability check trigger qilish.
5. Authenticate resultni state orqali UI'ga chiqarish.
6. PIN fallback oqimini o'zgartirmaslik.

### Bosqich 5: PIN Page UI

Fayl:

- `lib/features/auth/presentation/pin/pages/pin_page.dart`

Ishlar:

1. Biometric button qo'shish.
2. Button faqat available holatda ko'rinsin.
3. Button bosilganda `PinBiometricRequested` yuborilsin.
4. `PinStatus` yoki alohida result orqali success eshitilsin.
5. Success bo'lsa `SessionBiometricUnlocked` yuborilsin.
6. Token yo'q bo'lsa router login page'ga olib borishini tekshirish.
7. Figma redesign link kelgach layout shu dizaynga moslanadi.

### Bosqich 6: Localization

Fayllar:

- `lib/l10n/app_uz.arb`
- `lib/l10n/app_en.arb`

Ishlar:

1. Yangi stringlarni qo'shish.
2. `flutter gen-l10n` ishlatish.
3. UI'da hardcoded user-facing string qolmaganini tekshirish.

### Bosqich 7: Test va Verification

Ishlar:

1. Biometric service mapping unit testlari.
2. `SessionBloc` event testlari.
3. `PinBloc` availability va result testlari.
4. Android build smoke test.
5. iOS build smoke test.
6. Real device test: Android fingerprint/face.
7. Real device test: iOS Face ID/Touch ID.

## Test Scenariylari

### Unit Testlar

1. Biometrika available bo'lsa state `available`.
2. Biometrika not enrolled bo'lsa state `notEnrolled`.
3. User cancel bo'lsa PIN state errorga tushmaydi yoki soft state beradi.
4. Lockout bo'lsa `lockedOut` result qaytadi.
5. Unknown exception bo'lsa `unavailable` yoki `failed` result qaytadi.
6. `SessionBiometricUnlocked` token bor holatda authenticated emit qiladi.
7. `SessionBiometricUnlocked` token yo'q holatda unauthenticated emit qiladi.
8. Logoutdan keyin biometric unlock authenticated qilmaydi.

### Widget Testlar

1. Biometric unavailable bo'lsa button ko'rinmaydi.
2. Biometric available bo'lsa button ko'rinadi.
3. Button bosilganda biometric event yuboriladi.
4. Prompt in progress bo'lsa button disabled bo'ladi.
5. Biometric cancel holatida PIN keypad ishlashda davom etadi.
6. Biometric success holatida `SessionBiometricUnlocked` chaqiriladi.

### Manual Real Device Testlar

#### Android

1. Fingerprint sozlangan qurilmada PIN page biometric button ko'rinadi.
2. Fingerprint bilan tasdiqlanganda home yoki role select ochiladi.
3. Fingerprint prompt bekor qilinsa PIN page qoladi.
4. Fingerprint noto'g'ri bir necha marta berilsa PIN fallback ishlaydi.
5. Token tozalangandan keyin biometrik tasdiq login page'ga yuboradi.

#### iOS

1. Face ID sozlangan qurilmada biometric button ko'rinadi.
2. Face ID muvaffaqiyatli bo'lsa app protected page'ga o'tadi.
3. Face ID bekor qilinsa PIN page qoladi.
4. Face ID permission matni to'g'ri chiqadi.
5. Token yo'q bo'lsa login page'ga o'tadi.

## Acceptance Criteria

Funksiya tugallangan hisoblanadi, agar:

- Android va iOS platforma sozlamalari kiritilgan bo'lsa.
- PIN page biometric availabilityni tekshirsa.
- Biometric mavjud bo'lmagan qurilmada PIN oqimi o'zgarmasdan ishlasa.
- Biometric mavjud qurilmada button ko'rinsa.
- Biometric success + token bor holatda app protected page'ga o'tsa.
- Biometric success + token yo'q holatda login page'ga o'tsa.
- User cancel, lockout, unavailable holatlari appni buzmasa.
- PIN fallback har doim ishlasa.
- Logoutdan keyin biometric unlock orqali kirib bo'lmasa.
- `flutter analyze lib` 0 issue bilan o'tsa.
- Tegishli testlar o'tsa.

## Open Qarorlar

1. Refresh token yaroqsiz bo'lgan biometric unlockdan keyingi 401 holatida foydalanuvchi PIN page'ga qaytadimi yoki login page'ga o'tadimi?

   Tavsiya: login page. Sabab: biometrika server sessiyasini tiklay olmaydi.

2. Biometric button doim ko'rinadimi yoki faqat availability `available` bo'lsa ko'rinadimi?

   Tavsiya: faqat available holatda ko'rsatish.

3. User biometrik promptni bekor qilsa toast ko'rsatiladimi?

   Tavsiya: yo'q. Bu xato emas, foydalanuvchi tanlovi.

4. Biometric unlock uchun alohida profil sozlamasi kerakmi?

   Tavsiya: hozircha yo'q. Agar product talab qilsa keyingi bosqichda qo'shiladi.

## Risklar

- `local_auth` system prompt UI'si to'liq custom qilinmaydi; platforma cheklovlari bor.
- Android Activity noto'g'ri sozlansa prompt ochilmaydi yoki crash bo'lishi mumkin.
- Token storage hozir secure storage emas; biometrika mavjud tokenni himoyalangan secretga aylantirmaydi.
- Qurilmaga yangi biometrik credential qo'shilsa, OS uni ham valid deb qabul qilishi mumkin.
- Simulator/emulator testlari real biometrik tajribani to'liq qoplamaydi; real device test shart.

## Ponytail Qarori

Eng minimal ishlaydigan yechim:

- `local_auth`ni faqat PIN page shortcut sifatida ishlatish.
- Password/PINni saqlamaslik.
- Backend login oqimini o'zgartirmaslik.
- Token bor bo'lsa unlock qilish, token yo'q bo'lsa login page'ga yuborish.

Bu hozirgi talabni eng kam risk bilan yopadi. Secure storage, profil sozlamasi va enrollment invalidation keyingi aniq talab bo'lganda qo'shiladi.
