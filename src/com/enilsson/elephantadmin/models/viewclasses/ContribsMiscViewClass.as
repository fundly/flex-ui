package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.RecordsEvent;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ContribsMiscViewClass
	{
		public var records : ArrayCollection = new ArrayCollection();
		public var totalRecords:Number = 0;
		public var currPage:Number = 0;
		public var selectedIndex:Number = -1; 
		public var details:Object;
		
		public var sidRecord:Boolean = false;
		
		// data for the activity of a record
		public var recordActivity:ArrayCollection;

		public var lastQuery:RecordsEvent;
		public var lastIndex:int = -1;
		
		public var searchBoxCombo:ArrayCollection = new ArrayCollection(
			[ 
				{ label : "TYPE", data : "contributions_misc.type" }
			]
		);
	}
}