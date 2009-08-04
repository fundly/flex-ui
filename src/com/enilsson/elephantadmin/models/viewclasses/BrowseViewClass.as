package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.BrowseEvent;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Login View screen
	 */
	[Bindable]
	public class BrowseViewClass
	{
		public var records:ArrayCollection;
		public var totalRecords:Number = 0;
		
		public var currPage:Number = 0;
		public var selectedIndex:Number = 0;

		// data provider for the form
		public var columns:Array;

		public var isSearching:Boolean = false;
		
		public var usingSearch:Boolean = false;

		public var table:String;
		public var lastQuery:BrowseEvent;		
		public var lastExportableQuery : BrowseEvent;
	}
}