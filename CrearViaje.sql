create or replace procedure crearViaje( m_idRecorrido int, m_idAutocar int, m_fecha date, m_conductor varchar) is

    no_recorrido exception;
    no_autocar exception;
    autocar_ocupado exception;
    viaje_duplicado exception;
    
    PRAGMA EXCEPTION_INIT (no_recorrido, -20001);
    PRAGMA EXCEPTION_INIT (no_autocar, -20002);
    PRAGMA EXCEPTION_INIT (autocar_ocupado, -20003);
    PRAGMA EXCEPTION_INIT (viaje_duplicado, -20004);
    
    v_id_recorrido recorridos.idrecorrido%type;
    v_id_autocar autocares.idautocar%type;
    v_id_viajes viajes.idViaje%type;
    
    existeRecorrido boolean := false;
    existeAutocar boolean := false;
    autocarOcupado boolean := true;
    viajeDuplicado boolean := false;
    

begin
    select idrecorrido into v_id_recorrido
    from recorridos
    where idrecorrido=m_idrecorrido;
    
    existeRecorrido := true;
    
    select idautocar into v_id_autocar
    from autocares
    where m_idAutocar = idautocar;
    
    existeAutocar:=true;
    
    select idViaje into v_id_viajes
    from viajes 
    where m_idAutocar = idAutocar and m_fecha = fecha and m_idRecorrido = idRecorrido;
    
    IF v_id_viajes is not null then
        RAISE viaje_duplicado;
    END IF;
            
    
    EXCEPTION
    WHEN no_data_found THEN 
        rollback;
        IF existeRecorrido = false THEN
            raise_application_error(-20001, 'Recorrido inexistente');
        ELSIF existeAutocar = false THEN
            raise_application_error(-20002, 'Autocar inexistente');  
        ELSIF autocarOcupado = true THEN
            autocarOcupado := false;
        END IF;   
        
    WHEN viaje_duplicado then
        rollback;
        IF autocarOcupado = true then
            raise_application_error(-20003, 'Autocar ocupado');   
        end if;
    
end;