package com.enilsson.elephanttrakker.views.modules.pledge_workspace.model
{
	public class PledgeWorkspaceVO
	{
		public function PledgeWorkspaceVO()
		{
		}
		
		public var action:String = PledgeWorkspaceModel.ADD_NEW;

		public var pledgeID:int;
		public var contactID:int;
		public var savedID:int;
		public var eventID:int;
		public var fundraiserID:int;
		
		public var contactData:Object;
		public var pledgeData:Object;
		public var checkData:Object;
		public var billingData:Object;
	}
}