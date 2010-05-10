package com.enilsson.elephantadmin.controllers
{
	import com.adobe.cairngorm.control.FrontController;
	import com.enilsson.elephantadmin.commands.*;
	import com.enilsson.elephantadmin.commands.modules.*;
	import com.enilsson.elephantadmin.commands.modules.app_options.*;
	import com.enilsson.elephantadmin.commands.modules.batch.*;
	import com.enilsson.elephantadmin.commands.popups.*;
	import com.enilsson.elephantadmin.events.*;
	import com.enilsson.elephantadmin.events.login.*;
	import com.enilsson.elephantadmin.events.main.*;
	import com.enilsson.elephantadmin.events.modules.*;
	import com.enilsson.elephantadmin.events.modules.app_options.*;
	import com.enilsson.elephantadmin.events.modules.batch.*;
	import com.enilsson.elephantadmin.events.popups.*;
	import com.enilsson.elephantadmin.events.session.*;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.commands.*;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.events.*;

	public class EAController extends FrontController
	{
		public function EAController()
		{
			super();

			registerCommands();
		}

		private function registerCommands():void
		{			
			// initialisation of app
			this.addCommand(InitAppEvent.EVENT_INIT_APP, InitAppCommand);
			this.addCommand(URLChangeEvent.EVENT_URL_CHANGE, URLChangeCommand);
			this.addCommand(GetVersionEvent.GET_VERSION, GetVersionCommand);

			// login
			this.addCommand(LoginEvent.EVENT_LOGIN, LoginCommand);
			this.addCommand(LoginEvent.EVENT_LOGIN_FORGOT, LoginCommand);
			this.addCommand(RegisterGatewayEvent.EVENT_REGISTER_GATEWAY, RegisterGatewayCommand);
			
			// ui access
			this.addCommand(UIAccessEvent.GET_UI_ACCESS_RIGHTS, UIAccessCommand);
			this.addCommand(UIAccessEvent.SET_UI_ACCESS_RIGHTS, UIAccessCommand);
			
			// session 
			this.addCommand(SessionEvent.GET_SESSION_INFO, SessionCommand);
			this.addCommand(SessionEvent.END_SESSION, SessionCommand);
			this.addCommand(SessionEvent.CHECK_SUPERUSER, SessionCommand);
			this.addCommand(PingEvent.EVENT_PING, SessionCommand);
			this.addCommand(SessionFailEvent.EVENT_SESSION_FAIL, SessionCommand);
			this.addCommand(SessionEvent.SESSION_WHEEL, SessionCommand);
				
			// initialisation of main app view
			this.addCommand(SessionEvent.INIT_SESSION_CHECK, InitMainCommand);
			this.addCommand(InitMainEvent.EVENT_MAIN_APP, InitMainCommand);
			this.addCommand(ViewStateEvent.EVENT_VIEW_STATE, ViewStateCommand);
			this.addCommand(GetSiteLayoutEvent.EVENT_GET_LAYOUT, InitMainCommand);
			this.addCommand(GetGroupsEvent.EVENT_GET_GROUPS, InitMainCommand);
			this.addCommand(RecordEvent.GET_LAYOUTS, InitMainCommand);
			this.addCommand(SidEvent.TEST_SID, SidCommand);

			// dashboard module
			this.addCommand(DashboardEvent.GET_ACTIVE_USERS, DashboardCommand);
			this.addCommand(DashboardEvent.GET_LATEST_PLEDGES, DashboardCommand);
			this.addCommand(DashboardEvent.SEARCH_EVENTS, DashboardCommand);
			this.addCommand(DashboardEvent.GET_EVENT_STATS, DashboardCommand);
			this.addCommand(DashboardEvent.GET_EVENT, DashboardCommand);

			// users modules
			this.addCommand(UsersEvent.USERS_DELETE, UsersCommand);
			this.addCommand(UsersEvent.GET_GROUPS, UsersCommand);
			this.addCommand(UsersEvent.ADD_GROUPS, UsersCommand);
			this.addCommand(UsersEvent.DEL_GROUPS, UsersCommand);
			this.addCommand(UsersEvent.GET_ACL, UsersCommand);
			this.addCommand(UsersEvent.SET_ACL, UsersCommand);
			this.addCommand(UsersEvent.INVITATION_SEND, UsersCommand);
			this.addCommand(UsersEvent.USERS_EXPORT, UsersCommand);
			this.addCommand(UsersEvent.USERS_ENABLE, UsersCommand);
			this.addCommand(UsersEvent.USERS_DISABLE, UsersCommand);
			this.addCommand(UsersEvent.INVITATION_GET_TEMPLATE, UsersCommand);
			this.addCommand(UsersEvent.GET_PLEDGES, UsersCommand);
			this.addCommand(UsersEvent.RESET_PASSWORD, UsersCommand);
			this.addCommand(UsersEvent.ADD_POWER_USER, UsersCommand);
			this.addCommand(UsersEvent.ADD_SUPER_USER, UsersCommand);
			this.addCommand(UsersEvent.DEL_POWER_USER, UsersCommand);
			this.addCommand(UsersEvent.DEL_SUPER_USER, UsersCommand);
			this.addCommand(UsersEvent.GET_USER_EMAIL, UsersCommand);
			this.addCommand(UsersEvent.GET_USER_CONTACT, UsersCommand);
			this.addCommand(UsersEvent.USERS_UPSERT_CONTACT, UsersCommand);
			this.addCommand(UsersEvent.ADMIN_CHANGE_EMAIL, UsersCommand);
			this.addCommand(UsersEvent.CREATE_USER, UsersCommand);

			// news modules
			this.addCommand(NewsEvent.NEWS_LAYOUT, NewsCommand);
			this.addCommand(NewsEvent.NEWS_RECORD, NewsCommand);
			this.addCommand(NewsEvent.NEWS_RECORDS, NewsCommand);
			this.addCommand(NewsEvent.NEWS_SEARCH, NewsCommand);
			this.addCommand(NewsEvent.NEWS_UPSERT, NewsCommand);
			this.addCommand(NewsEvent.NEWS_DELETE, NewsCommand);
			this.addCommand(NewsEvent.NEWS_ACTIVITY, NewsCommand);
			this.addCommand(NewsEvent.NEWS_EXPORT, NewsCommand);

			// resources modules
			this.addCommand(ResourcesEvent.RESOURCES_LAYOUT, ResourcesCommand);
			this.addCommand(ResourcesEvent.RESOURCES_RECORD, ResourcesCommand);
			this.addCommand(ResourcesEvent.RESOURCES_RECORDS, ResourcesCommand);
			this.addCommand(ResourcesEvent.RESOURCES_SEARCH, ResourcesCommand);
			this.addCommand(ResourcesEvent.RESOURCES_UPSERT, ResourcesCommand);
			this.addCommand(ResourcesEvent.RESOURCES_DELETE, ResourcesCommand);
			this.addCommand(ResourcesEvent.RESOURCES_ACTIVITY, ResourcesCommand);
			this.addCommand(ResourcesEvent.RESOURCES_EXPORT, ResourcesCommand);

			// reporting modules
			this.addCommand(ReportingEvent.REPORTING_RECORD, ReportingCommand);
			this.addCommand(ReportingEvent.REPORTING_RECORDS, ReportingCommand);
			this.addCommand(ReportingEvent.REPORTING_SEARCH, ReportingCommand);
			this.addCommand(ReportingEvent.SHOW_RECORD, ReportingCommand);
			this.addCommand(ReportingEvent.RECORDS_LOADED, ReportingCommand);

			// e-mail log module
			this.addCommand(EmailEvent.EMAIL_LOG_LAYOUT, EmailLogCommand);
			this.addCommand(EmailEvent.EMAIL_LOG_RECORDS, EmailLogCommand);
			this.addCommand(EmailEvent.EMAIL_LOG_SEARCH, EmailLogCommand);

			// e-mail system module
			this.addCommand(EmailEvent.EMAIL_SYSTEM_LAYOUT, EmailSystemCommand);
			this.addCommand(EmailEvent.EMAIL_SYSTEM_RECORD, EmailSystemCommand);
			this.addCommand(EmailEvent.EMAIL_SYSTEM_RECORDS, EmailSystemCommand);
			this.addCommand(EmailEvent.EMAIL_SYSTEM_SEARCH, EmailSystemCommand);
			this.addCommand(EmailEvent.EMAIL_SYSTEM_UPSERT, EmailSystemCommand);
			this.addCommand(EmailEvent.EMAIL_SYSTEM_ACTIVITY, EmailSystemCommand);
			this.addCommand(EmailEvent.EMAIL_SYSTEM_TEST, EmailSystemCommand);
			this.addCommand(EmailEvent.EMAIL_SYSTEM_GET_ATTACHMENTS, EmailSystemCommand);

			// e-mail user module
			this.addCommand(EmailEvent.EMAIL_USER_LAYOUT, EmailUserCommand);
			this.addCommand(EmailEvent.EMAIL_USER_RECORD, EmailUserCommand);
			this.addCommand(EmailEvent.EMAIL_USER_RECORDS, EmailUserCommand);
			this.addCommand(EmailEvent.EMAIL_USER_SEARCH, EmailUserCommand);
			this.addCommand(EmailEvent.EMAIL_USER_UPSERT, EmailUserCommand);
			this.addCommand(EmailEvent.EMAIL_USER_ACTIVITY, EmailUserCommand);
			this.addCommand(EmailEvent.EMAIL_USER_SEND, EmailUserCommand);
			this.addCommand(EmailEvent.EMAIL_USER_DELETE, EmailUserCommand);

			// e-mail attachments module
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS_UPSERT, EmailAttachmentsCommand);
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS_DELETE, EmailAttachmentsCommand);
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS_RECORDS, EmailAttachmentsCommand);
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS_RECORD, EmailAttachmentsCommand);
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS_ACTIVITY, EmailAttachmentsCommand);
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS_SEARCH, EmailAttachmentsCommand);
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS_EXPORT, EmailAttachmentsCommand);

			// transactions module
			this.addCommand(TransactionsEvent.TRANSACTIONS_RECORDS, TransactionsCommand);
			this.addCommand(TransactionsEvent.TRANSACTIONS_SEARCH, TransactionsCommand);
			this.addCommand(TransactionsEvent.TRANSACTIONS_FAILED_RECORDS, TransactionsCommand);
			this.addCommand(TransactionsEvent.TRANSACTIONS_FAILED_SEARCH, TransactionsCommand);

			this.addCommand(PaypalTransactionsEvent.PAYPAL_RECORDS, PaypalTransactionsCommand);
			this.addCommand(PaypalTransactionsEvent.PAYPAL_SEARCH, PaypalTransactionsCommand);

			// checks module
			this.addCommand(ChecksEvent.LAYOUT, ChecksCommand);
			this.addCommand(ChecksEvent.RECORD, ChecksCommand);
			this.addCommand(ChecksEvent.RECORDS, ChecksCommand);
			this.addCommand(ChecksEvent.SEARCH, ChecksCommand);
			this.addCommand(ChecksEvent.UPSERT, ChecksCommand);
			this.addCommand(ChecksEvent.UPSERT_MULTIPLE, ChecksCommand);
			this.addCommand(ChecksEvent.DELETE, ChecksCommand);
			this.addCommand(ChecksEvent.VALIDATE, ChecksCommand);

			// events module
			this.addCommand(EventsEvent.DELETE, EventsCommand);
			this.addCommand(EventsEvent.EXPORT, EventsCommand);
			this.addCommand(EventsEvent.GET_HOSTS, EventsCommand);
			this.addCommand(EventsEvent.GET_PLEDGES, EventsCommand);
			this.addCommand(EventsEvent.LOOKUP_SEARCH, EventsCommand);
			this.addCommand(EventsEvent.UPSERT_HOST_RECORD, EventsCommand);
			this.addCommand(EventsEvent.DELETE_HOST_RECORD, EventsCommand);

			// popups
			this.addCommand(DownlineEvent.GET_DOWNLINE, DownlineCommand);

			// search
			this.addCommand(SearchEvent.SEARCH, SearchCommand);
			
			// browse module
			this.addCommand(BrowseEvent.RECORDS, BrowseCommand);
			this.addCommand(BrowseEvent.SEARCH, BrowseCommand);
			this.addCommand(BrowseEvent.EXPORT, BrowseCommand);

			// record module
			this.addCommand(RecordEvent.GET_AUDIT_TRAIL, RecordCommand);
			this.addCommand(RecordEvent.GET_DELETED_RECORD, RecordCommand);
			this.addCommand(RecordEvent.GET_FULL_RECORD, RecordCommand);
			this.addCommand(RecordEvent.RESTORE, RecordCommand);
			this.addCommand(RecordEvent.UPSERT, RecordCommand);

			// record module
			this.addCommand(RecordModuleEvent.GET_FULL_RECORD, RecordModuleCommand);
			this.addCommand(RecordModuleEvent.GET_AUDIT_TRAIL, RecordModuleCommand);
			this.addCommand(RecordModuleEvent.GET_RECORDS, RecordModuleCommand);
			this.addCommand(RecordModuleEvent.SEARCH_RECORDS, RecordModuleCommand);
			this.addCommand(RecordModuleEvent.GET_DELETED_RECORD, RecordModuleCommand);
			this.addCommand(RecordModuleEvent.RESTORE, RecordModuleCommand);
			this.addCommand(RecordModuleEvent.UPSERT, RecordModuleCommand);
			this.addCommand(RecordModuleEvent.DELETE, RecordModuleCommand);

			// pledges module
			this.addCommand(PledgeEvent.GET_CONTRIBUTIONS, PledgesCommand);
			this.addCommand(PledgeEvent.LOOKUPINPUT_SEARCH, PledgesCommand);
			this.addCommand(PledgeEvent.GET_LABEL, PledgesCommand);
			this.addCommand(PledgeEvent.UPSERT_CHECKREFUND, PledgesCommand);
			this.addCommand(PledgeEvent.DELETE_CHECKREFUND, PledgesCommand);
			this.addCommand(PledgeEvent.GET_SHARED_CREDIT_FUNDRAISERS, PledgesCommand);
			this.addCommand(PledgeEvent.UPSERT_SHARED_CREDIT, PledgesCommand);
			this.addCommand(PledgeEvent.DELETE_SHARED_CREDIT, PledgesCommand);

			// contacts module
			this.addCommand(ContactsEvent.UPSERT_CONTACT, ContactsCommand);
			this.addCommand(ContactsEvent.GET_SHARED_USERS, ContactsCommand);
			this.addCommand(ContactsEvent.GET_PLEDGES, ContactsCommand);
			this.addCommand(ContactsEvent.GET_MATCHES, ContactsCommand);
			this.addCommand(ContactsEvent.GET_MAXOUT, ContactsCommand);

			// batches module
			this.addCommand(BatchEvent.GET_CHECK_LIST, BatchCommand);
			this.addCommand(BatchEvent.GET_BATCH_LIST, BatchCommand);
			this.addCommand(BatchEvent.GET_PLEDGE_LIST, BatchCommand);
			this.addCommand(BatchEvent.SAVE_BATCH, BatchCommand);
			this.addCommand(BatchEvent.EXPORT_BATCH, BatchCommand);
			this.addCommand(BatchEvent.GET_CHECKS_FOR_BATCH, BatchCommand);
			this.addCommand(BatchListEvent.ADD_CHECKS_TO_NEW_BATCH, BatchListCommand );
			this.addCommand(BatchListEvent.REMOVE_CHECKS_FROM_NEW_BATCH, BatchListCommand );
			this.addCommand(BatchListEvent.MARK_CHECKS_IN_BATCH, BatchListCommand );
			
			// support
			this.addCommand(SupportEvent.EVENT_SEND_SUPPORT, SupportCommand );
			
			// site options
			this.addCommand(SiteOptionsEvent.GET_SITE_OPTIONS, SiteOptionsCommand );
			this.addCommand(SaveSiteOptionEvent.SAVE_SITE_OPTION, SiteOptionsCommand );
			this.addCommand(GetUsersEvent.GET_USERS, GetUsersCommand );

 			/**
 			 * Pledge Workspace events
 			 */
			this.addCommand(PWEvent.GET_PLEDGE, PWCommand);
			this.addCommand(PWEvent.GET_CONTACT, PWCommand);
			this.addCommand(PWEvent.LOOKUP_INPUT_SEARCH, PWCommand);
			this.addCommand(PWEvent.GET_LABEL, PWCommand);	
			this.addCommand(PWEvent.SAVE, PWCommand);
			this.addCommand(PWEvent.DUP_SEARCH, PWCommand);	
			this.addCommand(PWEvent.DO_TRANSACTION, PWCommand);
			this.addCommand(PWEvent.SEND_EMAIL, PWCommand);
			this.addCommand(PWEvent.DELETE_SAVED_PLEDGE, PWCommand);
			// Start Pledge workspace command
			this.addCommand(SPWEvent.ADD_NEW, SPWCommand);
		}
	}
}