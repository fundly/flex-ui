package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class PaypalTransactionsEvent extends CairngormEvent
	{
		static public var PAYPAL_RECORDS:String = 'paypalTransactionsRecords';
		static public var PAYPAL_SEARCH:String = 'paypalTransactionsSearch';

		public var e:String;
		public var params:Object

		public function PaypalTransactionsEvent(e:String, params:Object=null)
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
			return new PaypalTransactionsEvent(e, params);
		}
	}
}