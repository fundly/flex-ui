package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.RecordVO")]
	public class RecordVO implements IValueObject
	{
		public var table_name:String;
		public var params:Object;
		public var id:int;
		public var method:String;
		
		public function RecordVO(table_name:String, id:int, method:String = 'select', params:Object = null) 
		{
			this.table_name = table_name;
			this.id = id;
			this.method = method;
			this.params = params;
		}
	}
}