package com.enilsson.elephanttrakker.events.modules.message_center
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class MessageCenterEvent extends CairngormEvent
	{
		static public var MESSAGES_STATUS:String = 'message_center_status';
		static public var MESSAGES_ACTION:String = 'message_center_action';
		static public var MESSAGES_GET:String = 'message_center_get';
		static public var MESSAGES_GET_SENT:String = 'message_center_get_sent';
		static public var MESSAGES_GET_UNREAD:String = 'message_center_get_unread';
		static public var SEARCH:String = 'message_center_fundraisers_search';
		static public var MESSAGES_SEND:String = 'message_center_send';
		static public var MESSAGES_SENT:String = 'message_center_sent';
		static public var MESSAGES_GET_LABEL:String = 'message_get_label';
		
		private var e:String;
		public var obj:Object;
		
		public function MessageCenterEvent(e:String = 'message_center_get', obj:Object = null)
		{
			this.e = e;
			this.obj = obj;
			
			super( e, obj );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new MessageCenterEvent(e, obj);
		}
	}
}