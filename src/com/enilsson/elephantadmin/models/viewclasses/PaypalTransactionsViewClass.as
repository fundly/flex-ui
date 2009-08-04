package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.PaypalTransactionsEvent;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Transactions View screen
	 */
	[Bindable]
	public class PaypalTransactionsViewClass
	{
		public function PaypalTransactionsViewClass()
		{
		}
		
		public var records:ArrayCollection;
		public var totalRecords:Number = 0;
		public var currPage:Number = 0;
		public var selectedIndex:Number = -1;

		public var sidRecord:Boolean;

		// form layout
		public var layout:Object;

		// data provider for the form
		public var details:Object;
		
		// data for the activity of a record
		public var recordActivity:ArrayCollection;
				
		// activity indicator for the form
		public var formProcessing:Boolean = false;

		public var lastQuery:PaypalTransactionsEvent;
		public var lastIndex:int = -1;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection(
			[ {label:"TRANSACTION ID", data:"paypal_transactions.transactionid"},
			  {label:"AMOUNT", data:"paypal_transactions.amount"}]);
	}
}