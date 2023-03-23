create or replace procedure crearViaje( m_idRecorrido int, m_idAutocar int, m_fecha date, m_conductor varchar) is

    no_recorrido exception;
    no_autocar exception;
    autocar_duplicado exception;
    
    PRAGMA EXCEPTION_INIT (no_recorrido, -20001);
    PRAGMA EXCEPTION_INIT (no_autocar, -20002);
    v_id_recorrido recorridos.idrecorrido%type;
    v_id_autocar autocares.idautocar%type;
    --v_plazas_libres viajes.nPlazasLibres%type;
    
    existeRecorrido boolean := false;
    existeAutocar boolean := false;

begin

    
    
    
    select idrecorrido into v_id_recorrido
    from recorridos
    where idrecorrido=m_idrecorrido;
    
    existeRecorrido := true;
    
    select idautocar into v_id_autocar
    from autocares
    where m_idAutocar = idautocar;
    
    existeAutocar:=true;
    
   /* select idviaje 
    from viajes 
    where fecha = m_fecha and m_idAutocar = idautocar;*/  
    
    
    EXCEPTION
    WHEN no_data_found THEN 
        rollback;
        IF existeRecorrido = false THEN
            raise_application_error(-20001, 'Recorrido inexistente');
        ELSIF existeAutocar = false THEN
            raise_application_error(-20002, 'Autocar inexistente');
        END IF;   
    
end;