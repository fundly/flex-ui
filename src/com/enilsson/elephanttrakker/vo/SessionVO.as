package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.SessionVO")]
	public class SessionVO implements IValueObject
	{
		public function SessionVO(data:Object)
		{
			this.data = data;
			this.fname = data.fname;
			this.lname = data.lname;
			this.fullname = data.fname + ' ' + data.lname;
			this.email = data.email;
			this.user_id = data.user_id;
			this.phone = data._phone;
			this.firstlogin = data._firstlogin;
			this.acl = data.acl;
			this.groups = data.groups;
			
			this.pledgeTotal = Number(data._pledge_total) + Number(data._shared_credit_pledge_total);
			this.numPledges = Number(data._p) + Number(data._shared_credit_p);
			this.contribTotal = Number(data._contrib_total) + Number(data._shared_credit_contrib_total);
			this.numContribs = Number(data._c) + Number(data._shared_credit_c);
			
			this.pledgeAverage = this.pledgeTotal / this.numPledges;
			 
		}
		
		[Bindable] public var data:Object;
		[Bindable] public var fname:String;
		[Bindable] public var lname:String;
		[Bindable] public var fullname:String;
		[Bindable] public var email:String;
		[Bindable] public var user_id:Number;
		[Bindable] public var phone:String;
		[Bindable] public var firstlogin:Number;
		[Bindable] public var acl:Object;
		[Bindable] public var groups:Object;
		
		[Transient] [Bindable] public var pledgeTotal : Number = 0;
		[Transient]	[Bindable] public var numPledges : Number = 0;
		[Transient]	[Bindable] public var pledgeAverage : Number = 0;
		[Transient]	[Bindable] public var contribTotal : Number = 0;
		[Transient]	[Bindable] public var numContribs : Number = 0;
	}
}