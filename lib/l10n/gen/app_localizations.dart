import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonEmDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get commonEmDash;

  /// No description provided for @boardToolbarDomain.
  ///
  /// In en, this message translates to:
  /// **'· {domain}'**
  String boardToolbarDomain(String domain);

  /// No description provided for @boardTooltipTimeTracking.
  ///
  /// In en, this message translates to:
  /// **'Time tracking'**
  String get boardTooltipTimeTracking;

  /// No description provided for @boardTooltipMorningDigest.
  ///
  /// In en, this message translates to:
  /// **'Morning digest'**
  String get boardTooltipMorningDigest;

  /// No description provided for @boardTooltipAddAttention.
  ///
  /// In en, this message translates to:
  /// **'Add ticket that needs attention'**
  String get boardTooltipAddAttention;

  /// No description provided for @boardTooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get boardTooltipSettings;

  /// No description provided for @boardAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get boardAddDialogTitle;

  /// No description provided for @boardAddDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Add a ticket someone sent you (e.g. for an estimate). The time is recorded automatically.'**
  String get boardAddDialogHint;

  /// No description provided for @boardAddTicketKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket key'**
  String get boardAddTicketKeyLabel;

  /// No description provided for @boardAddTicketKeyHint.
  ///
  /// In en, this message translates to:
  /// **'PAY-123'**
  String get boardAddTicketKeyHint;

  /// No description provided for @boardAddSentByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent by'**
  String get boardAddSentByLabel;

  /// No description provided for @boardAddSentByHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Product Owner, Sarah…'**
  String get boardAddSentByHint;

  /// No description provided for @boardAddUnknownSender.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get boardAddUnknownSender;

  /// No description provided for @boardTicketNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find ticket \"{key}\".'**
  String boardTicketNotFound(String key);

  /// No description provided for @boardSyncedNever.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get boardSyncedNever;

  /// No description provided for @boardSyncedJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get boardSyncedJustNow;

  /// No description provided for @boardSyncedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String boardSyncedMinutesAgo(int minutes);

  /// No description provided for @boardSyncedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String boardSyncedHoursAgo(int hours);

  /// No description provided for @boardSyncedLabel.
  ///
  /// In en, this message translates to:
  /// **'Synced {when}'**
  String boardSyncedLabel(String when);

  /// No description provided for @boardConnAuthExpired.
  ///
  /// In en, this message translates to:
  /// **'Your Jira token expired — reconnect to continue.'**
  String get boardConnAuthExpired;

  /// No description provided for @boardConnOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing last synced data.'**
  String get boardConnOffline;

  /// No description provided for @boardConnReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get boardConnReconnect;

  /// No description provided for @boardNewTicketsBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} new tickets need attention'**
  String boardNewTicketsBanner(int count);

  /// No description provided for @boardNoTicketsMatch.
  ///
  /// In en, this message translates to:
  /// **'No tickets match your current filters.'**
  String get boardNoTicketsMatch;

  /// No description provided for @boardDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'⇅ drag to reorder'**
  String get boardDragToReorder;

  /// No description provided for @statusNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get statusNeedsAttention;

  /// No description provided for @connectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only · your Jira stays untouched'**
  String get connectSubtitle;

  /// No description provided for @connectErrorBanner.
  ///
  /// In en, this message translates to:
  /// **'⚠️ {error}'**
  String connectErrorBanner(String error);

  /// No description provided for @connectErrDomainEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your Jira domain.'**
  String get connectErrDomainEmpty;

  /// No description provided for @connectErrDomainInvalid.
  ///
  /// In en, this message translates to:
  /// **'Domain looks invalid — e.g. yourcompany.atlassian.net'**
  String get connectErrDomainInvalid;

  /// No description provided for @connectErrEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get connectErrEmailEmpty;

  /// No description provided for @connectErrEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Email format looks invalid.'**
  String get connectErrEmailInvalid;

  /// No description provided for @connectErrTokenEmpty.
  ///
  /// In en, this message translates to:
  /// **'Paste your API token.'**
  String get connectErrTokenEmpty;

  /// No description provided for @connectErrTokenShort.
  ///
  /// In en, this message translates to:
  /// **'That token looks too short — paste the full API token.'**
  String get connectErrTokenShort;

  /// No description provided for @connectErrAuth.
  ///
  /// In en, this message translates to:
  /// **'Could not authenticate. Check email and API token.'**
  String get connectErrAuth;

  /// No description provided for @connectErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Jira.'**
  String get connectErrNetwork;

  /// No description provided for @connectDomainLabel.
  ///
  /// In en, this message translates to:
  /// **'Jira Domain'**
  String get connectDomainLabel;

  /// No description provided for @connectDomainHint.
  ///
  /// In en, this message translates to:
  /// **'yourcompany.atlassian.net'**
  String get connectDomainHint;

  /// No description provided for @connectEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get connectEmailLabel;

  /// No description provided for @connectEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@company.com'**
  String get connectEmailHint;

  /// No description provided for @connectTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'API Token'**
  String get connectTokenLabel;

  /// No description provided for @connectTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your API token'**
  String get connectTokenHint;

  /// No description provided for @connectJqlLabel.
  ///
  /// In en, this message translates to:
  /// **'JQL filter (optional)'**
  String get connectJqlLabel;

  /// No description provided for @connectJqlHint.
  ///
  /// In en, this message translates to:
  /// **'project = \"ABC\" AND sprint in openSprints()'**
  String get connectJqlHint;

  /// No description provided for @connectLoadTickets.
  ///
  /// In en, this message translates to:
  /// **'Load Tickets  →'**
  String get connectLoadTickets;

  /// No description provided for @connectGetToken.
  ///
  /// In en, this message translates to:
  /// **'🔒 Get an API token ↗'**
  String get connectGetToken;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Settings saved ✓'**
  String get settingsSavedToast;

  /// No description provided for @settingsSectionAging.
  ///
  /// In en, this message translates to:
  /// **'Aging alerts — per status'**
  String get settingsSectionAging;

  /// No description provided for @settingsSectionTeam.
  ///
  /// In en, this message translates to:
  /// **'Team members'**
  String get settingsSectionTeam;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsAgingNewHint.
  ///
  /// In en, this message translates to:
  /// **'Untriaged — most urgent'**
  String get settingsAgingNewHint;

  /// No description provided for @settingsAgingInProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Usually off — being worked'**
  String get settingsAgingInProgressHint;

  /// No description provided for @settingsDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String settingsDaysShort(int days);

  /// No description provided for @settingsMorningDigestTime.
  ///
  /// In en, this message translates to:
  /// **'Morning digest time'**
  String get settingsMorningDigestTime;

  /// No description provided for @settingsSyncInterval.
  ///
  /// In en, this message translates to:
  /// **'Sync interval'**
  String get settingsSyncInterval;

  /// No description provided for @settingsSync5m.
  ///
  /// In en, this message translates to:
  /// **'5m'**
  String get settingsSync5m;

  /// No description provided for @settingsSync15m.
  ///
  /// In en, this message translates to:
  /// **'15m'**
  String get settingsSync15m;

  /// No description provided for @settingsSync30m.
  ///
  /// In en, this message translates to:
  /// **'30m'**
  String get settingsSync30m;

  /// No description provided for @settingsAgingCounts.
  ///
  /// In en, this message translates to:
  /// **'Aging counts'**
  String get settingsAgingCounts;

  /// No description provided for @settingsBusinessDays.
  ///
  /// In en, this message translates to:
  /// **'Business days'**
  String get settingsBusinessDays;

  /// No description provided for @settingsCalendarDays.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get settingsCalendarDays;

  /// No description provided for @settingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsNameHint;

  /// No description provided for @settingsEmailHint.
  ///
  /// In en, this message translates to:
  /// **'email@company.com'**
  String get settingsEmailHint;

  /// No description provided for @settingsAddMember.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get settingsAddMember;

  /// No description provided for @settingsDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect & erase all data'**
  String get settingsDisconnect;

  /// No description provided for @timeTitle.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Time Tracking'**
  String get timeTitle;

  /// No description provided for @timeExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get timeExport;

  /// No description provided for @timeSectionLog.
  ///
  /// In en, this message translates to:
  /// **'Log time'**
  String get timeSectionLog;

  /// No description provided for @timeTicketLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get timeTicketLabel;

  /// No description provided for @timeNoTicketOption.
  ///
  /// In en, this message translates to:
  /// **'📝 No ticket — add note'**
  String get timeNoTicketOption;

  /// No description provided for @timeHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get timeHoursLabel;

  /// No description provided for @timeNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you work on?'**
  String get timeNoteLabel;

  /// No description provided for @timeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sprint planning, interview, helping QA…'**
  String get timeNoteHint;

  /// No description provided for @timeWorkTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Work type'**
  String get timeWorkTypeLabel;

  /// No description provided for @timeAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get timeAddEntry;

  /// No description provided for @timeTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today — {date}'**
  String timeTodayLabel(String date);

  /// No description provided for @timeTotalHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h total'**
  String timeTotalHours(String hours);

  /// No description provided for @timeNothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet today.'**
  String get timeNothingLogged;

  /// No description provided for @timeErrInvalidHours.
  ///
  /// In en, this message translates to:
  /// **'Enter valid hours.'**
  String get timeErrInvalidHours;

  /// No description provided for @timeErrNoteRequired.
  ///
  /// In en, this message translates to:
  /// **'Write a short note about the work.'**
  String get timeErrNoteRequired;

  /// No description provided for @timeErrPickTicket.
  ///
  /// In en, this message translates to:
  /// **'Pick a ticket, or choose the note option.'**
  String get timeErrPickTicket;

  /// No description provided for @timeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'End of Day Summary'**
  String get timeSummaryTitle;

  /// No description provided for @timeCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard ✓'**
  String get timeCopied;

  /// No description provided for @timeNotePrefix.
  ///
  /// In en, this message translates to:
  /// **'📝 {label}'**
  String timeNotePrefix(String label);

  /// No description provided for @timeHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String timeHoursShort(String hours);

  /// No description provided for @workTypeMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get workTypeMeeting;

  /// No description provided for @workTypeDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get workTypeDevelopment;

  /// No description provided for @workTypeCodeReview.
  ///
  /// In en, this message translates to:
  /// **'Code Review'**
  String get workTypeCodeReview;

  /// No description provided for @workTypeBugFix.
  ///
  /// In en, this message translates to:
  /// **'Bug Fix'**
  String get workTypeBugFix;

  /// No description provided for @workTypeDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get workTypeDocumentation;

  /// No description provided for @workTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get workTypeOther;

  /// No description provided for @digestTitle.
  ///
  /// In en, this message translates to:
  /// **'☀️ Good morning'**
  String get digestTitle;

  /// No description provided for @digestDateSeparator.
  ///
  /// In en, this message translates to:
  /// **'· {date}'**
  String digestDateSeparator(String date);

  /// No description provided for @digestAgingBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} tickets are aging'**
  String digestAgingBanner(int count);

  /// No description provided for @digestAgingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Past your threshold · oldest first'**
  String get digestAgingSubtitle;

  /// No description provided for @digestSectionAging.
  ///
  /// In en, this message translates to:
  /// **'Aging — needs attention'**
  String get digestSectionAging;

  /// No description provided for @digestSectionNew.
  ///
  /// In en, this message translates to:
  /// **'New since yesterday'**
  String get digestSectionNew;

  /// No description provided for @digestFooter.
  ///
  /// In en, this message translates to:
  /// **'In Progress & Review never age — they’re being worked'**
  String get digestFooter;

  /// No description provided for @sidebarScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'My / Team'**
  String get sidebarScopeLabel;

  /// No description provided for @sidebarMyTickets.
  ///
  /// In en, this message translates to:
  /// **'My tickets'**
  String get sidebarMyTickets;

  /// No description provided for @sidebarTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get sidebarTeam;

  /// No description provided for @sidebarTeammates.
  ///
  /// In en, this message translates to:
  /// **'Teammates'**
  String get sidebarTeammates;

  /// No description provided for @sidebarShowStatuses.
  ///
  /// In en, this message translates to:
  /// **'Show statuses'**
  String get sidebarShowStatuses;

  /// No description provided for @sidebarProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get sidebarProjects;

  /// No description provided for @cardAgePill.
  ///
  /// In en, this message translates to:
  /// **'⏳ {age} in {status}'**
  String cardAgePill(String age, String status);

  /// No description provided for @cardProjectOnly.
  ///
  /// In en, this message translates to:
  /// **'📁 {project}'**
  String cardProjectOnly(String project);

  /// No description provided for @cardProjectWithType.
  ///
  /// In en, this message translates to:
  /// **'📁 {project} · {type}'**
  String cardProjectWithType(String project, String type);

  /// No description provided for @cardAttentionFrom.
  ///
  /// In en, this message translates to:
  /// **'👤 from {sender} · sent {ago}'**
  String cardAttentionFrom(String sender, String ago);

  /// No description provided for @cardMarkDone.
  ///
  /// In en, this message translates to:
  /// **'✓ Done'**
  String get cardMarkDone;

  /// No description provided for @detailUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get detailUnassigned;

  /// No description provided for @detailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailDescription;

  /// No description provided for @detailAssignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get detailAssignee;

  /// No description provided for @detailProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get detailProject;

  /// No description provided for @detailInStatus.
  ///
  /// In en, this message translates to:
  /// **'In status'**
  String get detailInStatus;

  /// No description provided for @detailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get detailType;

  /// No description provided for @detailProjectValue.
  ///
  /// In en, this message translates to:
  /// **'📁 {project}'**
  String detailProjectValue(String project);

  /// No description provided for @detailTypeValue.
  ///
  /// In en, this message translates to:
  /// **'🐞 {type}'**
  String detailTypeValue(String type);

  /// No description provided for @detailOpenInJira.
  ///
  /// In en, this message translates to:
  /// **'Open in Jira  ↗'**
  String get detailOpenInJira;

  /// No description provided for @updateBanner.
  ///
  /// In en, this message translates to:
  /// **'v{version} available — Download ↗'**
  String updateBanner(String version);

  /// No description provided for @updateDismissTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss this version'**
  String get updateDismissTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
