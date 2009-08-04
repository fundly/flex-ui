package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.LayoutVO")]
	public class LayoutVO implements IValueObject
	{
		[Bindable] public var table_name:String;
		
		public function LayoutVO(table_name:String) 
		{
			this.table_name = table_name;
		}
	}
}