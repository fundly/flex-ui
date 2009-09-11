package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	public class CustomReportVO implements IValueObject
	{
		public var id:int;
		public var name:String;
		public var description:String;
		public var data:Object;
		
		public function CustomReportVO(id:int, name:String, description:String, data:Object)
		{
			this.id = id;
			this.name = name;
			this.description = description;
			this.data = data;
		}
	}
}