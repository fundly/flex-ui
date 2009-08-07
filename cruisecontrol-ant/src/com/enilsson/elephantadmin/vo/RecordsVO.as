package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephantadmin.vo.RecordsVO")]
	public class RecordsVO implements IValueObject
	{
		public var table:String;
		public var where:Object;
		public var sort:String;
		public var iFrom:Number;
		public var iCount:Number;
		public var options:String;
		
		public function RecordsVO(table:String, where:Object=null, sort:String=null, 
			iFrom:Number=0, iCount:Number=200, options:String=null) 
		{
			this.table = table;
			this.where = where;
			this.sort = sort;
			this.iFrom = iFrom;
			this.iCount = iCount;
			this.options = options;
		}
		
		public function clone():RecordsVO
		{
			return new RecordsVO(table, where, sort,iFrom, iCount, options);
		}
	}
}