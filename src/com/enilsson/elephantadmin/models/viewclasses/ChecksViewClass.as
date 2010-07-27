package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.ChecksEvent;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Login View screen
	 */
	[Bindable]
	public class ChecksViewClass
	{
		public var records:ArrayCollection = new ArrayCollection();
		public var totalRecords:Number = 0;
		public var currPage:Number = 0;
		public var selectedIndex:Number = 0;

		// form layout
		public var layout:Object;

		// data provider for the form
		public var details:Object;
		
		public var sidRecord:Boolean = false;
		public var editingRecord:Boolean = false;

		// data for the activity of a record
		public var recordActivity:ArrayCollection;
		public var recordQuery:RecordsVO = new RecordsVO('checks');
				
		// activity indicator for the form
		public var formProcessing:Boolean = false;
		public var isSearching:Boolean = false;

		public var lastQuery:ChecksEvent;

		public var searchBoxCombo:ArrayCollection = new ArrayCollection([
				{label:"NAME ON ACCOUNT", data:'checks.full_name', type:"any"}
			,	{label:"AMOUNT", data:'checks.amount', type:"exact"}
			,	{label:"FIRST NAME", data:'checks__pledge_id.fname'}
			,	{label:"LAST NAME", data:'checks__pledge_id.lname'}
			]);

	}
}