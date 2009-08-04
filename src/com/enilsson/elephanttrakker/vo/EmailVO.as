package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.EmailVO")]
	public class EmailVO implements IValueObject
	{
		[Bindable] public var fname:String = "";
		[Bindable] public var lname:String = "";
		[Bindable] public var addresses:String = "";
		[Bindable] public var cc:String = "";
		[Bindable] public var bcc:String = "";
		[Bindable] public var subject:String = "";
		[Bindable] public var content:String = "";
		[Bindable] public var attachmentList:String = "";
		[Bindable] public var templateID:int = undefined;
		[Bindable] public var templateVars:Array;
		[Bindable] public var logged:Boolean = true;
		[Bindable] public var date:Date;

		public function EmailVO(addresses:String, subject:String, content:String, attachmentList:String = "", templateID:int = undefined, templateVars:Array = null, logged:Boolean = true)
		{
			this.addresses = addresses;
			this.fname = fname;
			this.lname = lname;
			this.subject = subject;
			this.content = content;
			this.attachmentList = attachmentList;
			this.templateID = templateID;
			this.templateVars = templateVars;
			this.logged = logged;
		}
	}
}