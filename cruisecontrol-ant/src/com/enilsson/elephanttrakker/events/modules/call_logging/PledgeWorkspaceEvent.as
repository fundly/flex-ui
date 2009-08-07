package com.enilsson.elephanttrakker.events.modules.call_logging
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class PledgeWorkspaceEvent extends CairngormEvent
	{
		static public const GET_CONTACT:String = 'get_contact_data';
		static public const GET_PLEDGE:String = 'get_pledge_data';
		static public const SAVE:String = 'save';
		static public const LOOKUP_INPUT_SEARCH:String = 'lookup_input_search';
		static public const GET_LABEL:String = 'get_label';
		static public const DO_TRANSACTION:String = 'do_transaction';
		static public const SEND_EMAIL:String = 'send_email';
		static public const DUP_SEARCH:String = 'dup_search';
		static public const DELETE_SAVED_PLEDGE:String = 'pw_del_saved_pledge';
		
		public var e:String;
		public var params:Object;
		
		public function PledgeWorkspaceEvent( e:String, params:Object = null )
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
			return new PledgeWorkspaceEvent( e, params );
		}
	}
}