package com.enilsson.elephantadmin.vo
{
	[Bindable]
	[RemoteClass(alias="admin.UIAccessVO")]
	public class UIAccessVO
	{
		public var dataExport		: Boolean = true;
		public var recordWrite		: Boolean = true;
		public var reportingAccess	: Boolean = true;
		public var reportingExport	: Boolean = true;
	}
}