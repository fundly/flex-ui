package com.enilsson.elephantadmin.vo
{
	import mx.utils.ObjectUtil;
	
	[Bindable]
	[RemoteClass(alias="admin.UIAccessVO")]
	public class UIAccessVO
	{
		public var userId			: Number;
		public var dataExport		: Boolean;
		
		public var recordCreate		: Boolean;
		public var recordUpdate		: Boolean;
		public var recordDelete		: Boolean;
		
		public var reportingAccess	: Boolean;
	}
}