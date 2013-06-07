package com.github.davidmoten.timesheet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.common.base.Preconditions;

/**
 * General purpose servlet. Doesn't really offer the richness of a formal REST
 * interface but is ok for something simple.
 * 
 * @author dxm
 * 
 */
public class CommandServlet extends HttpServlet {

	private static final String COMMAND_SAVE_TIME = "saveTime";
	private static final String COMMAND_GET_TIMES = "getTimes";
	private static final String COMMAND_LOAD_TIMES = "loadTimes";
	private static final Object COMMAND_DELETE = "delete";
	private static final Object COMMAND_GET_TIME_RANGE = "getTimeRange";
	private static final Object COMMAND_EXPORT_TIMES = "exportTimes";
	private static final Object COMMAND_GET_SETTING = "getSetting";
	private static final Object COMMAND_SET_SETTING = "setSetting";

	private static final long serialVersionUID = 8026282588720357161L;

	private final Database db = new Database();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		String command = req.getParameter("command");
		if (COMMAND_SAVE_TIME.equals(command))
			saveTime(req);
		else if (COMMAND_GET_TIMES.equals(command))
			getTimes(req, resp);
		else if (COMMAND_GET_TIME_RANGE.equals(command))
			getTimeRange(req, resp);
		else if (COMMAND_DELETE.equals(command))
			deleteEntry(req, resp);
		else if (COMMAND_EXPORT_TIMES.equals(command))
			exportTimes(req, resp);
		else if (COMMAND_SET_SETTING.equals(command))
			setSetting(req, resp);
		else if (COMMAND_GET_SETTING.equals(command))
			getSetting(req, resp);
		else
			throw new RuntimeException("unknown command: " + command);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		String command = req.getParameter("command");
		if (COMMAND_LOAD_TIMES.equals(command))
			loadTimes(req, resp);
		else
			throw new RuntimeException("unknown command: " + command);
	}

	private void saveTime(HttpServletRequest req) {
		// Testing url
		// http://localhost:8080/command?command=saveTime&start=2013-05-11-21-55&durationMs=60000000&id=fred
		String id = req.getParameter("id");
		Date start = parseDate(req.getParameter("start"));
		long durationMs = Long.parseLong(req.getParameter("durationMs"));
		db.saveTime(id, start, durationMs);
	}

	private void getTimes(HttpServletRequest req, HttpServletResponse resp) {
		int n = Integer.parseInt(req.getParameter("n"));
		String json = db.getTimesJson(n);
		resp.setContentType("application/json");
		try {
			resp.getWriter().print(json);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void getTimeRange(HttpServletRequest req, HttpServletResponse resp) {
		Date start = parseDate(req.getParameter("start") + "-00-00");
		Date finish = parseDate(req.getParameter("finish") + "-00-00");
		String json = db.getTimeRangeJson(start, new Date(finish.getTime()
				+ TimeUnit.DAYS.toMillis(1)));
		resp.setContentType("application/json");
		try {
			resp.getWriter().print(json);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void deleteEntry(HttpServletRequest req, HttpServletResponse resp) {
		String id = req.getParameter("id");
		db.deleteEntry(id);
	}

	private void exportTimes(HttpServletRequest req, HttpServletResponse resp) {
		String s = db.getTimesTabDelimited();
		resp.setContentType("text/plain");
		try {
			resp.getWriter().print(s);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void loadTimes(HttpServletRequest req, HttpServletResponse resp) {
		String s = req.getParameter("times");
		BufferedReader br = new BufferedReader(new StringReader(s));
		String line;
		try {
			int count = 0;
			while ((line = br.readLine()) != null) {
				if (line.trim().length() > 0) {
					String[] items = line.split("\t");
					SimpleDateFormat df = new SimpleDateFormat(
							"dd/MM/yy HH:mmZ");
					Date t1 = df.parse(items[0] + " " + items[1] + "UTC");
					Date t2 = df.parse(items[0] + " " + items[2] + "UTC");
					db.saveTime(UUID.randomUUID().toString(), t1, t2.getTime()
							- t1.getTime());
					count++;
				}
			}
			br.close();
			resp.getWriter().print(count + " entries loaded");
		} catch (IOException e) {
			throw new RuntimeException(e);
		} catch (ParseException e) {
			throw new RuntimeException(e);
		}

	}

	private void setSetting(HttpServletRequest req, HttpServletResponse resp) {
		String key = req.getParameter("key");
		String value = req.getParameter("value");
		Preconditions.checkNotNull(key, "key parameter must not be null");
		Preconditions.checkNotNull(value, "value parameter must not be null");
		db.setSetting(key, value);
	}

	private void getSetting(HttpServletRequest req, HttpServletResponse resp) {
		String key = req.getParameter("key");
		Preconditions.checkNotNull(key, "key parameter must not be null");
		try {
			resp.setContentType("text/plain");
			resp.getWriter().print(db.getSetting(key));
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	/**
	 * Returns the {@link Date} from a date string in format yyyy-MM-dd-HH-mm.
	 * Date string is assumed to be in UTC time zone.
	 * 
	 * @param date
	 * @return
	 */
	private Date parseDate(String date) {

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd-HH-mm-Z");
		try {
			return sdf.parse(date + "-UTC");
		} catch (ParseException e) {
			throw new RuntimeException(e);
		}

	}

}
