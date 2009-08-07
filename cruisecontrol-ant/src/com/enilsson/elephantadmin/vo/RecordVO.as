package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephantadmin.vo.RecordVO")]
	public class RecordVO implements IValueObject
	{
		public var table_name:String;
		public var params:Object;
		public var id:int;
		
		public function RecordVO(table_name:String, id:int, params:Object = null) 
		{
			this.table_name = table_name;
			this.id = id;
			this.params = params;
		}
	}
}