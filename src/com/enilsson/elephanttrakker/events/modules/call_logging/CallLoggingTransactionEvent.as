package com.enilsson.elephanttrakker.events.modules.call_logging
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.vo.TransactionVO;
	
	import flash.events.Event;

	public class CallLoggingTransactionEvent extends CairngormEvent
	{
		static public var EVENT_TRANSACTION:String = 'transaction';
		
		public var transaction:TransactionVO;
		
		public function CallLoggingTransactionEvent(transaction:TransactionVO)
		{
			super( EVENT_TRANSACTION );
			
			this.transaction = transaction;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new CallLoggingTransactionEvent(transaction);
		}
	}
}