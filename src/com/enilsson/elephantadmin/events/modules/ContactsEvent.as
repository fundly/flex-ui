package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.vo.IValueObject;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	
	import flash.events.Event;

	public class ContactsEvent extends RecordModuleEvent
	{
		static public const UPSERT_CONTACT:String 		= 'contactsUpsertRecord';
		static public const GET_SHARED_USERS:String 	= 'contactsGetSharedUsers';
		static public const GET_PLEDGES:String 			= 'contactsGetPledges';
		static public const GET_MATCHES:String 			= 'contactsGetMatches';
		static public const GET_MAXOUT:String 			= 'contactsGetMaxOut';

		public function ContactsEvent( type:String, model:RecordModel, vo:Object = null )
		{
			super( type , model , vo);
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return ContactsEvent(super.clone());
		}
	}
}