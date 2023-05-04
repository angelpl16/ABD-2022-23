package lsi.ubu.solucion;

import java.sql.Connection;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.PreparedStatement;

import lsi.ubu.util.*;

public class GestionMedicos {
	public static void reservar_consulta(String m_NIF_cliente, String m_NIF_medico, Date m_Fecha_Consulta)
			throws SQLException {
		PoolDeConexiones pool = PoolDeConexiones.getInstance();
		Connection con = null;

		PreparedStatement insert_linea = null;
		PreparedStatement update_linea = null;

		java.sql.Date m_sqlFecha_Consulta = new java.sql.Date(m_Fecha_Consulta.getTime());

		try {
			con = pool.getConnection();

			// Se añade la nueva consulta
			insert_linea = con.prepareStatement(
					"INSERT INTO consultas values (sec_id_consulta.nextVal,?,?,select id_medico from medicos where NIF = ?)");
			insert_linea.setDate(1, m_sqlFecha_Consulta);
			insert_linea.setString(2, m_NIF_cliente);
			insert_linea.setString(3, m_NIF_medico);
			insert_linea.executeUpdate();

			// Se actualiza el campo consulta en la tabla medicos

			update_linea = con.prepareStatement("UPDATE medico SET consultas = 1 WHERE NIF = ?");
			update_linea.setString(1, m_NIF_medico);

			update_linea.executeUpdate();

			con.commit();
		} catch (SQLException e) {
			if (con != null) {

				con.rollback();
			}
			throw e;
		} finally {
			if (insert_linea !=null) {
				insert_linea.close();
			}
			if (update_linea != null) {
				update_linea.close();
			}
			if (con != null) {
				con.close();
			}

		}

	}

	public static void anular_consulta(String m_NIF_cliente, String m_NIF_medico, Date m_Fecha_Consulta,
			Date m_Fecha_Anulacion, String motivo) throws SQLException {

	}

	public static void consulta_medico(String m_NIF_medico) throws SQLException {

	}

}
