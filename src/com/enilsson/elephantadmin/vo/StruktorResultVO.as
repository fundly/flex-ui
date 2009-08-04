package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="StruktorResultVO")]
	[Bindable]
	public class StruktorResultVO implements IValueObject
	{
		public var table_name:String;
		public var total_records:int;
		public var list:ArrayCollection;
	}
}