package com.enilsson.elephantadmin.views.common
{
	import mx.containers.Panel;
	import mx.core.ScrollPolicy;

	public class FluidPanel extends Panel
	{
		public function FluidPanel()
		{
			super();
		}
		
		override public function validateDisplayList():void
		{
			super.validateDisplayList();
			
			if(verticalScrollBar != null && verticalScrollBar.maxScrollPosition == 0
			&& verticalScrollPolicy != ScrollPolicy.AUTO)
			{
				verticalScrollPolicy = ScrollPolicy.AUTO;
			}
			else if(verticalScrollBar != null)
			{
				verticalScrollPolicy = ScrollPolicy.ON;
			}

			if(horizontalScrollBar != null && horizontalScrollBar.maxScrollPosition == 0
			&& horizontalScrollPolicy != ScrollPolicy.AUTO)
			{
				horizontalScrollPolicy = ScrollPolicy.AUTO;
			}
			else if(horizontalScrollBar != null)
			{
				horizontalScrollPolicy = ScrollPolicy.ON;
			}

		}
		
	}
}