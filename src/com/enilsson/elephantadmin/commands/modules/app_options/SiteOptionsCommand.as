package com.enilsson.elephantadmin.commands.modules.app_options
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordDelegate;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.events.modules.app_options.SaveSiteOptionEvent;
	import com.enilsson.elephantadmin.events.modules.app_options.SiteOptionsEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.app_options.model.SiteOption;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class SiteOptionsCommand implements ICommand
	{
		private static const SITE_OPTIONS 	: String = "site_options";
		private static const ORDER 			: String = SITE_OPTIONS + ".option_title ASC";
		
		private var _model : EAModelLocator = EAModelLocator.getInstance();
		private var _event : Event;
		
		public function execute( event : CairngormEvent ) : void
		{
			_event = event;
			
			switch(event.type)
			{
				case SiteOptionsEvent.GET_SITE_OPTIONS:
					getSiteOptions();	
				break;
				case SaveSiteOptionEvent.SAVE_SITE_OPTION:
					saveSiteOption();
				break;
			}
		}
		
		/**
		 * Get the site options and apply them to the module
		 */
		private function getSiteOptions() : void
		{
			var responder	: Responder = new Responder(handleGetSiteOptionsResult, handleGetSiteOptionsFault);
			var delegate  	: RecordsDelegate = new RecordsDelegate(responder);
			
			var recordsVO 	: RecordsVO = new RecordsVO(SITE_OPTIONS, null, ORDER);
			
			delegate.getRecords(recordsVO);
			
			_model.dataLoading = true;
		}	
			
		private function handleGetSiteOptionsResult( event : ResultEvent ) : void
		{
			_model.dataLoading = false;
			
			var optionsObj 	: Object = event.result.site_options;			
			var siteOptions	: ArrayCollection = new ArrayCollection();
			
			for( var prop : String in optionsObj )
			{
				var option : SiteOption = new SiteOption();
				option.data = optionsObj[prop];
				
				siteOptions.addItem( option );
			}
			
			_model.appOptions.siteOptions = siteOptions;
		}
				
		private function handleGetSiteOptionsFault( event : FaultEvent ) : void
		{
			_model.dataLoading = false;
			if(_model.debug) Logger.warn( ObjectUtil.toString( event.fault ) );
		}
		
		
		/**
		 * Save the selected option
		 */
		private function saveSiteOption() : void
		{
			var e : SaveSiteOptionEvent = _event as SaveSiteOptionEvent;
			
			var responder 	: Responder = new Responder(handleSaveSiteOptionResult, handleSaveSiteOptionFault);
			var delegate	: RecordDelegate = new RecordDelegate( responder );
			var recordVO	: RecordVO = new RecordVO(SITE_OPTIONS, e.option.id, e.option.data);
			
			delegate.upsertRecord(recordVO);
			_model.dataLoading = true;
		}
		
		private function handleSaveSiteOptionResult( event : ResultEvent ) : void
		{
			var e : SaveSiteOptionEvent = _event as SaveSiteOptionEvent;
			
			if ( _model.debug ) Logger.info('Save SiteOption', ObjectUtil.toString( event.result ), ObjectUtil.toString( e.option ));
			
			var df:DateFormatter = new DateFormatter();
			df.formatString = 'MM/DD/YYYY';
			_model.dataLoading = false;
			
			var options : ArrayCollection = _model.appOptions.siteOptions;
			for(var i : int = 0; i < options.length; i++)
			{
				if( SiteOption(options[i]).id == e.option.id )
				{
					var opt:SiteOption = e.option;
					opt.modifiedBy = _model.session.fullname;
					opt.modifiedById = _model.session.user_id;
					opt.modifiedOn = df.format( new Date() );
					
					options.setItemAt( opt, i );
					break;
				}
			}
									
			if( e.callback != null )
				e.callback();
		}
		
		private function handleSaveSiteOptionFault( event : FaultEvent ) : void
		{
			_model.dataLoading = false;
			if(_model.debug) Logger.warn( 'SaveSiteOptionsFail', ObjectUtil.toString( event.fault ) );
		}
	}
}