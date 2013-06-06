package com.github.davidmoten.timesheet;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Query.SortDirection;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.common.base.Preconditions;

/**
 * Encapsulates database access. GoogleAppEngine (BigTable) used for
 * persistence.
 * 
 * @author dxm
 * 
 */
public class Database {

	public void saveTime(String id, Date start, long durationMs) {
		Preconditions.checkNotNull(id);
		Preconditions.checkNotNull(start);

		User user = getUser();

		// kind=db,name=schema,
		Key timesheetKey = KeyFactory.createKey("Timesheet", "Timesheet");
		// kind=table,entity=row
		Entity entry = new Entity("Entry", timesheetKey);
		entry.setProperty("user", user);
		entry.setProperty("startTime", start);
		entry.setProperty("durationMs", durationMs);
		entry.setProperty("entryId", id);

		// TODO allow addition of tags to an entry which might then be the basis
		// of queries in reports.

		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		datastore.put(entry);
		System.out.println("saved " + start + " " + durationMs);

	}

	public String getTimes(int n) {
		User user = getUser();
		long t = toUtc(System.currentTimeMillis() - n * 24 * 3600 * 1000L);
		Filter sinceFilter = new FilterPredicate("startTime",
				FilterOperator.GREATER_THAN_OR_EQUAL, new Date(t));
		Filter userFilter = new FilterPredicate("user", FilterOperator.EQUAL,
				user);
		Filter userAndSinceFilter = CompositeFilterOperator.and(userFilter,
				sinceFilter);
		Query q = new Query("Entry").setFilter(userAndSinceFilter).addSort(
				"startTime", SortDirection.ASCENDING);

		return toJson(getEntities(q));
	}

	public String getTimeRange(Date start, Date finish) {
		User user = getUser();
		Filter afterFilter = new FilterPredicate("startTime",
				FilterOperator.GREATER_THAN_OR_EQUAL, start);
		Filter beforeFilter = new FilterPredicate("startTime",
				FilterOperator.LESS_THAN, finish);
		Filter userFilter = new FilterPredicate("user", FilterOperator.EQUAL,
				user);
		Filter userAndTimeFilter = CompositeFilterOperator.and(userFilter,
				afterFilter, beforeFilter);
		Query q = new Query("Entry").setFilter(userAndTimeFilter).addSort(
				"startTime", SortDirection.ASCENDING);

		return toJson(getEntities(q));
	}

	public void deleteEntry(String id) {
		Filter idFilter = new FilterPredicate("entryId", FilterOperator.EQUAL,
				id);
		Query q = new Query("Entry").setFilter(idFilter);
		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		System.out.println("deleting");
		for (Entity entity : getEntities(q)) {
			datastore.delete(entity.getKey());
			System.out.println("deleted " + entity.getKey());
		}
	}

	private static User getUser() {
		UserService userService = UserServiceFactory.getUserService();
		return userService.getCurrentUser();
	}

	private static long toUtc(long t) {
		return t + TimeZone.getDefault().getOffset(t);
	}

	private static Iterable<Entity> getEntities(Query q) {
		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		return datastore.prepare(q).asIterable();
	}

	private String toJson(Iterable<Entity> entities) {
		StringBuilder s = new StringBuilder();
		s.append("{\n  \"entries\":[\n");
		boolean first = true;
		for (Entity entity : entities) {
			Date startTime = (Date) entity.getProperty("startTime");
			Long durationMs = (Long) entity.getProperty("durationMs");
			String id = (String) entity.getProperty("entryId");
			SimpleDateFormat df = new SimpleDateFormat(
					"yyyy-MM-dd'T'HH:mm:00.000'Z'");
			df.setTimeZone(TimeZone.getTimeZone("UTC"));
			if (!first)
				s.append(",\n");

			s.append("      {\"startTime\" : \"").append(df.format(startTime))
					.append("\"").append(",");
			s.append("\"durationMs\" : ").append("\"").append(durationMs)
					.append("\"").append(",");
			s.append("\"id\" : ").append("\"").append(id).append("\"")
					.append("}");
			first = false;
		}
		s.append("\n]}");
		System.out.println(s.toString());
		return s.toString();
	}
}
