package com.enilsson.elephantadmin.views.manage_record_base.model
{
	import com.adobe.cairngorm.model.ModelLocator;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	
	[Bindable] 
	public class RecordModuleConfiguration
	{
		public function RecordModuleConfiguration()
		{
		}

		public var table:String;
		public var eSQL:String;
		public var searchOptions:ArrayCollection;
		public var browseField:String;
		public var gridFields:Array;
		public var searchListItemRenderer:ClassFactory;
	}
}