import java.sql.*;

public class Insert {

	static private int PortID = 5333;
	static private String DBName = "tdb";
	static private String tableName = "t1";
	static private int totalRecCnt = 1024*1024*8;
	static private int numThread = 40;
        static private int recSize = 100;

	public static void main(String[] args) throws SQLException {
		String driver = null;
		try {
			driver = "cubrid.jdbc.driver.CUBRIDDriver";
			Class.forName(driver);
		} catch (ClassNotFoundException e) {
			throw new RuntimeException(e);
		}

		Insert.DBName = args[0];
		Insert.tableName = args[1];
		Insert.PortID = Integer.valueOf(args[2]);
		Insert.recSize = Integer.valueOf(args[3]);
		Insert.totalRecCnt = Integer.valueOf(args[4]);
		
                InsertThread.tableName = tableName;

		Connection conn;
                PreparedStatement pstmt = null;
		Thread thread[] = new Thread[numThread];

		try {
			for (int i = 0; i < numThread; i++) {
				conn = getConnection();
				thread[i] = new Thread(new InsertThread(conn, i, totalRecCnt/numThread));
				thread[i].start();
			}

			for (int i = 0; i < numThread; i++) {
				thread[i].join();
			}
		} catch (InterruptedException ex) {

		}

	}

	public static Connection getConnection() throws SQLException {
		String url = String.format("jdbc:cubrid:localhost:%1$d:%2$s:::", Insert.PortID, Insert.DBName);
		String user = "dba";
		String pwd = "";
		Connection conn = DriverManager.getConnection(url, user, pwd);

		return conn;
	}

}

class InsertThread implements Runnable {

	Connection conn;
	int tid;
        int tup_cnt;
	static String tableName = "t1";

	public InsertThread(Connection conn, int i, int tup_cnt) {
		this.conn = conn;
		this.tid = i;
                this.tup_cnt = tup_cnt;
	}

	@Override
	public void run() {

		PreparedStatement pstmt = null;
                int cnt = tup_cnt;
                int progress_interval = cnt/100;
                System.out.println("Thread[" + tid + "] has started");
		try {
                        conn.setAutoCommit(false);
			pstmt = conn.prepareStatement("insert into t1 (a) values(?)");
                        // pstmt = conn.prepareStatement("insert into t2 (a, b) values(?, ?)");
			// pstmt = conn.prepareStatement("insert into t1 (b, c) values (?, 'CUBRID is an object-relational database management system (ORDBMS), which supports object-oriented concepts such as inheritance. In this manual, relational database terminologies are also used along with object-oriented terminologies for better understanding. Object-oriented terminologies such as class, instance and attribute is used to describe concepts including inheritance, and relational database terminologies are mainly used to describe common SQL syntax.Introduction to CUBRID: This chapter provides a description of the structure and characteristics of the CUBRID DBMS.Getting Started: The \"Getting Started with CUBRID\" provides users with a brief explanation on what to do when first starting CUBRID. The chapter contains information on how to install and execute the system, used ports on accessing to CUBRID and provides simple explanations on the CUBRID query tools.CSQL Interpreter: CSQL is an application that allows you to use SQL statements through a command-driven interface.')");
			StringBuilder builder = new StringBuilder();
			for (int i = 0; i < cnt; i++) {
				pstmt.setInt(1, tid * cnt + i);
				// pstmt.setInt(2, tid * cnt + i);
				pstmt.executeUpdate();
                                if (i%progress_interval == 0)
                                {
                                  conn.commit();
                                  System.out.println ("["+tid+"] " + i/(float)cnt + " has been completed. ("+i+"/"+cnt+")");
                                }
			}
		} catch (SQLException ex) {
			ex.printStackTrace();
		} finally {
			if (pstmt != null)
				try {
                                        conn.commit();
					pstmt.close();
				} catch (SQLException ex) {
					ex.printStackTrace();
				}

		}

	}
}

