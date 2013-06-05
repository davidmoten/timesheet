package com.github.davidmoten;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
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

public class CommandServlet extends HttpServlet {

	private static final String COMMAND_SAVE_TIME = "saveTime";
	private static final String COMMAND_GET_TIMES = "getTimes";
	private static final String COMMAND_LOAD_TIMES = "loadTimes";
	private static final Object COMMAND_DELETE = "delete";

	private static final long serialVersionUID = 8026282588720357161L;

	// Testing url
	// http://localhost:8080/command?command=saveTime&start=2013-05-11-21-55&durationMs=60000000&id=fred

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		String command = req.getParameter("command");
		if (COMMAND_SAVE_TIME.equals(command))
			saveTime(req);
		else if (COMMAND_GET_TIMES.equals(command))
			getTimes(req, resp);
		else if (COMMAND_DELETE.equals(command))
			deleteEntry(req, resp);
		else
			throw new RuntimeException("unknown command: " + command);
	}

	private void deleteEntry(HttpServletRequest req, HttpServletResponse resp) {
		String id = req.getParameter("id");
		deleteEntry(id);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		String command = req.getParameter("command");
		if (COMMAND_LOAD_TIMES.equals(command))
			loadTimes(req);
		else
			throw new RuntimeException("unknown command: " + command);
	}

	private void loadTimes(HttpServletRequest req) {
		String s = req.getParameter("times");
		BufferedReader br = new BufferedReader(new StringReader(s));
		String line;
		try {
			while ((line = br.readLine()) != null) {
				String[] items = line.split("\t");
				SimpleDateFormat df = new SimpleDateFormat("dd/MM/yy HH:mmZ");
				Date t1 = df.parse(items[0] + " " + items[1] + "UTC");
				Date t2 = df.parse(items[0] + " " + items[2] + "UTC");
				saveTime(UUID.randomUUID().toString(), t1,
						t2.getTime() - t1.getTime());
			}
			br.close();
		} catch (IOException e) {
			throw new RuntimeException(e);
		} catch (ParseException e) {
			throw new RuntimeException(e);
		}

	}

	private void getTimes(HttpServletRequest req, HttpServletResponse resp) {
		int n = Integer.parseInt(req.getParameter("n"));
		String json = getTimes(n);
		resp.setContentType("application/json");
		try {
			resp.getWriter().print(json);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void deleteEntry(String id) {
		Filter idFilter = new FilterPredicate("entryId", FilterOperator.EQUAL,
				id);
		Query q = new Query("Entry").setFilter(idFilter);
		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		PreparedQuery pq = datastore.prepare(q);
		System.out.println("deleting");
		for (Entity entity : pq.asIterable()) {
			datastore.delete(entity.getKey());
			System.out.println("deleted " + entity.getKey());
		}
	}

	private String getTimes(int n) {
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();
		long t = toUtc(System.currentTimeMillis() - n * 24 * 3600 * 1000L);
		Filter sinceFilter = new FilterPredicate("startTime",
				FilterOperator.GREATER_THAN_OR_EQUAL, new Date(t));
		Filter userFilter = new FilterPredicate("user", FilterOperator.EQUAL,
				user);
		Filter userAndSinceFilter = CompositeFilterOperator.and(userFilter,
				sinceFilter);
		Query q = new Query("Entry").setFilter(userAndSinceFilter).addSort(
				"startTime", SortDirection.ASCENDING);

		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		PreparedQuery pq = datastore.prepare(q);

		StringBuilder s = new StringBuilder();
		s.append("{\n  \"entries\":[\n");
		boolean first = true;
		for (Entity entity : pq.asIterable()) {
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

	private void saveTime(HttpServletRequest req) {
		String id = req.getParameter("id");
		Date start = parseDate(req.getParameter("start"));
		long durationMs = Long.parseLong(req.getParameter("durationMs"));

		saveTime(id, start, durationMs);

	}

	private void saveTime(String id, Date start, long durationMs) {
		Preconditions.checkNotNull(id);
		Preconditions.checkNotNull(start);

		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();

		// kind=db,name=schema,
		Key timesheetKey = KeyFactory.createKey("Timesheet", "Timesheet");
		// kind=table,entity=row
		Entity entry = new Entity("Entry", timesheetKey);
		entry.setProperty("user", user);
		entry.setProperty("startTime", start);
		entry.setProperty("durationMs", durationMs);
		entry.setProperty("entryId", id);
		// TODO add tags as a list

		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		datastore.put(entry);
		System.out.println("saved " + start + " " + durationMs);

	}

	private Date parseDate(String date) {

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd-HH-mm-Z");
		try {
			return sdf.parse(date + "-UTC");
		} catch (ParseException e) {
			throw new RuntimeException(e);
		}

	}

	private static long toUtc(long t) {
		return t + TimeZone.getDefault().getOffset(t);
	}

}
