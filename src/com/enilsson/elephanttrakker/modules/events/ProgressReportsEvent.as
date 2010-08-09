package com.enilsson.elephanttrakker.modules.events
{
	import com.enilsson.modules.events.UIDGenerator;
	
	public class ProgressReportsEvent
	{
		public static const GET_TOP_FUNDRAISERS						: String = UIDGenerator.createId( 'getTopFundraisers' );
		public static const GET_TOP_FUNDRAISERS_DOWNLINE_CONTRIBS	: String = UIDGenerator.createId( 'getTopFundraisersDownlineContribs' );
		public static const GET_TOP_FUNDRAISERS_DOWNLINE_USERS		: String = UIDGenerator.createId( 'getTopFundraisersDownlineUsers' );
		public static const GET_GROUP_STATS							: String = UIDGenerator.createId( 'getGroupStats' );
	}
}