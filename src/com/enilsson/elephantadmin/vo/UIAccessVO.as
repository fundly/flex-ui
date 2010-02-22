package com.enilsson.elephantadmin.vo
{
	import mx.utils.ObjectUtil;
	
	[Bindable]
	[RemoteClass(alias="admin.UIAccessVO")]
	public class UIAccessVO
	{
		public var userId			: Number;
		public var dataExport		: Boolean;
		public var recordWrite		: Boolean;
		public var reportingAccess	: Boolean;
		public var reportingExport	: Boolean;
	}
}