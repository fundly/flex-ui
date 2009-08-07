package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	public class BatchRecordVO implements IValueObject
	{
		// Optional argument to set user id instead of session user id
		public var user_id:Number;
		// Array of RecordVOs to upsert
		public var list:Array = [];

		public function BatchRecordVO(list:Array) 
		{
			this.list = list;
		}
	}
}