package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.CountingVO")]
	public class CountingVO implements IValueObject
	{
		public var table_name:String;
		public var group_field:String;
		public var sum_fields:String;		
		
		public function CountingVO( table_name:String, group_field:String, sum_fields:String )
		{
			this.table_name = table_name;
			this.group_field = group_field;
			this.sum_fields = sum_fields;			
		}

	}
}