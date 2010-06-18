package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[Bindable]
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.PledgeVO")]
	public class PledgeVO implements IValueObject
	{
		public var tr_users_id:Number;
		public var contact:Object = {};
		public var pledge:Object = {};
		public var contribution:Object = {};
		
		public var transaction:TransactionVO;
		public var transactionData:Object = {};
		public var check:Object;
		public var billing:Object = {};
		public var paymentType:String;		
	}
}