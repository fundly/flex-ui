package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.TransactionsEvent;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Transactions View screen
	 */
	[Bindable]
	public class TransactionsViewClass
	{
		public function TransactionsViewClass()
		{
		}
		
		public var records:ArrayCollection;
		public var totalRecords:Number = 0;
		public var currPage:Number = 0;
		public var selectedIndex:Number = -1;

		// form layout
		public var layout:Object;

		// data provider for the form
		public var details:Object;
		
		public var sidRecord:Boolean = false;
		
		// data for the activity of a record
		public var recordActivity:ArrayCollection;
				
		// activity indicator for the form
		public var formProcessing:Boolean = false;

		public var lastQuery:TransactionsEvent;
		public var lastIndex:int = -1;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection(
			[ 
				{ label : "NAME ON CARD", data : "transactions.full_name" },
				{ label : "CARD TYPE", data : "transactions.card_type" },
				{ label : "ENGINE", data : "transactions.engine" }
			]
		);
	}
}