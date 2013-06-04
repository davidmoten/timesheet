package com.github.davidmoten;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.common.base.Preconditions;

public class CommandServlet extends HttpServlet {

	private static final String COMMAND_SAVE_TIME = "saveTime";
	private static final long serialVersionUID = 8026282588720357161L;

	// Testing url
	// http://localhost:8080/command?command=saveTime&start=2013-05-11-21-55&durationMs=60000000&id=fred

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		// TODO
		String command = req.getParameter("command");
		if (COMMAND_SAVE_TIME.equals(command))
			saveTime(req);

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
		// kind=table,name=schema,
		Entity entry = new Entity("Entry", timesheetKey);
		entry.setProperty("user", user);
		entry.setProperty("startTime", start);
		entry.setProperty("durationMs", durationMs);
		// TODO add tags as a list

		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		datastore.put(entry);
	}

	private Date parseDate(String date) {

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd-HH-mm-Z");
		try {
			return sdf.parse(date + "-UTC");
		} catch (ParseException e) {
			throw new RuntimeException(e);
		}

	}

}
