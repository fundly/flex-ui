package com.enilsson.elephanttrakker.controllers
{
	import com.adobe.cairngorm.control.FrontController;
	import com.enilsson.elephanttrakker.commands.*;
	import com.enilsson.elephanttrakker.commands.modules.*;
	import com.enilsson.elephanttrakker.events.*;
	import com.enilsson.elephanttrakker.events.login.*;
	import com.enilsson.elephanttrakker.events.main.*;
	import com.enilsson.elephanttrakker.events.modules.call_logging.*;
	import com.enilsson.elephanttrakker.events.modules.calls_reminders.*;
	import com.enilsson.elephanttrakker.events.modules.email.*;
	import com.enilsson.elephanttrakker.events.modules.events.*;
	import com.enilsson.elephanttrakker.events.modules.first_login.FirstLoginEvent;
	import com.enilsson.elephanttrakker.events.modules.invitation.InvitationEvent;
	import com.enilsson.elephanttrakker.events.modules.message_center.*;
	import com.enilsson.elephanttrakker.events.modules.my_contacts.*;
	import com.enilsson.elephanttrakker.events.modules.my_details.*;
	import com.enilsson.elephanttrakker.events.modules.my_downline.*;
	import com.enilsson.elephanttrakker.events.modules.my_history.*;
	import com.enilsson.elephanttrakker.events.modules.overview.*;
	import com.enilsson.elephanttrakker.events.modules.resources.*;
	import com.enilsson.elephanttrakker.events.session.*;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.commands.*;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.events.*;	

	public class ETcontroller extends FrontController
	{
		public function ETcontroller()
		{
			super();
			
			registerCommands();
		}
		
		private function registerCommands():void
		{			
			/**
			 * Initialisation of app
			 */
			this.addCommand(InitAppEvent.EVENT_INIT_APP, InitAppCommand);
			this.addCommand(GetVersionEvent.GET_VERSION, GetVersionCommand);
			this.addCommand(AppEvent.EVENT_APP, AppCommand);
			this.addCommand(URLChangeEvent.EVENT_URL_CHANGE, URLChangeCommand);
			
			/**
			 * Login events
			 */
			this.addCommand(LoginEvent.EVENT_LOGIN, LoginCommand);
			this.addCommand(LoginEvent.EVENT_LOGIN_FORGOT, LoginCommand);
			this.addCommand(RegisterGatewayEvent.EVENT_REGISTER_GATEWAY, RegisterGatewayCommand);

			/**
			 * Session events
			 */
			this.addCommand(PingEvent.EVENT_PING, SessionCommand);
			this.addCommand(EndSessionEvent.EVENT_END_SESSION, SessionCommand);
			this.addCommand(EndSessionEvent.EVENT_END_PROXYSESSION, SessionCommand);
			this.addCommand(UpdateSessionEvent.EVENT_UPDATE_SESSION, SessionCommand);
			this.addCommand(SessionEvent.GET_SESSION_INFO, SessionCommand);
			this.addCommand(SessionFailEvent.EVENT_SESSION_FAIL, SessionCommand);

			/**
			 * Initialisation of main app view
			 */
			this.addCommand(SessionCheckEvent.EVENT_SESSION_CHECK, InitMainCommand);			
			this.addCommand(InitMainEvent.EVENT_MAIN_APP, InitMainCommand);
			this.addCommand(ViewStateEvent.EVENT_VIEW_STATE, ViewStateCommand);
			this.addCommand(GetSiteLayoutEvent.EVENT_GET_LAYOUT, InitMainCommand);
			this.addCommand(GetRSSEvent.EVENT_GET_RSS, InitMainCommand);
			this.addCommand(GetStruktorLayoutEvent.GET_STRUKTOR_LAYOUT, InitMainCommand);
			this.addCommand(GetSiteOptionsEvent.EVENT_GET_OPTIONS, InitMainCommand);
			
			/**
			 * Main application events
			 */
			this.addCommand(SupportEvent.EVENT_SEND_SUPPORT, MainCommand);
			this.addCommand(SupportEvent.MESSAGE_SENT, MainCommand);
			this.addCommand(GetRSSEvent.EVENT_SEND_EMAIL, MainCommand);
			
			/**
			 * Overview
			 */
			this.addCommand(AnnouncementsEvent.EVENT_ANNOUNCEMENTS, OverviewCommand);
			this.addCommand(MyFundraisingEvent.EVENT_MY_FUNDRAISING, OverviewCommand);
			this.addCommand(UpdateGoalLineEvent.EVENT_UPDATE_GOALLINE, OverviewCommand);
			
			// call_logging
			this.addCommand(PledgeWorkspaceEvent.GET_CONTACT, CallLoggingCommand);
			this.addCommand(PledgeWorkspaceEvent.GET_PLEDGE, CallLoggingCommand);
			this.addCommand(PledgeWorkspaceEvent.LOOKUP_INPUT_SEARCH, CallLoggingCommand);			
			this.addCommand(PledgeWorkspaceEvent.GET_LABEL, CallLoggingCommand);	
			this.addCommand(PledgeWorkspaceEvent.SAVE, CallLoggingCommand);
			this.addCommand(PledgeWorkspaceEvent.DUP_SEARCH, CallLoggingCommand);	
			this.addCommand(PledgeWorkspaceEvent.DO_TRANSACTION, CallLoggingCommand);
			this.addCommand(PledgeWorkspaceEvent.SEND_EMAIL, CallLoggingCommand);
			this.addCommand(PledgeWorkspaceEvent.DELETE_SAVED_PLEDGE, CallLoggingCommand);		

			/**
			 * Start Pledge Workspace events
			 */
			this.addCommand(SPWEvent.ADD_NEW, SPWCommand);
			this.addCommand(SPWEvent.ADD_EXISTING, SPWCommand);
			this.addCommand(SPWEvent.ADD_SHARED, SPWCommand);
			this.addCommand(SPWEvent.EDIT, SPWCommand);
			this.addCommand(SPWEvent.RESTORE_SAVED, SPWCommand);

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
			
			/**
			 * Email events
			 */
			this.addCommand(EmailEvent.EMAIL_CONTACTS, EmailCommand);
			this.addCommand(EmailEvent.EMAIL_ATTACHMENTS, EmailCommand);
			this.addCommand(EmailEvent.EMAIL_TEMPLATES, EmailCommand);
			this.addCommand(EmailEvent.EMAIL_SEND_EMAILS, EmailCommand);
			this.addCommand(EmailEvent.EMAIL_SENT, EmailCommand);

			/**
			 * Recruit fundraiser events
			 */
			this.addCommand(InvitationEvent.INVITATION_SEND, InvitationCommand);
			this.addCommand(InvitationEvent.INVITATION_SENT, InvitationCommand);
			this.addCommand(InvitationEvent.INVITATION_GET_LOG, InvitationCommand);
						
			/**
			 * My Contacts events
			 */
			this.addCommand(GetContactEvent.EVENT_GET_CONTACT, MyContactsCommand);
			this.addCommand(GetContactEvent.EVENT_GET_CONTACT_INFO, MyContactsCommand);
			this.addCommand(GetMyContactsEvent.EVENT_GET_MYCONTACTS, MyContactsCommand);
			this.addCommand(GetMyContactsEvent.CONTACTS_FETCHED, MyContactsCommand);
			this.addCommand(SearchMyContactsEvent.EVENT_SEARCH_MYCONTACTS, MyContactsCommand);
			this.addCommand(UpsertContactEvent.EVENT_UPSERT_CONTACT, MyContactsCommand);
			this.addCommand(GetContactHistoryEvent.EVENT_GET_CONTACT_HISTORY, MyContactsCommand);
			this.addCommand(ImportContactEvent.FETCH_CONTACTS, MyContactsCommand);
			this.addCommand(ImportContactEvent.DELETE_IMPORTED, MyContactsCommand);
			this.addCommand(ImportContactEvent.IMPORT_CONTACTS, MyContactsCommand);
			this.addCommand(ExportContactEvent.EXPORT_CONTACTS, MyContactsCommand);
			this.addCommand(DeleteContactEvent.EVENT_DELETE_CONTACT, MyContactsCommand);

			/**
			 * Resources events
			 */
			this.addCommand(ResourcesEvent.EVENT_RESOURCES, ResourcesCommand);
			
			/**
			 * Event listings
			 */
			this.addCommand(EventsEvent.EVENT_GET_EVENTS, EventsCommand);
			this.addCommand(EventsEvent.EVENT_SEARCH_EVENTS, EventsCommand);
			this.addCommand(EventsEvent.EVENT_SEARCH_CONTACTS, EventsCommand);
			this.addCommand(EventsEvent.EVENT_ATTEND_EVENT, EventsCommand);
			this.addCommand(EventsEvent.EVENT_SEARCH, EventsCommand);
			
			/**
			 * My History events
			 */
			this.addCommand(MyHistoryGetPledgesEvent.EVENT_MYHISTORY_GET_PLEDGES, MyHistoryCommand);
			this.addCommand(MyHistoryGetContribsEvent.EVENT_MYHISTORY_GET_CONTRIBS, MyHistoryCommand);			
			this.addCommand(MyHistoryGetContribsEvent.EVENT_MYHISTORY_GET_CHECK_CONTRIBS, MyHistoryCommand);			
			this.addCommand(MyHistorySearchEvent.EVENT_SEARCH_MYHISTORY, MyHistoryCommand);
			this.addCommand(MyHistoryEvent.EVENT_STATS, MyHistoryCommand);
			this.addCommand(MyHistoryEvent.EVENT_DOWNLINE, MyHistoryCommand);
			this.addCommand(MyHistoryEvent.EVENT_CHART, MyHistoryCommand);
			this.addCommand(MyHistoryEvent.EVENT_EXPORT, MyHistoryCommand);
			this.addCommand(MyHistoryEvent.GET_TOPDONORS, MyHistoryCommand);
			this.addCommand(MyHistoryEvent.DELETE_PLEDGE, MyHistoryCommand);
			this.addCommand(MyHistoryEvent.DELETE_SAVED_PLEDGE, MyHistoryCommand);
			this.addCommand(MyHistoryGetSavedCallsEvent.EVENT_MYHISTORY_GET_SAVEDCALLS, MyHistoryCommand);
			
			/**
			 * My Downline events
			 */
			this.addCommand(GetDownlineEvent.EVENT_GET_DOWNLINE, MyDownlineCommand);
			this.addCommand(GetDownlineEvent.EVENT_GET_PARENTS, MyDownlineCommand);
			
/* 			
			// calls_reminders
			this.addCommand(CallsReminders_Event.EVENT_CR_CALLS_LAYOUT, CallsRemindersCommand);
			this.addCommand(CallsReminders_Event.EVENT_CR_CALLS_LIST, CallsRemindersCommand);			
			this.addCommand(CallsReminders_Event.EVENT_CR_CALLS_SEARCHCONTACTS, CallsRemindersCommand);	
 */			
			
			/**
			 * My Details events
			 */
			this.addCommand(MyDetailsEvent.MYDETAILS_UPSERT, MyDetailsCommand);				
			this.addCommand(MyDetailsEvent.MYDETAILS_CHANGE_PWD, MyDetailsCommand);
			this.addCommand(MyDetailsEvent.MYDETAILS_CHANGE_EMAIL, MyDetailsCommand);				
			this.addCommand(MyDetailsEvent.MYDETAILS_PASSWORD_CHANGED, MyDetailsCommand);				
			this.addCommand(MyDetailsEvent.MYDETAILS_UPSERT_CONTACT, MyDetailsCommand);				

			/**
			 * Message Center events
			 */
			this.addCommand(MessageCenterEvent.MESSAGES_ACTION, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.MESSAGES_GET, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.MESSAGES_GET_SENT, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.MESSAGES_GET_UNREAD, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.MESSAGES_STATUS, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.SEARCH, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.MESSAGES_SEND, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.MESSAGES_GET_LABEL, MessageCenterCommand);
			this.addCommand(MessageCenterEvent.MESSAGES_SENT, MessageCenterCommand);

			/**
			 * First login events
			 */
			this.addCommand(FirstLoginEvent.FIRSTLOGIN_CHANGEPWD, FirstLoginCommand);
			this.addCommand(FirstLoginEvent.FIRSTLOGIN_PASSWORD_CHANGED, FirstLoginCommand);
			this.addCommand(FirstLoginEvent.FIRSTLOGIN_UPSERTCONTACT, FirstLoginCommand);
			this.addCommand(FirstLoginEvent.FIRSTLOGIN_UPSERTDETAILS, FirstLoginCommand);
			this.addCommand(FirstLoginEvent.FIRSTLOGIN_LOGGEDIN, FirstLoginCommand);			
		}
		
	}
}