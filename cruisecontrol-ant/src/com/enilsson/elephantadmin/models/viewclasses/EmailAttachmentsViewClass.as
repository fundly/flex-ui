package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.events.modules.EmailEvent;
	
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class EmailAttachmentsViewClass
	{
		public function EmailAttachmentsViewClass()
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
		
		// activity indicator for the form
		public var formProcessing:Boolean = false;

		// addding
		public var addingRecord:Boolean = false;
		
		// data for the activity of a record
		public var recordActivity:ArrayCollection;

		// file reference object to upload files to S3
		public var fileRef:FileReference = new FileReference();
		public var fileChanged:Boolean = false;
		public var fileMaxSize:int = 2; // 2MB
		public var optionsViewStack:uint = 0;

		public var lastQuery:EmailEvent;
		public var lastIndex:int = -1;
		
		public var searchBoxCombo:ArrayCollection = new ArrayCollection(           
				[ {label:"EVERYTHING", data:0}, 
				  {label:"TITLE", data:"email_attachments.title"}, 
				  {label:"DESCRIPTION", data:"email_attachments.description"}]);

	}
}