package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.EventsEvent;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Login View screen
	 */
	[Bindable]
	public class EventsViewClass
	{
		public function EventsViewClass()
		{
		}
		
		public var records:ArrayCollection;
		public var totalRecords:Number = 0;
		public var currPage:Number = 0;
		public var selectedIndex:Number = 0;

		// form layout
		public var layout:Object;

		public var editingRecord:Boolean = false;
		public var addingRecord:Boolean = false;

		public var optionsViewStack:uint = 0;
		public var recordActivity:ArrayCollection;


		// data for the activity of a record
		public var recordQuery:RecordsVO;
				
		// activity indicator for the form
		public var formProcessing:Boolean = false;
		public var isSearching:Boolean = false;

		public var lastQuery:EventsEvent;

		public var onClose:Function;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection(           
			[ {label:"EVERYTHING", data:0}]);

	}
}