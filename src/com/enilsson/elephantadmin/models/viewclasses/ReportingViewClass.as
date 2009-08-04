package com.enilsson.elephantadmin.models.viewclasses
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	public class ReportingViewClass
	{
		[Bindable] public var reportModule:String;
		[Bindable] public var reportRecordID:int;
		
		// module list variables
		[Bindable] public var records:ArrayCollection = new ArrayCollection();
		[Bindable] public var records_chart:ArrayCollection = new ArrayCollection();
		[Bindable] public var totalRecords:Number = 0;
		[Bindable] public var currPage:Number = 0;
		[Bindable] public var selectedIndex:Number = -1;

		[Bindable] public var data_records:Object = new Object();
				
		
		// file reference object to upload files to S3
		[Bindable] public var fileRef:FileReference = new FileReference();
		[Bindable] public var optionsViewStack:uint = 0;
	}
}