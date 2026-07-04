/// The app's design language. Import this one file to use any component:
///
///   import 'package:triage/widgets/ui/ui.dart';
///
/// Components:
///  - AppTextField / appInputDecoration  (app_text_field.dart)
///  - AppButton / AppSecondaryButton / AppIconButton  (app_button.dart)
///  - showAppDialog / DialogHint  (app_dialog.dart)
///  - SectionHeader  (section_header.dart)
///  - AppToggle  (app_toggle.dart)
///
/// Rule: screens never write InputDecoration, button styling, or dialog
/// shapes inline — they use these components. Change the design here once
/// and the whole app follows.
library ui;

export 'app_text_field.dart';
export 'app_button.dart';
export 'app_dialog.dart';
export 'section_header.dart';
export 'app_toggle.dart';
