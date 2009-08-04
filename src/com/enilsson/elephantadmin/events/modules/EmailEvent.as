package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class EmailEvent extends CairngormEvent
	{
		static public var EMAIL_LOG_LAYOUT:String = 'email_log_layout';
		static public var EMAIL_LOG_RECORDS:String = 'email_log_records';
		static public var EMAIL_LOG_SEARCH:String = 'email_log_search';

		static public var EMAIL_SYSTEM_LAYOUT:String = 'email_system_layout';
		static public var EMAIL_SYSTEM_RECORDS:String = 'email_system_records';
		static public var EMAIL_SYSTEM_RECORD:String = 'email_system_record';
		static public var EMAIL_SYSTEM_SEARCH:String = 'email_system_search';
		static public var EMAIL_SYSTEM_UPSERT:String = 'email_system_upsert';
		static public var EMAIL_SYSTEM_ACTIVITY:String = 'email_system_activity';
		static public var EMAIL_SYSTEM_TEST:String = 'email_system_test';
		static public var EMAIL_SYSTEM_GET_ATTACHMENTS:String = 'email_system_getAttachments';

		static public var EMAIL_USER_LAYOUT:String = 'email_user_layout';
		static public var EMAIL_USER_RECORDS:String = 'email_user_records';
		static public var EMAIL_USER_RECORD:String = 'email_user_record';
		static public var EMAIL_USER_SEARCH:String = 'email_user_search';
		static public var EMAIL_USER_UPSERT:String = 'email_user_upsert';
		static public var EMAIL_USER_DELETE:String = 'email_user_delete';
		static public var EMAIL_USER_ACTIVITY:String = 'email_user_activity';
		static public var EMAIL_USER_SEND:String = 'email_user_send';

		static public var EMAIL_ATTACHMENTS_LAYOUT:String = 'email_attachments_layout';
		static public var EMAIL_ATTACHMENTS_RECORDS:String = 'email_attachments_records';
		static public var EMAIL_ATTACHMENTS_RECORD:String = 'email_attachments_record';
		static public var EMAIL_ATTACHMENTS_SEARCH:String = 'email_attachments_search';
		static public var EMAIL_ATTACHMENTS_UPSERT:String = 'email_attachments_upsert';
		static public var EMAIL_ATTACHMENTS_DELETE:String = 'email_attachments_delete';
		static public var EMAIL_ATTACHMENTS_ACTIVITY:String = 'email_attachments_activity';
		static public var EMAIL_ATTACHMENTS_EXPORT:String = 'email_attachments_export';

		public var e:String;
		public var params:Object

		public function EmailEvent(e:String, params:Object=null)
		{
			super( e );
			this.e = e;
			this.params = params;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new EmailEvent(e, params);
		}
				
	}
}