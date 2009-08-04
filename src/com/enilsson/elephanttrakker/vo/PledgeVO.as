package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.PledgeVO")]
	public class PledgeVO implements IValueObject
	{
		public function PledgeVO()
		{
			
		}

		[Bindable] public var tr_users_id:Number;
		[Bindable] public var contact:Object = {};
		[Bindable] public var pledge:Object = {};
		[Bindable] public var transaction:TransactionVO;
		[Bindable] public var transactionData:Object = {};
		[Bindable] public var check:Object = {};
		[Bindable] public var billing:Object = {};

	}
}