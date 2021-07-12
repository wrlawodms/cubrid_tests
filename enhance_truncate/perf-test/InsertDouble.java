import java.sql.*;

public class InsertDouble {

	static private int PortID = 5333;
	static private String DBName = "tdb";
	static private int doubling_cnt = 22; // 4*1024*1024

	public static void main(String[] args) throws SQLException {
		String driver = null;
		try {
			driver = "cubrid.jdbc.driver.CUBRIDDriver";
			Class.forName(driver);
		} catch (ClassNotFoundException e) {
			throw new RuntimeException(e);
		}

		InsertDouble.DBName = args[0];
		InsertDouble.PortID = Integer.valueOf(args[1]);

		Connection conn = null;
               Statement pstmt = null;

		try {
                        conn = getConnection();
                        pstmt = conn.createStatement();
			//pstmt.executeUpdate("drop table if exists t1;");
			// pstmt.executeUpdate("create table t1(a int);");
			pstmt.executeUpdate("insert into t1 (a) values(0)");
                        for (int i=1; i<=doubling_cnt; i++)
                        {
                          pstmt.executeUpdate("insert into t1 (a) select * from t1");
                          System.out.println ( "("+i+"/"+doubling_cnt+")" + " has been completed.");
                        }
		} catch (SQLException ex) {
			ex.printStackTrace();
		} finally {
			if (pstmt != null)
                        {
				try {
					pstmt.close();
				} catch (SQLException ex) {
					ex.printStackTrace();
				}
                        }

		}

	}

	public static Connection getConnection() throws SQLException {
		String url = String.format("jdbc:cubrid:localhost:%1$d:%2$s:::", InsertDouble.PortID, InsertDouble.DBName);
		String user = "dba";
		String pwd = "";
		Connection conn = DriverManager.getConnection(url, user, pwd);

		return conn;
	}

}
