package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.SearchVO")]
	public class SearchVO implements IValueObject
	{
		public var table:String;
		public var query:String;
		public var mode:String;
		public var iCount:Number;
		public var iFrom:Number;
		public var sort:String;
		public var priv:Boolean;
		public var export:String;
		
		public function SearchVO(table:String, query:String, mode:String=null, 
			iFrom:Number=0, iCount:Number=200, sort:String=null, priv:Boolean=false, export:String=null) 
		{
			this.table = table;
			this.query = query;
			this.mode = mode;
			this.iCount = iCount;
			this.iFrom = iFrom;
			this.sort = sort;
			this.priv = priv;
			this.export = export;
		}
	}
}