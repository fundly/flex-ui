package com.enilsson.elephantadmin.views.modules.reporting.base
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="reporting.ReportResultVO")]
	[Bindable]
	public class ReportResultVO implements IValueObject
	{
		public var total_records:int;
		public var list:ArrayCollection;
		public var addData:Object;
	}
}