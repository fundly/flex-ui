package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephantadmin.vo.SearchVO")]
	public class SearchVO implements IValueObject
	{
		public var table:String;
		public var query:String;
		public var mode:String;
		public var iCount:Number;
		public var iFrom:Number;
		public var sort:String;
		public var priv:String;
		public var export:Boolean;
		
		public function SearchVO(table:String, query:String, mode:String=null, 
			iFrom:Number=0, iCount:Number=200, sort:String=null, priv:String=null, export:Boolean=false) 
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