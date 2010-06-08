package com.enilsson.elephantadmin.vo
{
	public class SharedCreditVO
	{
		public var pledgeID : int;
		public var userID : int;
			
		public function SharedCreditVO( pledgeID : int, userID : int )
		{
			this.pledgeID = pledgeID;
			this.userID = userID;
		}
	}
}