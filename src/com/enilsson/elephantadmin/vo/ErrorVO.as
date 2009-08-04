package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephantadmin.vo.ErrorVO")]
	public class ErrorVO implements IValueObject
	{
		[Bindable] public var message:String = '';
		[Bindable] public var style:String = '';
		[Bindable] public var visible:Boolean = false;
		
		public function ErrorVO(message:String, style:String, visible:Boolean)
		{
			this.message = message;
			this.style = style;
			this.visible = visible;
		}

	}
}