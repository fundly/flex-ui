package com.enilsson.elephantadmin.views.modules.app_options.model
{
	import com.enilsson.utils.EDateUtil;
	
	import flash.net.registerClassAlias;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;

	[Bindable]
	public class SiteOption
	{
		public static const WORKSPACE_AGREEMENT : String = "workspace_agreement";
		
		public var id				: Number;
		
		public var title			: String;
		public var name				: String;
		public var value 			: String;
		public var description		: String;
		
		// a comma-separated string of vairables, each variable is encoded as followed: {VARIBALE_NAME}
		public var variables		: ArrayCollection = new ArrayCollection();
		
		public var type				: String;
		public var optional			: Boolean;
		public var display			: Boolean;
		
		public var createdOn		: Date;
		public var createdBy		: String;
		public var createdById		: int;
		
		public var modifiedOn		: Date;
		public var modifiedById		: int;
		public var modifiedBy		: String;
		
		public var groupId			: int;
		
		public var eRead  			: Boolean;
		public var eWrite 			: Boolean;
		public var oRead 			: Boolean;
		public var oWrite 			: Boolean;
		public var gRead 			: Boolean;
		public var gWrite 			: Boolean;
		
		[Transient]
		public function set data( value : Object ) : void
		{
			if(value)
			{
				id 				= value.id;
				title 			= value.option_title;
				name			= value.option_name;
				this.value		= value.option_value;
				description		= value.option_description;
				
				var varstr : String = StringUtil.trimArrayElements(value.option_variables,",");
				if(varstr.length > 0) 
					variables = new ArrayCollection( varstr.split(",") );
				
				type 			= value.option_type;
				optional 		= value.option_optional;
				display			= value.option_display != 0;
				createdOn		= EDateUtil.timeFromTimestamp( value.created_on );
				createdById		= value.created_by_id;
				createdBy		= value.created_by;
				modifiedOn		= EDateUtil.timeFromTimestamp(value.modified_on);
				modifiedById	= value.modified_by_id;
				modifiedBy		= value.modified_by;				
				eRead			= value.mod_e_read;
				oRead			= value.mod_o_read;
				gRead			= value.mod_g_read;				
				eWrite			= value.mod_e_write;
				oWrite			= value.mod_o_write;
				gWrite			= value.mod_g_write;			
				groupId			= value.mod_group_id; 
			}
		}		
		public function get data() : Object
		{
			return {
				id: 				this.id,
				option_title: 		title,
				option_name: 		name,
				option_value: 		value,
				option_description:	description,
				
				option_variables:	variables ? (variables.toArray().toString()) : null,
					
				option_type:		type,
				option_optional:	optional,
				option_display:		display,
				created_on:			EDateUtil.dateToTimestamp(createdOn),
				created_by_id:		createdById,
				created_by:			createdBy,
				modified_on:		EDateUtil.dateToTimestamp(modifiedOn),
				modified_by_id:		modifiedById,
				modified_by:		modifiedBy,
				mod_e_read:			eRead,
				mod_o_read:			oRead,
				mod_g_read:			gRead,
				mod_e_write:		eWrite,
				mod_o_write:		oWrite,
				mod_g_write:		gWrite,
				mod_group_id:		groupId
			};
		}
		
		
		{
			registerClassAlias("com.enilsson.elephantadmin.views.modules.app_options.model.SiteOption", SiteOption);
		}
	}
}