package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class TransactionsEvent extends CairngormEvent
	{
		static public var TRANSACTIONS_RECORDS:String = 'transactionsRecords';
		static public var TRANSACTIONS_SEARCH:String = 'transactionsSearch';
		static public var TRANSACTIONS_FAILED_RECORDS:String = 'transactionsFailedRecords';
		static public var TRANSACTIONS_FAILED_SEARCH:String = 'transactionsFailedSearch';

		public var e:String;
		public var params:Object

		public function TransactionsEvent(e:String, params:Object=null)
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
			return new TransactionsEvent(e, params);
		}
				
	}
}