// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonDone => 'Done';

  @override
  String get commonEmDash => '—';

  @override
  String boardToolbarDomain(String domain) {
    return '· $domain';
  }

  @override
  String get boardTooltipTimeTracking => 'Time tracking';

  @override
  String get boardTooltipMorningDigest => 'Morning digest';

  @override
  String get boardTooltipAddAttention => 'Add ticket that needs attention';

  @override
  String get boardTooltipSettings => 'Settings';

  @override
  String get boardAddDialogTitle => 'Needs attention';

  @override
  String get boardAddDialogHint =>
      'Add a ticket someone sent you (e.g. for an estimate). The time is recorded automatically.';

  @override
  String get boardAddTicketKeyLabel => 'Ticket key';

  @override
  String get boardAddTicketKeyHint => 'PAY-123';

  @override
  String get boardAddSentByLabel => 'Sent by';

  @override
  String get boardAddSentByHint => 'e.g. Product Owner, Sarah…';

  @override
  String get boardAddUnknownSender => 'Unknown';

  @override
  String boardTicketNotFound(String key) {
    return 'Could not find ticket \"$key\".';
  }

  @override
  String get boardSyncedNever => 'never';

  @override
  String get boardSyncedJustNow => 'just now';

  @override
  String boardSyncedMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String boardSyncedHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String boardSyncedLabel(String when) {
    return 'Synced $when';
  }

  @override
  String get boardConnAuthExpired =>
      'Your Jira token expired — reconnect to continue.';

  @override
  String get boardConnOffline => 'Offline — showing last synced data.';

  @override
  String get boardConnReconnect => 'Reconnect';

  @override
  String boardNewTicketsBanner(int count) {
    return '$count new tickets need attention';
  }

  @override
  String get boardNoTicketsMatch => 'No tickets match your current filters.';

  @override
  String get boardDragToReorder => '⇅ drag to reorder';

  @override
  String get statusNeedsAttention => 'Needs Attention';

  @override
  String get connectSubtitle => 'Read-only · your Jira stays untouched';

  @override
  String connectErrorBanner(String error) {
    return '⚠️ $error';
  }

  @override
  String get connectErrDomainEmpty => 'Enter your Jira domain.';

  @override
  String get connectErrDomainInvalid =>
      'Domain looks invalid — e.g. yourcompany.atlassian.net';

  @override
  String get connectErrEmailEmpty => 'Enter your email.';

  @override
  String get connectErrEmailInvalid => 'Email format looks invalid.';

  @override
  String get connectErrTokenEmpty => 'Paste your API token.';

  @override
  String get connectErrTokenShort =>
      'That token looks too short — paste the full API token.';

  @override
  String get connectErrAuth =>
      'Could not authenticate. Check email and API token.';

  @override
  String get connectErrNetwork => 'Could not reach Jira.';

  @override
  String get connectDomainLabel => 'Jira Domain';

  @override
  String get connectDomainHint => 'yourcompany.atlassian.net';

  @override
  String get connectEmailLabel => 'Email';

  @override
  String get connectEmailHint => 'you@company.com';

  @override
  String get connectTokenLabel => 'API Token';

  @override
  String get connectTokenHint => 'Paste your API token';

  @override
  String get connectJqlLabel => 'JQL filter (optional)';

  @override
  String get connectJqlHint => 'project = \"ABC\" AND sprint in openSprints()';

  @override
  String get connectLoadTickets => 'Load Tickets  →';

  @override
  String get connectGetToken => '🔒 Get an API token ↗';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSavedToast => 'Settings saved ✓';

  @override
  String get settingsSectionAging => 'Aging alerts — per status';

  @override
  String get settingsSectionTeam => 'Team members';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsAgingNewHint => 'Untriaged — most urgent';

  @override
  String get settingsAgingInProgressHint => 'Usually off — being worked';

  @override
  String settingsDaysShort(int days) {
    return '${days}d';
  }

  @override
  String get settingsMorningDigestTime => 'Morning digest time';

  @override
  String get settingsSyncInterval => 'Sync interval';

  @override
  String get settingsSync5m => '5m';

  @override
  String get settingsSync15m => '15m';

  @override
  String get settingsSync30m => '30m';

  @override
  String get settingsAgingCounts => 'Aging counts';

  @override
  String get settingsBusinessDays => 'Business days';

  @override
  String get settingsCalendarDays => 'Calendar';

  @override
  String get settingsNameHint => 'Name';

  @override
  String get settingsEmailHint => 'email@company.com';

  @override
  String get settingsAddMember => '+ Add';

  @override
  String get settingsDisconnect => 'Disconnect & erase all data';

  @override
  String get timeTitle => '⏱️ Time Tracking';

  @override
  String get timeExport => 'Export';

  @override
  String get timeSectionLog => 'Log time';

  @override
  String get timeTicketLabel => 'Ticket';

  @override
  String get timeNoTicketOption => '📝 No ticket — add note';

  @override
  String get timeHoursLabel => 'Hours';

  @override
  String get timeNoteLabel => 'What did you work on?';

  @override
  String get timeNoteHint => 'e.g. Sprint planning, interview, helping QA…';

  @override
  String get timeWorkTypeLabel => 'Work type';

  @override
  String get timeAddEntry => 'Add entry';

  @override
  String timeTodayLabel(String date) {
    return 'Today — $date';
  }

  @override
  String timeTotalHours(String hours) {
    return '${hours}h total';
  }

  @override
  String get timeNothingLogged => 'Nothing logged yet today.';

  @override
  String get timeErrInvalidHours => 'Enter valid hours.';

  @override
  String get timeErrNoteRequired => 'Write a short note about the work.';

  @override
  String get timeErrPickTicket => 'Pick a ticket, or choose the note option.';

  @override
  String get timeSummaryTitle => 'End of Day Summary';

  @override
  String get timeCopied => 'Copied to clipboard ✓';

  @override
  String timeNotePrefix(String label) {
    return '📝 $label';
  }

  @override
  String timeHoursShort(String hours) {
    return '${hours}h';
  }

  @override
  String get workTypeMeeting => 'Meeting';

  @override
  String get workTypeDevelopment => 'Development';

  @override
  String get workTypeCodeReview => 'Code Review';

  @override
  String get workTypeBugFix => 'Bug Fix';

  @override
  String get workTypeDocumentation => 'Documentation';

  @override
  String get workTypeOther => 'Other';

  @override
  String get digestTitle => '☀️ Good morning';

  @override
  String digestDateSeparator(String date) {
    return '· $date';
  }

  @override
  String digestAgingBanner(int count) {
    return '$count tickets are aging';
  }

  @override
  String get digestAgingSubtitle => 'Past your threshold · oldest first';

  @override
  String get digestSectionAging => 'Aging — needs attention';

  @override
  String get digestSectionNew => 'New since yesterday';

  @override
  String get digestFooter =>
      'In Progress & Review never age — they’re being worked';

  @override
  String get sidebarScopeLabel => 'My / Team';

  @override
  String get sidebarMyTickets => 'My tickets';

  @override
  String get sidebarTeam => 'Team';

  @override
  String get sidebarTeammates => 'Teammates';

  @override
  String get sidebarShowStatuses => 'Show statuses';

  @override
  String get sidebarProjects => 'Projects';

  @override
  String cardAgePill(String age, String status) {
    return '⏳ $age in $status';
  }

  @override
  String cardProjectOnly(String project) {
    return '📁 $project';
  }

  @override
  String cardProjectWithType(String project, String type) {
    return '📁 $project · $type';
  }

  @override
  String cardAttentionFrom(String sender, String ago) {
    return '👤 from $sender · sent $ago';
  }

  @override
  String get cardMarkDone => '✓ Done';

  @override
  String get detailUnassigned => 'Unassigned';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailAssignee => 'Assignee';

  @override
  String get detailProject => 'Project';

  @override
  String get detailInStatus => 'In status';

  @override
  String get detailType => 'Type';

  @override
  String detailProjectValue(String project) {
    return '📁 $project';
  }

  @override
  String detailTypeValue(String type) {
    return '🐞 $type';
  }

  @override
  String get detailOpenInJira => 'Open in Jira  ↗';

  @override
  String updateBanner(String version) {
    return 'v$version available — Download ↗';
  }

  @override
  String get updateDismissTooltip => 'Dismiss this version';
}
