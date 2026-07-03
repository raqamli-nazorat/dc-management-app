# Role-Based Access Control

## Backend role list

Backend (`roles` / `active_role` in login and `GET /users/me/` responses) sends
exactly 5 raw values, no aliases: `admin`, `manager`, `employee`, `auditor`,
`accountant`. `RoleType.fromRaw()` normalizes these 1:1 (case-insensitive/trim
only, no synonym handling — the backend contract is exact).

## Permission Matrix

| Section | Admin | Manager | Employee | Auditor (Nazoratchi) | Accountant |
|---|---|---|---|---|---|
| Bosh sahifa (Home) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Analitika (chart section embedded in `MainPage` — not a separate tab) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Foydalanuvchilar (Users tab) | ✅ | ❌ | ❌ | ✅ | ✅ |
| Loyihalar (Projects tab) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Moliya (Finance tab) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Hisobotlar (Reports tab) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Arizalar tugmasi (MainPage AppBar, bildirishnoma yonida — bo'lim hali qurilmagan) | ✅ | ✅ | ❌ | ✅ | ❌ |

**Ariza yaratish** — `isVisible(AppSection.applications, ...)` dan **alohida**
ruxsat: faqat **Menejer va Xodim** ariza yubora oladi (`canCreateApplication`).
Admin/Auditor/Hisobchi ariza yaratmaydi — Admin va Auditor tugmani ko'rsa ham,
faqat ko'rib chiqadi/boshqaradi. Xodim tugmani ko'rmaydi, lekin baribir ariza
yuborish nuqtasiga muhtoj (hali qurilmagan — masalan profilida yoki alohida
ekranda).

**Auditor (Nazoratchi)** — Admin kabi hamma bo'limni ko'radi, lekin hech
qayerda yaratish/tahrirlash/o'chirish/tasdiqlash (CRUD/approve) amalini
bajara olmaydi (`canPerformActions`). Bu cheklov o'z profilini tahrirlash /
parol o'zgartirishga taalluqli emas — ular ochiq qoladi.

## Architecture

### `RoleType` (`lib/core/access/role_type.dart`)

Backend'ning 5 ta xom qiymatini (`admin`, `manager`, `employee`, `auditor`,
`accountant`) kanonik enumga aylantiradi: `RoleType.fromRaw(raw)`. Noma'lum
qiymat → `RoleType.unknown` (xavfsiz default: hech narsa ko'rinmaydi).

`RolePresentation.of()` (`features/auth/presentation/role/role_presentation.dart`)
shu enumga tayanadi — label/ikonka mapping shu yerda qoladi
(`AppLocalizations` va `SvgGenImage`ga bog'liq), string parsing esa yagona
manbadan (`RoleType.fromRaw`) keladi.

### `NavPermissions` (`lib/core/access/nav_permissions.dart`)

- `AppSection` enum — `home, analytics, users, projects, finance, reports, applications`.
- `NavPermissions.isVisible(AppSection, RoleType)` — matritsadan ko'rinishni tekshiradi.
- `NavPermissions.canPerformActions(RoleType)` — faqat Auditor uchun `false`.
- `NavPermissions.canCreateApplication(RoleType)` — faqat Menejer/Xodim uchun `true`.

### `SessionState.activeRole` / `roleType`

`SessionState` (`lib/app/bloc/session_bloc.dart`da `part`) `activeRole: String?`
saqlaydi. Ikkita manbadan to'ldiriladi/yangilanadi:

1. **Login vaqtida** (`SessionLoggedIn`) — bitta rolli login'da avtomatik;
   ko'p rolli login'da `SessionRoleSelected`dan keyin.
2. **`GET /users/me/` javobidagi `active_role`** — `SessionActiveRoleSynced`
   event orqali, backend'dagi eng so'nggi qiymat bilan sinxronlanadi (bu
   autoritativ manba — login/rol tanlashdan keyin backend tomonda
   o'zgarishi mumkin). `MainPage`dagi `_MainView` `ProfileBloc` muvaffaqiyatli
   yuklangan har safar (`BlocListener<ProfileBloc, ProfileState>`) shu
   event'ni yuboradi.

Ikkala yo'l ham `StorageKeys.activeRole`ga yozadi (disk — PIN qayta kirish /
sovuq ishga tushirishda tiklash uchun) va `SessionState.activeRole`ni
yangilaydi (UI filtrlash uchun reaktiv). `SessionState.roleType` getter shu
qiymatni `RoleType.fromRaw` orqali kanonik turga aylantiradi.

## Usage

### Navigatsiya ko'rinishini tekshirish (`HomePage` patterni)

```dart
final role = context.select<SessionBloc, RoleType>((b) => b.state.roleType);
final visible = _sections.where((e) => NavPermissions.isVisible(e.$1, role));
```

`HomePage` (`lib/features/home/presentation/pages/home_page.dart`) `_sections`
(barcha tab) ro'yxatini har `build()`da rolga qarab filtrlaydi — `pages` va
`items` bitta iteratsiyadan olinadi, shu sabab indekslar doim mos keladi.

`MainPage`dagi Analitika bo'limi va Arizalar tugmasi xuddi shu tarzda, lekin
alohida tab emas — `if (NavPermissions.isVisible(AppSection.X, role)) ...`
bilan (mos ravishda `_Header` va `_MainView.build()` ichida).

### CRUD tugmalarini yashirish (`NavPermissions.canPerformActions`)

Users/Projects/Finance/Reports/Arizalar sahifalarida haqiqiy CRUD UI
qurilganda, har bir yaratish/tahrirlash/o'chirish/tasdiqlash tugmasi:

```dart
if (NavPermissions.canPerformActions(role)) ... // tugma ko'rsatiladi
```

### Auditor istisnosi

`canPerformActions` faqat ma'lumotlarni boshqarish (CRUD) amallariga
tegishli — profilni o'zini tahrirlash, parol o'zgartirish kabi shaxsiy
amallar bu tekshiruv bilan cheklanmaydi.

## Known Limitations

- `_onStarted`dagi tezkor tiklash yo'lida (`_hasToken && !_pinLockExpired`)
  `activeRole` diskdan o'qib to'ldiriladi, lekin `roles` (to'liq ro'yxat)
  bo'sh qoladi — bu oldindan mavjud bo'shliq. `MainPage` ochilganda
  `SessionActiveRoleSynced` baribir `activeRole`ni backend bilan
  yangilaydi, shu sabab bu amalda ta'sir qilmaydi.
- `HomePage`da `_currentIndex` filtrlangan ro'yxatdan uzun bo'lib qolsa
  (rol ilova ochiq turganda o'zgarsa — masalan backend `active_role`ni
  o'zgartirsa va `SessionActiveRoleSynced` yangi qiymat bilan kelsa) —
  `build()` ichida `0`ga clamp qilinadi.

## Future Work Checklist

### Arizalar / Applications feature qurilishi

- [ ] `AppSection.applications` + matritsa yozuvi + `canCreateApplication()`
      allaqachon `NavPermissions`da tayyor — feature (data/domain/presentation),
      route, `navApplications` l10n kaliti (uz/en) qo'shilsin.
- [ ] `MainPage` AppBar'dagi Arizalar tugmasi (`_Header`, hozir `onTap: () {}`
      stub) haqiqiy sahifaga yo'naltirilsin.
- [ ] "Yangi ariza" tugmasi/yuborish nuqtasi `NavPermissions.canCreateApplication(role)`
      bilan cheklansin — **`isVisible(AppSection.applications, ...)` bilan emas**:
      Xodim tugmani/bo'limni ko'rmaydi, lekin ariza yubora olishi kerak
      (alohida kirish nuqtasi kerak bo'ladi).

### Users / Projects / Finance / Reports — haqiqiy CRUD UI

- [ ] Har bir yaratish/tahrirlash/o'chirish/tasdiqlash tugmasi
      `NavPermissions.canPerformActions(role)` bilan o'ralsin.
- [ ] Auditor to'liq ko'rish huquqini saqlaydi (`isVisible`), lekin hech
      qanday yozish amalini ko'rmasligi/bajara olmasligi kerak.
- [ ] Profilni o'zini tahrirlash / parol o'zgartirish oqimlari bu tekshiruv
      bilan cheklanmasin.
