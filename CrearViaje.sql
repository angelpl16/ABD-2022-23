create or replace procedure crearViaje( m_idRecorrido int, m_idAutocar int, m_fecha date, m_conductor varchar) is

    no_recorrido exception;
    no_autocar exception;
    autocar_ocupado exception;
    viaje_duplicado exception;
    
    PRAGMA EXCEPTION_INIT (no_recorrido, -20001);
    PRAGMA EXCEPTION_INIT (no_autocar, -20002);
    PRAGMA EXCEPTION_INIT (autocar_ocupado, -20003);
    PRAGMA EXCEPTION_INIT (viaje_duplicado, -20004);
    
    
    v_id_recorrido recorridos.idrecorrido%type; --Con esta variable se comprueba la duplicidad de recorridos
    v_id_autocar autocares.idautocar%type;
    v_id_viajes viajes.idViaje%type;
    v_recorrido viajes.idrecorrido%type; --Con esta variable se comprueba si un autocar esta ocupado
    v_plazas_libres modelos.nPlazas%type;
    
    existeRecorrido boolean := false;
    existeAutocar boolean := false;
    autocarOcupado boolean := false;
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
    
    select idRecorrido into v_recorrido
    from viajes 
    where m_idAutocar = idAutocar and m_fecha = fecha;
    
    
    
    IF v_recorrido is not null then
        rollback;
        raise_application_error(-20003, 'Autocar Ocupado');  
        autocarOcupado := true;
        
    END IF;
    
    select idViaje into v_id_viajes
    from viajes 
    where m_idAutocar = idAutocar and m_fecha = fecha and m_idRecorrido = idRecorrido;
    
     
    
    IF v_id_viajes is not null then
        rollback;
        raise_application_error(-20004, 'Viaje duplicado');  
        viajeDuplicado := true;
        
    END IF;
    
    select nPlazas into v_plazas_libres
    from modelos join autocares
    on modelo = idModelo
    where idAutocar = m_idAutocar;
    
    if viajeDuplicado = false and autocarOcupado = false then
        if v_plazas_libres is not null then
            insert into viajes (idViaje, idAutocar, idRecorrido, fecha, nPlazasLibres,  Conductor)
            values (seq_viajes.nextval, m_idAutocar, m_idRecorrido, m_fecha, v_plazas_libres, m_conductor);
        else
            insert into viajes (idViaje, idAutocar, idRecorrido, fecha, nPlazasLibres,  Conductor)
            values (seq_viajes.nextval, m_idAutocar, m_idRecorrido, m_fecha, 25, m_conductor);
        end if;
    end if;
    
            
    
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
        
    
end;
