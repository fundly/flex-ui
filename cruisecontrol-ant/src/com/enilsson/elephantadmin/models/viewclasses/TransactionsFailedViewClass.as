package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.TransactionsEvent;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Transactions View screen
	 */
	[Bindable]
	public class TransactionsFailedViewClass
	{
		public function TransactionsFailedViewClass()
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
		
		// data for the activity of a record
		public var recordActivity:ArrayCollection;
				
		// activity indicator for the form
		public var formProcessing:Boolean = false;
		public var optionsViewStack:uint = 0;

		public var lastQuery:TransactionsEvent;
		public var lastIndex:int = -1;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection(
			[ {label:"NAME", data:"transactions_failed.full_name"},
			  {label:"AMOUNT", data:"transactions_failed.amount"},
			  {label:"ZIP CODE", data:"transactions_failed.zip"}]);
	}
}