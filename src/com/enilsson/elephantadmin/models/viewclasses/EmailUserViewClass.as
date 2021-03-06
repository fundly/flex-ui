package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.EmailEvent;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Login View screen
	 */
	[Bindable]
	public class EmailUserViewClass
	{
		public function EmailUserViewClass()
		{
		}
		
		public var records:ArrayCollection;
		public var totalRecords:Number = 0;
		public var currPage:Number = 0;
		public var selectedIndex:Number = -1;
		public var attachmentList:ArrayCollection;

		// form layout
		public var layout:Object;

		// data provider for the form
		public var formRecord:Object;
		
		// data for the activity of a record
		public var recordActivity:ArrayCollection;
				
		// activity indicator for the form
		public var formProcessing:Boolean = false;
		public var optionsViewStack:uint = 0;

		public var lastQuery:EmailEvent;
		public var lastIndex:int = -1;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection(           
			[ {label:"EVERYTHING", data:0}, 
			  {label:"TITLE", data:'email_user_templates.title'}, 
			  {label:"SUBJECT", data:'email_user_templates.subject'},
			  {label:"CONTENT", data:'email_user_templates.description'}]);
	}
}