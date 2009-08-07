package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.NewsEvent;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class NewsViewClass
	{
		public function NewsViewClass()
		{
		}
		
		// module list variables
		public var records:ArrayCollection;
		public var totalRecords:Number = 0;
		public var currPage:Number = 0;
		public var selectedIndex:Number = -1;

		// form layout
		public var layout:Object;
				
		// data provider for the form
		public var formRecord:Object;
		
		// data for the activity of a record
		public var recordActivity:ArrayCollection;
				
		// activity indicator for the form
		public var formProcessing:Boolean = false;
		public var optionsViewStack:uint = 0;

		public var lastQuery:NewsEvent;
		public var lastIndex:int = -1;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection(           
			[ {label:"EVERYTHING", data:0}, 
			  {label:"TITLE", data:"news.title"}, 
			  {label:"DESCRIPTION", data:"news.description"}]);
	}
}