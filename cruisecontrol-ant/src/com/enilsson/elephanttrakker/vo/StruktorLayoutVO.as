package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.StruktorLayoutVO")]
	public class StruktorLayoutVO implements IValueObject
	{
		public function StruktorLayoutVO( data:Object )
		{
			for ( var i:String in data )
				this[i] = data[i];
		}

		[Bindable] public var display_type:String;
		[Bindable] public var field_groups:Object;
		[Bindable] public var fields:Array;
		[Bindable] public var foreign_keys:Object;
		[Bindable] public var primary_key:String;
		[Bindable] public var table:String;
		[Bindable] public var title:String;
		
		public function get fieldNames():Array
		{
			var f:Array = new Array();
			for each ( var field:Object in fields )
				f.push( field.fieldname );
			
			return f;
		}
						
	}
}