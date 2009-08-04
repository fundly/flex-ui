package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.EmailEvent;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Login View screen
	 */
	[Bindable]
	public class EmailLogViewClass
	{
		public function EmailLogViewClass()
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

		public var lastQuery:EmailEvent;
		public var lastIndex:int = -1;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection(
			[ {label:"TO EMAIL", data:"email_log.to"},
			  {label:"CC EMAIL", data:"email_log.cc"},
			  {label:"BCC EMAIL", data:"email_log.bcc"},
			  {label:"SENDER", data:"email_log.created_by"},
			  {label:"SUBJECT", data:"email_log.subject"},
			  {label:"CONTENT", data:"email_log.content"}]);
	}
}