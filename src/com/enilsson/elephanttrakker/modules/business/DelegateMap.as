package com.enilsson.elephanttrakker.modules.business
{
	public dynamic class DelegateMap extends Array
	{
		public static const PROGRESS_REPORT			: int = 0;
		public static const DOWNLINE				: int = 1;
		public static const DOWNLINE_HTTP			: int = 2;
		
		public function DelegateMap()
		{
			super();
			
			this[PROGRESS_REPORT] 		= ProgressReportsDelegate;
			this[DOWNLINE]				= DownlineDelegate;
			this[DOWNLINE_HTTP]			= DownlineHttpDelegate;
		}

	}
}