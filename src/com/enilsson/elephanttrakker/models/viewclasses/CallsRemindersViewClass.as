package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Calls & Reminders module
	 */
	[Bindable]	
	public class CallsRemindersViewClass
	{
		public function CallsRemindersViewClass()
		{
		}
		
		public var callsLayout:Object;
		
		public var callsContactsSearch:ArrayCollection;
		
		public var callsErrorVO:ErrorVO;

	}
}