package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.models.Icons;
	import com.enilsson.elephantadmin.views.modules.search.grids.*;
	
	import mx.collections.ArrayCollection;
	
	public class SearchViewClass
	{		
		public static const EVERYTHING 	: String = "EVERYTHING";
		public static const CONTACTS	: String = "CONTACTS";
		public static const PLEDGES		: String = "PLEDGES";
		public static const USERS		: String = "USERS";
		public static const EVENTS		: String = "EVENTS"; 
		public static const EMAILS		: String = "EMAILS";
		public static const NEWS		: String = "NEWS";
		public static const RESOURCES	: String = "RESOURCES";
		
		public static const ITEMS_PER_PAGE : int = 10;
		
		public static const SEARCH_OPTIONS : ArrayCollection = new ArrayCollection([
			{ label:EVERYTHING,	table:EVERYTHING, 	resultIcon: null, 				renderer: null }, 
			{ label:CONTACTS, 	table:"contacts",	resultIcon: Icons.CONTACTS,		renderer: ContactsGrid }, 
			{ label:PLEDGES,	table:"pledges",	resultIcon: Icons.PLEDGE,		renderer: PledgesGrid }, 
			{ label:USERS, 		table:"tr_users",	resultIcon: Icons.USERS, 		renderer: UsersGrid },
			{ label:EVENTS,		table:"events",		resultIcon: Icons.EVENTS,		renderer: EventsGrid },
			{ label:EMAILS, 	table:"email_log",	resultIcon: Icons.EMAIL,		renderer: EmailsGrid },
			{ label:NEWS, 		table:"news",		resultIcon: Icons.CALLS,		renderer: NewsGrid }, 
			{ label:RESOURCES, 	table:"resources",	resultIcon: Icons.RESOURCES, 	renderer: ResourcesGrid }
		]);
	}
}