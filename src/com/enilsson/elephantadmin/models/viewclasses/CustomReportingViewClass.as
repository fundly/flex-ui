package com.enilsson.elephantadmin.models.viewclasses
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class CustomReportingViewClass
	{
		// List of previous batches
		public var reportList:ArrayCollection = new ArrayCollection();
		public var reportListTotal:int;
		public var reportListFrom:int;
		public var reportListLoading:Boolean;
		public var reportListOrderField : String;
		public var reportListOrder : String;
		
		public var relationships:Object;
		public var layout:Object;
		public var layout_tables:Object;
		public var layout_structure:Object;
		
		public var fieldsObj:Array;

		// loaded report data
		public var reportData:Object = {};
		// temporary report data for parsing loaded report
		public var loadedData:Object = {};

		public var formValidate:Array = [];

		// fields tab
		public var tableBoxHts:Object;
		
		public var dataType:String;

		// maths fields tab
		public var mathFieldsDataProvider:ArrayCollection;
		public var dataTypeDataProvider:ArrayCollection;
		
	}
}