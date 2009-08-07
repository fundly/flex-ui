package com.enilsson.elephanttrakker.views.modules.pledge_workspace.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.events.SPWEvent;
	import com.enilsson.elephanttrakker.views.modules.pledge_workspace.model.PledgeWorkspaceVO;
	
	import org.osflash.thunderbolt.Logger;
	
	public class SPWCommand implements ICommand
	{
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function SPWCommand() { }
		
		public function execute ( e:CairngormEvent ):void
		{
			Logger.info('SPWCommand', e.type);
			
			var event:SPWEvent = e as SPWEvent;
			
			// send the user to the pledge workspace if not there already
			_model.mainViewState = ETModelLocator.PLEDGE_WORKSPACE_VIEW;			

			// apply the event VO to the model
			_model.pledgeWorkspace = event.params as PledgeWorkspaceVO;
		}

	}
}